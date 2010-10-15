From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tbf/htb qdisc limitations
Date: Sat, 16 Oct 2010 00:05:35 +0200
Message-ID: <20101015220535.GA1997@del.dom.local>
References: <4CB4DE6E.7030802@hp.com>
 <20101013062649.GA6915@ff.dom.local>
 <20101013233653.1e363692.billfink@mindspring.com>
 <20101014064404.GA6219@ff.dom.local>
 <20101014031354.e172d737.billfink@mindspring.com>
 <20101014080939.GA7710@ff.dom.local>
 <20101014085005.GA8349@ff.dom.local>
 <20101015023749.f085006b.billfink@mindspring.com>
 <1287125059.2659.1812.camel@edumazet-laptop>
 <20101015173746.12c7c40a.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Steven Brudenell <steven.brudenell@gmail.com>,
	netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39845 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039Ab0JOWFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 18:05:48 -0400
Received: by wyb28 with SMTP id 28so1109808wyb.19
        for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 15:05:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20101015173746.12c7c40a.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 15, 2010 at 05:37:46PM -0400, Bill Fink wrote:
...
> i7test7% tc -s -d qdisc show dev eth2
> qdisc prio 1: root refcnt 33 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 11028687119 bytes 1223828 pkt (dropped 293, overlimits 0 requeues 0) 
>  backlog 0b 0p requeues 0 
> qdisc tbf 10: parent 1:1 rate 8900Mbit burst 1112500b/64 mpu 0b lat 4295.0s 
>  Sent 11028687077 bytes 1223827 pkt (dropped 293, overlimits 593 requeues 0) 
>  backlog 0b 0p requeues 0 
> 
> I'm not sure how you can have so many dropped but not have
> any TCP retransmissions (or not show up as requeues).  But
> there's probably something basic I just don't understand
> about how all this stuff works.

Me either, but it seems higher "limit" might help with these drops.

Jarek P.
