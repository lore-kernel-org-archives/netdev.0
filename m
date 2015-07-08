From: Duan Andy <fugang.duan@freescale.com>
Subject: RE: [PATCH v5] net: fec: Ensure clocks are enabled while using mdio
 bus
Date: Wed, 8 Jul 2015 07:52:49 +0000
Message-ID: <BLUPR03MB373367558B55CA2778FB772F5910@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1436207695-652-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0138.outbound.protection.outlook.com ([157.56.110.138]:53347
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933648AbbGHHww convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 03:52:52 -0400
In-Reply-To: <1436207695-652-1-git-send-email-andrew@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch> Sent: Tuesday, July 07, 2015 2:35 AM
> To: David Miller
> Cc: Duan Fugang-B38611; Cory Tusar; netdev; Andrew Lunn
> Subject: [PATCH v5] net: fec: Ensure clocks are enabled while using mdio
> bus
> 
> When a switch is attached to the mdio bus, the mdio bus can be used while
> the interface is not open. If the IPG clock is not enabled, MDIO
> reads/writes will simply time out.
> 
> Add support for runtime PM to control this clock. Enable/disable this
> clock using runtime PM, with open()/close() and mdio read()/write()
> function triggering runtime PM operations. Since PM is optional, the IPG
> clock is enabled at probe and is no longer modified by
> fec_enet_clk_enable(), thus if PM is not enabled in the kernel, it is
> guaranteed the clock is running when MDIO operations are performed.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
> v5:
> Rewrite to use runtime PM with fec_runtime_suspend and fec_runtime_resume
> 

The version is fine for me.

Acked-by: Fugang Duan <B38611@freescale.com>
