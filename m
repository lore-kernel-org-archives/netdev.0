From: Noam Camus <noamc@ezchip.com>
Subject: Re: [PATCH 13/22] net: Fix dependencies for !HAS_IOMEM archs
Date: Tue, 26 Jan 2016 23:15:29 +0000
Message-ID: <HE1PR02MB13871CED63A989B03AF11B56D6D80@HE1PR02MB1387.eurprd02.prod.outlook.com>
References: <1453760661-1444-1-git-send-email-richard@nod.at>,<1453760661-1444-14-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "user-mode-linux-devel@lists.sourceforge.net"
	<user-mode-linux-devel@lists.sourceforge.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Tal Zilcer <talz@ezchip.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Brodkin <abrodkin@synopsys.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Weinberger <richard@nod.at>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453760661-1444-14-git-send-email-richard@nod.at>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Weinberger <richard@nod.at>
Sent: Tuesday, January 26, 2016 12:24 AM

>Not every arch has io memory.
>So, unbreak the build by fixing the dependencies.

>Signed-off-by: Richard Weinberger <richard@nod.at>
>---
> drivers/net/ethernet/ezchip/Kconfig | 1 +
> drivers/net/phy/Kconfig             | 1 +
> 2 files changed, 2 insertions(+)

>diff --git a/drivers/net/ethernet/ezchip/Kconfig >b/drivers/net/ethernet/ezchip/Kconfig
>index 48ecbc8..b423ad3 100644
>--- a/drivers/net/ethernet/ezchip/Kconfig
>+++ b/drivers/net/ethernet/ezchip/Kconfig
>@@ -18,6 +18,7 @@ if NET_VENDOR_EZCHIP
> config EZCHIP_NPS_MANAGEMENT_ENET
>        tristate "EZchip NPS management enet support"
>       depends on OF_IRQ && OF_NET
>+       depends on HAS_IOMEM
>        ---help---
>          Simple LAN device for debug or management purposes.
>          Device supports interrupts for RX and TX(completion).

You got my ACK.

-Noam
