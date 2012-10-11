From: Dong Aisheng <b29396@freescale.com>
Subject: Re: [PATCH] flexcan: disable bus error interrupts for the i.MX28
Date: Thu, 11 Oct 2012 09:41:38 +0800
Message-ID: <20121011014135.GA7374@shlinux2.ap.freescale.net>
References: <5065A35B.3020702@grandegger.com>
 <20121007030858.GJ20231@S2101-09.ap.freescale.net>
 <50719647.4070404@grandegger.com>
 <7FE21149F4667147B645348EC60578850B2A361F@039-SN2MPN1-011.039d.mgd.msft.net>
 <5075D4DA.7010407@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux-CAN <linux-can@vger.kernel.org>,
	Hui Wang <jason77.wang@gmail.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5075D4DA.7010407@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 10, 2012 at 10:04:42PM +0200, Marc Kleine-Budde wrote:
> On 10/08/2012 09:59 AM, Dong Aisheng-B29396 wrote:
> [...]
> 
> >>>> Concerning the bug, I know that the i.MX35 does have it. Maybe other
> >>>> Flexcan cores than on the i.MX28 does *not* have it either. If you
> >>>> have a chance, please check on the P1010, i.MX6Q, i.MX51, i.MX53,
> >>>> etc.
> >>>
> >>> >From what I can tell, i.MX35, i.MX51 and i.MX53 use the same version,
> >>> so they should all have the bug.  And for i.MX6Q, since it uses a
> >>> newer version even than i.MX28, I would believe it's affected by the bug.
> >>> But I'm copying Dong who should have better knowledge about this to
> >>> confirm.
> >>
> >> Thank for clarification. I have a i.MX6Q board but without CAN adapter :(,
> >> unfortunately. Otherwise I would try it out myself.
> >>
> > How did you verify this issue?
> > I just checked our ic guy of flexcan, it seems he also had no sense of this issue.
> 
> Wolfgang added this table to the driver code, which is a very good idea.
> I've some (nitpicky) questions :)
> 
> > Below is some version info what I got:
> > Mx6s use FlexCAN3, with IP version 10.00.12.00
>     ^^^
> Is this core different from the mx6q?
Yes, it's a single core named i.MX6 Solo.
For details, please see:
http://www.freescale.com/webapp/sps/site/taxonomy.jsp?code=IMX6X_SERIES

> Has the flexcan on mx6 a glitch filter?
> 
Yes.

> > Mx53 use FlexCAN2 (with glitch filter), with IP version 03.00.00.00
> > Mx28 use FlexCAN2 (with glitch filter), with IP version 03.00.04.00
> > Mx35 use FlexCAN2 (without glitch filter) , with IP version 03.00.00.00
> > Mx25 use FlexCAN2 (without glitch filter), with IP version 03.00.00.00
> 
> Do you have access to the powerpc designs which have a flexcan core,
> too? I'm interested to complete the above table with powerpcs cores
> (p1010 and similar).
Sorry, we don't have access.

Regards
Dong Aisheng
> 
> Marc
> -- 
> Pengutronix e.K.                  | Marc Kleine-Budde           |
> Industrial Linux Solutions        | Phone: +49-231-2826-924     |
> Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
> Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
> 



