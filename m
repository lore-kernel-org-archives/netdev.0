From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sched: kill dead code in sch_choke.c
Date: Tue, 03 Nov 2015 13:32:44 -0500 (EST)
Message-ID: <20151103.133244.1213287119275421272.davem@davemloft.net>
References: <1446573701-7585-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemming@brocade.com, netdev@vger.kernel.org
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46345 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754762AbbKCScr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 13:32:47 -0500
In-Reply-To: <1446573701-7585-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Tue,  3 Nov 2015 19:01:41 +0100

> It looks like this has never been used at all.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Indeed, from day one this was completely unreferenced.

One downside from marking so much stuff const is that an
unreferenced static variable won't be warned as unused if
it's const.

Applied, thanks.
