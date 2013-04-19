From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash
 list depth
Date: Fri, 19 Apr 2013 07:45:03 -0700
Message-ID: <1366382703.16391.2.camel@edumazet-glaptop>
References: <20130418213637.14296.43143.stgit@dragon>
	 <20130418213732.14296.36026.stgit@dragon>
	 <1366366287.3205.98.camel@edumazet-glaptop>
	 <1366373950.26911.134.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f41.google.com ([209.85.210.41]:50988 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030606Ab3DSOpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 10:45:06 -0400
Received: by mail-da0-f41.google.com with SMTP id p8so1861493dan.0
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 07:45:05 -0700 (PDT)
In-Reply-To: <1366373950.26911.134.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 14:19 +0200, Jesper Dangaard Brouer wrote:
> On Fri, 2013-04-19 at 03:11 -0700, Eric Dumazet wrote:

> > I am not sure its worth adding extra complexity.
> 
> It's not that complex, and we simply need it, else an attacker can DoS
> us very easily by sending a burst every 30 sec.  We do need this change,
> else we must revert Hannes patch, and find a complete other approach of
> removing the LRU list system.

Its a never ending stuff.

fragments are fundamentally not suitable for any workload that can be
attacked by an hostile guy.

The guy will adapt its strategy knowing yours.

Thats pretty easy for him, linux sources are public.
