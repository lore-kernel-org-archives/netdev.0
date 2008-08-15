From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Fix unlocking in tc_ctl_tfilter()
Date: Thu, 14 Aug 2008 17:01:25 -0700 (PDT)
Message-ID: <20080814.170125.62607985.davem@davemloft.net>
References: <20080814224129.GA2517@ami.dom.local>
	<200808150156.49541.denys@visp.net.lb>
	<20080814232708.GB2517@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57483
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754741AbYHOABZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 20:01:25 -0400
In-Reply-To: <20080814232708.GB2517@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 15 Aug 2008 01:27:09 +0200

> pkt_sched: Fix unlocking in tc_ctl_tfilter()
> 
> Fix a bug with spin_lock_bh() inserted instead of spin_unlock_bh() by
> some recent patch. 
> 
> Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Excellent find, applied, thanks!
