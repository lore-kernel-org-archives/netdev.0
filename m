From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] drivers: net: cpsw-phy-sel: add dev_warn() for
 unsupported PHY mode
Date: Mon, 15 Feb 2016 11:45:59 +0530
Message-ID: <56C16D1F.7060601@ti.com>
References: <1455324336-3884-1-git-send-email-drivshin.allworx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Nicolas Chauvet <kwizart@gmail.com>
To: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:37760 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751667AbcBOGRA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2016 01:17:00 -0500
In-Reply-To: <1455324336-3884-1-git-send-email-drivshin.allworx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 13 February 2016 06:15 AM, David Rivshin (Allworx) wrote:
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

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
