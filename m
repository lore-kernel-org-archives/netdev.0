From: David Miller <davem@davemloft.net>
Subject: Re: netlink: Kill bogus lock_sock in netlink_insert
Date: Sat, 16 May 2015 16:58:20 -0400 (EDT)
Message-ID: <20150516.165820.1892952636997510105.davem@davemloft.net>
References: <20150515.124955.1765730151919172866.davem@redhat.com>
	<1431712914.27831.116.camel@edumazet-glaptop2.roam.corp.google.com>
	<1431795011.27831.122.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, tgraf@suug.ch, netdev@vger.kernel.org,
	ying.xue@windriver.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37696 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbbEPU6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 16:58:22 -0400
In-Reply-To: <1431795011.27831.122.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 16 May 2015 09:50:11 -0700

> Maybe the difference between 3.15 and 4.1 is not coming from
> rhashtable/netlink but other core stuff, like mutex code.
> 
> The workload is largely dominated by mutex acquisition anyway.

Hmmm, the only commit that sticks out for me in that time-frame is:

commit 90631822c5d307b5410500806e8ac3e63928aa3e
Author: Jason Low <jason.low2@hp.com>
Date:   Mon Jul 14 10:27:49 2014 -0700

    locking/spinlocks/mcs: Convert osq lock to atomic_t to reduce overhead
    
