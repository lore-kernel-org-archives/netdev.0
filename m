From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 0/3] net: Add incoming CPU mask to sockets
Date: Tue, 26 May 2015 10:18:09 -0700
Message-ID: <1432660689.4060.275.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432658049-3400132-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:35018 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709AbbEZRSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 13:18:11 -0400
Received: by pdea3 with SMTP id a3so95294500pde.2
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 10:18:10 -0700 (PDT)
In-Reply-To: <1432658049-3400132-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-26 at 09:34 -0700, Tom Herbert wrote:
> Added matching of CPU to a socket CPU mask. This is useful for TCP
> listeners and unconnected UDP. This works with SO_REUSPORT to steer
> packets to listener sockets based on CPU affinity. These patches
> allow steering packets to listeners based on numa locality. This is
> only useful for passive connections.
> 
> v2:
>   - Add cache alignment for fields used in socket lookup in sock_common
>   - Added UDP test results

What about the feedback I gave earlier Tom ???

This cannot work for TCP in its current state.
