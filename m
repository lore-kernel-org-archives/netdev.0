From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] drivers: xgene: Add support RGMII
 TX/RX delay configuration
Date: Fri, 30 Oct 2015 12:22:20 +0900 (KST)
Message-ID: <20151030.122220.1215954538392198950.davem@davemloft.net>
References: <1445898316-21372-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, patches@apm.com,
	f.fainelli@gmail.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59844 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460AbbJ3DWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 23:22:24 -0400
In-Reply-To: <1445898316-21372-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Mon, 26 Oct 2015 15:25:14 -0700

> X-Gene RGMII ethernet controller has a RGMII bridge that performs the
> task of converting the RGMII signal {RX_CLK,RX_CTL, RX_DATA[3:0]} from
> PHY to GMII signal {RX_DV,RX_ER,RX_DATA[7:0]} and vice versa.  This
> RGMII bridge has a provision to internally delay the input RX_CLK and
> the output TX_CLK using configuration registers. This will help in
> maintain the CLK-CTL delay relationship in various operating
> conditions.
> 
> This patch adds support RGMII TX/RX delay configuration.
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>

Series applied, thanks.
