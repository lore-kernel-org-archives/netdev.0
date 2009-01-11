From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ucc_geth: use correct UCCE macros
Date: Sun, 11 Jan 2009 00:25:45 -0800 (PST)
Message-ID: <20090111.002545.208618220.davem@davemloft.net>
References: <1231359172-6119-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leoli@freescale.com,
	galak@kernel.crashing.org, linuxppc-dev@ozlabs.org
To: timur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59335
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751131AbZAKIZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 03:25:45 -0500
In-Reply-To: <1231359172-6119-1-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@freescale.com>
Date: Wed,  7 Jan 2009 14:12:52 -0600

> The UCC Event Register (UCCE) already has unambigous macro definitions in qe.h,
> so we should not be defining our own in the UCC Ethernet driver.
> 
> Removed unused local variable 'dev' from ucc_geth_poll(), which fixes a warning
> caused by commit 908a7a16b852ffd618a9127be8d62432182d81b4.
> 
> Replaced in_be/out_be pairs with setbits32 or clrbits32, where applicable.
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>

Applied.
