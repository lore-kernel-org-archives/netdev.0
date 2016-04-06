From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH net-next V3 02/16] net: fec: remove unused interrupt
 FEC_ENET_TS_TIMER
Date: Wed, 6 Apr 2016 09:10:30 +0000
Message-ID: <VI1PR0401MB1855BC1C6A65516245790BA3FF9F0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
References: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
 <1459909562-22865-3-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "andrew@lunn.ch" <andrew@lunn.ch>,
 "stillcompiling@gmail.com" <stillcompiling@gmail.com>,
 "arnd@arndb.de" <arnd@arndb.de>,
 "sergei.shtylyov@cogentembedded.com" <sergei.shtylyov@cogentembedded.com>,
 "gerg@uclinux.org" <gerg@uclinux.org>, Fabio Estevam <fabio.estevam@nxp.com>,
 "johannes@sipsolutions.net" <johannes@sipsolutions.net>,
 "l.stach@pengutronix.de" <l.stach@pengutronix.de>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 "tremyfr@gmail.com" <tremyfr@gmail.com>
To: Troy Kisky <troy.kisky@boundarydevices.com>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>, "davem@davemloft.net" <davem@davemloft.net>,
 "lznuaa@gmail.com" <lznuaa@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1459909562-22865-3-git-send-email-troy.kisky@boundarydevices.com>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Wednesday, April 06, 2016 10:26 AM
> To: netdev@vger.kernel.org; davem@davemloft.net; Fugang Duan
> <fugang.duan@nxp.com>; lznuaa@gmail.com
> Cc: Fabio Estevam <fabio.estevam@nxp.com>; l.stach@pengutronix.de;
> andrew@lunn.ch; tremyfr@gmail.com; gerg@uclinux.org; linux-arm-
> kernel@lists.infradead.org; johannes@sipsolutions.net;
> stillcompiling@gmail.com; sergei.shtylyov@cogentembedded.com;
> arnd@arndb.de; Troy Kisky <troy.kisky@boundarydevices.com>
> Subject: [PATCH net-next V3 02/16] net: fec: remove unused interrupt
> FEC_ENET_TS_TIMER
> 
> FEC_ENET_TS_TIMER is not checked in the interrupt routine so there is no need
> to enable it.
> 
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> 
> ---
> v3: New patch
> 
> Frank Li said "TS_TIMER should never be triggered."
> when discussing another patch.
> ---
>  drivers/net/ethernet/freescale/fec.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec.h
> b/drivers/net/ethernet/freescale/fec.h
> index 195122e..6dd0ba8 100644
> --- a/drivers/net/ethernet/freescale/fec.h
> +++ b/drivers/net/ethernet/freescale/fec.h
> @@ -374,8 +374,8 @@ struct bufdesc_ex {
>  #define FEC_ENET_TS_AVAIL       ((uint)0x00010000)
>  #define FEC_ENET_TS_TIMER       ((uint)0x00008000)
> 
> -#define FEC_DEFAULT_IMASK (FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII
> | FEC_ENET_TS_TIMER)
> -#define FEC_NAPI_IMASK	(FEC_ENET_MII | FEC_ENET_TS_TIMER)
> +#define FEC_DEFAULT_IMASK (FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII)
> +#define FEC_NAPI_IMASK	FEC_ENET_MII
>  #define FEC_RX_DISABLED_IMASK (FEC_DEFAULT_IMASK & (~FEC_ENET_RXF))
> 
>  /* ENET interrupt coalescing macro define */
> --
> 2.5.0

Acked-by: Fugang Duan <fugang.duan@nxp.com>
