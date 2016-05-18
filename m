From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Make TCP work better with re-ordered frames?
Date: Wed, 18 May 2016 07:29:20 -0700
Message-ID: <1463581760.18194.114.camel@edumazet-glaptop3.roam.corp.google.com>
References: <573C758E.9050008@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33312 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753324AbcERO3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 10:29:24 -0400
Received: by mail-pf0-f171.google.com with SMTP id 206so19306670pfu.0
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 07:29:24 -0700 (PDT)
In-Reply-To: <573C758E.9050008@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-05-18 at 07:00 -0700, Ben Greear wrote:
> We are investigating a system that has fairly poor TCP throughput
> with the 3.17 and 4.0 kernels, but evidently it worked pretty well
> with 3.14 (I should be able to verify 3.14 later today).
> 
> One thing I notice is that a UDP download test shows lots of reordered
> frames, so I am thinking maybe TCP is running slow because of this.
> 
> (We see about 800Mbps UDP download, but only 500Mbps TCP, even when
>   using 100 concurrent TCP streams.)
> 
> Is there some way to tune the TCP stack to better handle reordered frames?

Nothing yet. Are you the sender or the receiver ?

You really want to avoid reorders as much as possible.

Are you telling us something broke in networking layers between 3.14 and
3.17 leadings to reorders ?
