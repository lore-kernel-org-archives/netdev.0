From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net: delete orphaned MCA ibmlana
 driver content
Date: Mon, 14 Jan 2013 21:26:22 -0500 (EST)
Message-ID: <20130114.212622.2148013404188632702.davem@davemloft.net>
References: <1358216245-3956-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37622 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601Ab3AOC0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 21:26:23 -0500
In-Reply-To: <1358216245-3956-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 14 Jan 2013 21:17:25 -0500

> In commit a5e371f61ad33c07b28e7c9b60c78d71fdd34e2a ("drivers/net: delete
> all code/drivers depending on CONFIG_MCA") most of the MCA drivers went,
> including the Kconfig/Makefile hooks for ibmlana, but it seems that I
> missed the "git rm" on these actual driver files, and with the namespace
> overlap with machine check architecture, it got missed by various git
> grep type checking done at that time.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks Paul.
