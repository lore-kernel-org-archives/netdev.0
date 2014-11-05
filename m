From: Dong Aisheng <b29396@freescale.com>
Subject: Re: [PATCH V2 2/4] can: m_can: workaround for transmit data less
 than 4 bytes
Date: Wed, 5 Nov 2014 19:32:09 +0800
Message-ID: <20141105113208.GC4007@shlinux1.ap.freescale.net>
References: <1415174326-6623-1-git-send-email-b29396@freescale.com>
 <1415174326-6623-2-git-send-email-b29396@freescale.com>
 <5459F94C.1030506@pengutronix.de>
 <20141105103349.GA4007@shlinux1.ap.freescale.net>
 <545A0AC5.80006@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-can@vger.kernel.org>, <wg@grandegger.com>,
	<varkabhadram@gmail.com>, <netdev@vger.kernel.org>,
	<socketcan@hartkopp.net>, <linux-arm-kernel@lists.infradead.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <545A0AC5.80006@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 05, 2014 at 12:32:21PM +0100, Marc Kleine-Budde wrote:
> On 11/05/2014 11:33 AM, Dong Aisheng wrote:
> > On Wed, Nov 05, 2014 at 11:17:48AM +0100, Marc Kleine-Budde wrote:
> >> On 11/05/2014 08:58 AM, Dong Aisheng wrote:
> >>> At least on the i.MX6SX with M_CAN IP version 3.0.x, an issue with
> >>
> >> Can you add the imx mask revision, too and the exact m_can version (is
> >> available).
> >>
> > 
> > What do you mean imx mask revision?
> 
> In my imx6sdl/imx6q data sheet it's called: Chip Silicon Version
> (USB_ANALOG_DIGPROG), I expect that the imx6sx has a the same register.
> 
> > By reading the Core Release Register (CREL), it seems the exact m_can
> > version is 3.0.1. (CREL = 30130506).
> > 
> > So what about changing to as follows?
> > "At least on the i.MX6SX with M_CAN IP version 3.0.1 (CREL = 30130506),
> > an issue with"
> 
> Yes, please ass the imx silicon revision, too.
> 

Okay, it's i.MX6SX TO1.2. Will add it.

Regards
Dong Aisheng

> Marc
> 
> -- 
> Pengutronix e.K.                  | Marc Kleine-Budde           |
> Industrial Linux Solutions        | Phone: +49-231-2826-924     |
> Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
> Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
> 


