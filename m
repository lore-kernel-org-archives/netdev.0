From: Rafal Ozieblo <rafalo@cadence.com>
Subject: [RFC PATCH 1/2] macb: Add 1588 support in Cadence GEM.
Date: Fri, 18 Nov 2016 12:05:53 +0000
Message-ID: <BN3PR07MB2516576760AA9CDF8647973DC9B00@BN3PR07MB2516.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
        "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "andrei.pistirica@microchip.com" <andrei.pistirica@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Andrei,

>+static struct ptp_clock_info macb_ptp_caps =3D {
>+       .owner          =3D THIS_MODULE,
>+       .name           =3D GMAC_TIMER_NAME,
>+       .max_adj        =3D 250000000,
>+       .n_alarm        =3D 0,
>+       .n_ext_ts       =3D 0,
>+       .n_per_out      =3D 0,
>+       .n_pins         =3D 0,
>+       .pps            =3D 0,
>+       .adjfreq        =3D macb_ptp_adjfreq,
>+       .adjtime        =3D macb_ptp_adjtime,
>+       .gettime64      =3D macb_ptp_gettime,
>+       .settime64      =3D macb_ptp_settime,
>+       .enable         =3D macb_ptp_enable,
>+};

I'm wondering, how did you count max_adj ?

Best regards,

Rafal Ozieblo=A0=A0=A0|=A0=A0=A0Firmware System Engineer,=20
phone nbr.: +48 32=A05085469=20


www.cadence.com


=A0
