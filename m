From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH RESEND v6 0/7] net: cpsw: Support for am335x chip MACIDs
Date: Mon, 29 Sep 2014 14:21:28 +0530
Message-ID: <54291D90.4010806@ti.com>
References: <1411973599-18908-1-git-send-email-mpa@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: =?windows-1252?Q?Beno=EEt_Cousson?= <bcousson@baylibre.com>,
	Tony Lindgren <tony@atomide.com>,
	Wolfram Sang <wsa@the-dreams.de>,
	Steven Rostedt <rostedt@goodmis.org>,
	<linux-omap@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<kernel@pengutronix.de>
To: Markus Pargmann <mpa@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1411973599-18908-1-git-send-email-mpa@pengutronix.de>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 29 September 2014 12:23 PM, Markus Pargmann wrote:
> Hi,
> 
> Another resend of this series to add the netdev list.
> 
> This series adds support to the cpsw driver to read the MACIDs of the am335x
> chip and use them as fallback. These addresses are only used if there are no
> mac addresses in the devicetree, for example set by a bootloader.
> 
> Best regards,
> 
> Markus
> 
> 
> Markus Pargmann (7):
>   DT doc: net: cpsw mac-address is optional
>   net: cpsw: Add missing return value
>   net: cpsw: header, Add missing include
>   net: cpsw: Replace pr_err by dev_err
>   net: cpsw: Add am33xx MACID readout
>   am33xx: define syscon control module device node
>   arm: dts: am33xx, Add syscon phandle to cpsw node
> 
>  Documentation/devicetree/bindings/net/cpsw.txt |  6 +++-
>  arch/arm/boot/dts/am33xx.dtsi                  |  6 ++++
>  drivers/net/ethernet/ti/Kconfig                |  2 ++
>  drivers/net/ethernet/ti/cpsw.c                 | 45 ++++++++++++++++++++++++--
>  drivers/net/ethernet/ti/cpsw.h                 |  1 +
>  5 files changed, 57 insertions(+), 3 deletions(-)
> 

Acked-by: Mugunthan V N <mugunthanvnm@gmail.com>

Regards
Mugunthan V N
