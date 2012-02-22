From: mroos@linux.ee
Subject: Re: 3.3-rc3+ Crash in __neigh_for_each_release
Date: Wed, 22 Feb 2012 09:19:15 +0200 (EET)
Message-ID: <alpine.SOC.1.00.1202220918220.21339@math.ut.ee>
References: <alpine.SOC.1.00.1202201359190.8004@math.ut.ee>  <1329851004.18384.45.camel@edumazet-laptop>  <20120221.140716.1396286389544946379.davem@davemloft.net>  <1329851756.18384.47.camel@edumazet-laptop> <1329857209.18384.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.it.da.ut.ee ([193.40.5.66]:53733 "EHLO smtp1.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751716Ab2BVHTT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Feb 2012 02:19:19 -0500
In-Reply-To: <1329857209.18384.53.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> What about following patch ?
> 
> Meelis, can you test it please ?

Works fine, thank you!
 
> [PATCH] atm: clip: remove clip_tbl
> 
> Commit 32092ecf0644 (atm: clip: Use device neigh support on top of
> "arp_tbl".) introduced a bug since clip_tbl is zeroed : Crash occurs in
> __neigh_for_each_release()
> 
> idle_timer_check() must use instead arp_tbl and neigh_check_cb() should
> ignore non clip neighbours.
> 
> Idea from David Miller.
> 
> Reported-by: Meelis Roos <mroos@linux.ee>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Tested-by: Meelis Roos <mroos@linux.ee>

-- 
Meelis Roos (mroos@linux.ee)
