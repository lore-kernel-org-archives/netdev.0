From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] drivers: net: cpsw: Fix bugs in fixed-link PHY
 DT parsing
Date: Fri, 18 Dec 2015 14:46:36 -0500 (EST)
Message-ID: <20151218.144636.771957142710802303.davem@davemloft.net>
References: <20151209223115.6c5a400f.drivshin.allworx@gmail.com>
	<1741588.Ve76Z1ZI87@localhost>
	<cover.1450309613.git.drivshin@allworx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, systemprogrammierung.brunner@gmail.com,
	mugunthanvnm@ti.com, kernel@iktek.de, dtrautmann@ibhsoftec-sps.de
To: drivshin.allworx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932554AbbLRTqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 14:46:38 -0500
In-Reply-To: <cover.1450309613.git.drivshin@allworx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Date: Wed, 16 Dec 2015 23:02:08 -0500

> Commit 1f71e8c96fc654724723ce987e0a8b2aeb81746d ("drivers: net: cpsw:
> Add support for fixed-link PHY") added initial fixed-link PHY support
> for CPSW, but missed a few considerations.
> 
> This series is based on the tip of the net tree. The first two patches
> fix user-visible errors in different hardware configurations. The third
> patch is for an internal reference counting issue. They are logically
> independent changes, but in the same function, so must be applied in
> order to apply cleanly.
> 
> The first patch was originally submitted by Pascal Speck on December 4,
> but was not picked up by patchwork. I suspect that is because the patch
> was mangled by the mailer. I fixed the mangling and am including it in
> this series, as I believe it is the correct change.
> 
> I have tested on the following hardware configurations:
>  - (EVMSK) dual emac with two real MDIO-connected phys using RGMII-TXID
>  - single emac with fixed-link using RGMII
> Testing of other CPSW emac configurations that folks may have would
> be appreciated.

Series applied, thanks David.
