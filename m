From: Rafal Ozieblo <rafalo@cadence.com>
Subject: RE: [PATCH net-next v2] macb: Common code to enable ptp support for
 MACB/GEM
Date: Thu, 26 Jan 2017 15:15:58 +0000
Message-ID: <BN3PR07MB25160FCBCF19918C495F43B4C9770@BN3PR07MB2516.namprd07.prod.outlook.com>
References: <1484841375-11420-1-git-send-email-andrei.pistirica@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "punnaia@xilinx.com" <punnaia@xilinx.com>,
        "michals@xilinx.com" <michals@xilinx.com>,
        "anirudh@xilinx.com" <anirudh@xilinx.com>,
        "boris.brezillon@free-electrons.com"
        <boris.brezillon@free-electrons.com>,
        "alexandre.belloni@free-electrons.com"
        <alexandre.belloni@free-electrons.com>,
        "tbultel@pixelsurmer.com" <tbultel@pixelsurmer.com>,
        "richardcochran@gmail.com" <richardcochran@gmail.com>
To: Andrei Pistirica <andrei.pistirica@microchip.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
        "harinikatakamlinux@gmail.com" <harinikatakamlinux@gmail.com>,
        "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484841375-11420-1-git-send-email-andrei.pistirica@microchip.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Andrei Pistirica [mailto:andrei.pistirica@microchip.com]=20
> Sent: 19 stycznia 2017 16:56
> Subject: [PATCH net-next v2] macb: Common code to enable ptp support for =
MACB/GEM
>=20
> =20
> +static inline bool gem_has_ptp(struct macb *bp)
> +{
> +	return !!(bp->caps & MACB_CAPS_GEM_HAS_PTP);
> +}
Why don't you use hardware capabilities here? Would it be better to read it=
 from hardware instead adding it to many configuration?
