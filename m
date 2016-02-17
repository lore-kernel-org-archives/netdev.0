From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: cpsw-phy-sel: add dev_warn() for
 unsupported PHY mode
Date: Wed, 17 Feb 2016 10:51:04 -0500 (EST)
Message-ID: <20160217.105104.143723229571677119.davem@davemloft.net>
References: <1455324336-3884-1-git-send-email-drivshin.allworx@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, mugunthanvnm@ti.com, kwizart@gmail.com
To: drivshin.allworx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53552 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423032AbcBQPvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 10:51:06 -0500
In-Reply-To: <1455324336-3884-1-git-send-email-drivshin.allworx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Date: Fri, 12 Feb 2016 19:45:36 -0500

> From: David Rivshin <drivshin@allworx.com>
> 
> The cpsw-phy-sel driver supports only MII, RMII, and RGMII PHY modes,
> and silently handled any other values as if MII was specified. In a
> case where the PHY mode was incorrectly specified, or a bug elsewhere,
> there would be no indication of a problem. If MII was the correct mode,
> then this will go unnoticed, otherwise the symptom will be a failure
> to transmit/receive data over the RMII/RGMII link.
> 
> Add a dev_warn() to make this condition obvious and provide a
> breadcrumb to follow.
> 
> Cc: Mugunthan V N <mugunthanvnm@ti.com>
> Signed-off-by: David Rivshin <drivshin@allworx.com>

Applied to 'net', thanks.  I don't think I'll queue this up for -stable.

Thanks.
