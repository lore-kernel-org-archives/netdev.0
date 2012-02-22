From: David Miller <davem@davemloft.net>
Subject: Re: 3.3-rc3+ Crash in __neigh_for_each_release
Date: Wed, 22 Feb 2012 02:24:46 -0500 (EST)
Message-ID: <20120222.022446.2266738985280478421.davem@davemloft.net>
References: <1329851756.18384.47.camel@edumazet-laptop>
	<1329857209.18384.53.camel@edumazet-laptop>
	<alpine.SOC.1.00.1202220918220.21339@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: mroos@linux.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37022 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058Ab2BVHY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 02:24:56 -0500
In-Reply-To: <alpine.SOC.1.00.1202220918220.21339@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: mroos@linux.ee
Date: Wed, 22 Feb 2012 09:19:15 +0200 (EET)

>> What about following patch ?
>> 
>> Meelis, can you test it please ?
> 
> Works fine, thank you!
>  
>> [PATCH] atm: clip: remove clip_tbl
>> 
>> Commit 32092ecf0644 (atm: clip: Use device neigh support on top of
>> "arp_tbl".) introduced a bug since clip_tbl is zeroed : Crash occurs in
>> __neigh_for_each_release()
>> 
>> idle_timer_check() must use instead arp_tbl and neigh_check_cb() should
>> ignore non clip neighbours.
>> 
>> Idea from David Miller.
>> 
>> Reported-by: Meelis Roos <mroos@linux.ee>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Tested-by: Meelis Roos <mroos@linux.ee>

Applied, thanks everyone.
