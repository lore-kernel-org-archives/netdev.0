From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH] MAINTAINERS: add maintainer entry for FREESCALE FEC
 ethernet driver
Date: Wed, 2 Mar 2016 09:38:54 +0000
Message-ID: <VI1PR0401MB18552E858B53A8C92A73F733FFBC0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
References: <1456910693-25787-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "b38611@freescale.com" <b38611@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0063.outbound.protection.outlook.com ([157.55.234.63]:45216
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751616AbcCBLMC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 06:12:02 -0500
In-Reply-To: <1456910693-25787-1-git-send-email-b38611@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com> Sent: Wednesday, March 02, 2016 5:25 PM
> To: davem@davemloft.net
> Cc: netdev@vger.kernel.org; Fugang Duan <fugang.duan@nxp.com>
> Subject: [PATCH] MAINTAINERS: add maintainer entry for FREESCALE FEC
> ethernet driver
> 
> Add a maintainer entry for FREESCALE FEC ethernet driver and add myself as a
> maintainer.
> 
> Signed-off-by: Fugang Duan <fugang.duan@nxp.com>
> ---

Hi David,

Recently, there have many fec Ethernet driver patches sent out review, to avoid introducing impact on fec driver stable for all i.MX platforms, I request to add myself as the driver maintainer for helping patch review.
Current the driver supports FEC and ENET controllers, support HW PTP for i.MX25/i.MX50/i.MX51/i.MX53/i.MX6x/i.MX7x/i.MX8x...    There have some feature extensions in later chips. 
It is more convenient for us to test reviewing patches.

Regards,
Andy

>  MAINTAINERS | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 0499f9e..4d4b18f 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -4552,6 +4552,15 @@ S:	Maintained
>  F:	drivers/net/ethernet/freescale/fs_enet/
>  F:	include/linux/fs_enet_pd.h
> 
> +FREESCALE IMX / MXC FEC DRIVER
> +M:	Fugang Duan <fugang.duan@nxp.com>
> +L:	netdev@vger.kernel.org
> +S:	Maintained
> +F:	drivers/net/ethernet/freescale/fec_main.c
> +F:	drivers/net/ethernet/freescale/fec_ptp.c
> +F:	drivers/net/ethernet/freescale/fec.h
> +F:	Documentation/devicetree/bindings/net/fsl-fec.txt
> +
>  FREESCALE QUICC ENGINE LIBRARY
>  L:	linuxppc-dev@lists.ozlabs.org
>  S:	Orphan
> --
> 1.9.1
