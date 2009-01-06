From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: [Bugme-new] [Bug 11571] New: u32_classify Kernel
 Panic
Date: Mon, 05 Jan 2009 18:14:51 -0800 (PST)
Message-ID: <20090105.181451.193271284.davem@davemloft.net>
References: <48D1FDB8.4040805@plotinka.ru>
	<20080918075351.GA4633@ff.dom.local>
	<20090105135245.GC4460@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47505
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751293AbZAFCOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 21:14:51 -0500
In-Reply-To: <20090105135245.GC4460@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 5 Jan 2009 13:52:45 +0000

> pkt_sched: cls_u32: Fix locking in u32_change()
> 
> New nodes are inserted in u32_change() under rtnl_lock() with wmb(),
> so without tcf_tree_lock() like in other classifiers (e.g. cls_fw).
> This isn't enough without rmb() on the read side, but on the other
> hand adding such barriers doesn't give any savings, so the lock is
> added instead.
> 
> Reported-by: m0sia <m0sia@plotinka.ru>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied and queued up for -stable, thanks Jarek.
