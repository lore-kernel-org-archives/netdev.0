From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] ARM: OMAP: AM33XX: CAN: d_can: Add support for Bosch
 D_CAN controller
Date: Tue, 03 Apr 2012 17:54:23 +0200
Message-ID: <4F7B1D2F.40409@hartkopp.net>
References: <1333456339-9372-1-git-send-email-anilkumar@ti.com> <331ABD5ECB02734CA317220B2BBEABC1317D84CC@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "m.kleine-budde@pengutronix.de" <m.kleine-budde@pengutronix.de>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Gole, Anant" <anantgole@ti.com>, "Nori, Sekhar" <nsekhar@ti.com>
To: "AnilKumar, Chimata" <anilkumar@ti.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <331ABD5ECB02734CA317220B2BBEABC1317D84CC@DBDE01.ent.ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03.04.2012 14:39, AnilKumar, Chimata wrote:

> Hi All,
> 
> Subject line of this patch should be
> "ARM: CAN: d_can: Add support for Bosch D_CAN controller"


No, the d_can IP core is generally not limited to ARM.

	"can: Add support for Bosch D_CAN controller"

would be perfectly fine.

The correct way is:

1. post your new CAN driver to linux-can ML
2. When the major reviews & style fixes are done and the driver is fit for
mainline you can post it on ti-omap ML too

But an initial cross-posting of this CAN driver to netdev ML and linux-kernel
ML does not help anyone - it only increases traffic & confusion.

See MAINTAINERS:

http://lxr.linux.no/#linux+v3.3.1/MAINTAINERS#L1710

Thanks for following these hints,
Oliver
