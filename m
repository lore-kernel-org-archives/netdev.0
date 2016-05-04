From: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Subject: RE: [PATCH v5 1/2] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Wed, 4 May 2016 06:23:44 +0000
Message-ID: <SG2PR06MB1038986EFD250DCE8E9D8D05C37B0@SG2PR06MB1038.apcprd06.prod.outlook.com>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1461846188-31249-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1461846188-31249-2-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <20160503164728.GA32640@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "mkl@pengutronix.de" <mkl@pengutronix.de>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"socketcan@hartkopp.net" <socketcan@hartkopp.net>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"linux-renesas-soc@vger.kernel.org"
	<linux-renesas-soc@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chris Paterson <Chris.Paterson2@renesas.com>
To: Rob Herring <robh@kernel.org>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20160503164728.GA32640@rob-hp-laptop>
Content-Language: en-US
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rob,

> On Thu, Apr 28, 2016 at 01:23:07PM +0100, Ramesh Shanmugasundaram wrote:
> > This patch adds support for the CAN FD controller found in Renesas
> > R-Car SoCs. The controller operates in CAN FD only mode by default.
> >
> > CAN FD mode supports both Classical CAN & CAN FD frame formats. The
> > controller supports ISO 11898-1:2015 CAN FD format only.
> >
> > This controller supports two channels and the driver can enable either
> > or both of the channels.
> >
> > Driver uses Rx FIFOs (one per channel) for reception & Common FIFOs
> > (one per channel) for transmission. Rx filter rules are configured to
> > the minimum (one per channel) and it accepts Standard, Extended, Data
> > & Remote Frame combinations.
> >
> > Note: There are few documentation errors in R-Car Gen3 Hardware User
> > Manual v0.5E with respect to CAN FD controller. They are listed below:
> >
> > 1. CAN FD interrupt numbers 29 & 30 are listed as per channel
> > interrupts. However, they are common to both channels (i.e.) they are
> > global and channel interrupts respectively.
> >
> > 2. CANFD clock is derived from PLL1. This is not documented.
> >
> > 3. CANFD clock is further divided by (1/2) within the CAN FD controller.
> > This is not documented.
> >
> > 4. The minimum value of NTSEG1 in RSCFDnCFDCmNCFG register is 2 Tq. It
> > is specified 4 Tq in the manual.
> >
> > 5. The maximum number of message RAM area the controller can use is
> > 3584 bytes. It is specified 10752 bytes in the manual.
> >
> > Signed-off-by: Ramesh Shanmugasundaram
> > <ramesh.shanmugasundaram@bp.renesas.com>
> > ---
> >  .../devicetree/bindings/net/can/rcar_canfd.txt     |   89 ++
> 
> What happened to my ack?

Sorry, I missed it when I updated the patch. I mentioned it in cover letter though. I will request the CAN maintainer to add it if this is accepted or otherwise I will add it to the next patch series.

---
Changes since v3:
	* Split v3 patch into two (Marc K)
	  (1) Introduce rcar_canfd.c driver in drivers/net/can/rcar dir
	  (2) Move rcar_can.c driver to new drivers/net/can/rcar dir
	* Added Acked-by Rob H for the bindings
---

Thanks,
Ramesh
