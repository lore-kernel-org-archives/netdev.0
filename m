From: Dong Aisheng <b29396@freescale.com>
Subject: Re: M_CAN message RAM initialization AppNote  - was: Re: [PATCH V3
 3/3] can: m_can: workaround for transmit data less than 4 bytes
Date: Fri, 7 Nov 2014 16:40:52 +0800
Message-ID: <20141107084051.GB23086@shlinux1.ap.freescale.net>
References: <1415193393-30023-1-git-send-email-b29396@freescale.com>
 <1415193393-30023-3-git-send-email-b29396@freescale.com>
 <545A3451.2090302@pengutronix.de> <545A692E.40002@hartkopp.net>
 <20141106015716.GB7642@shlinux1.ap.freescale.net>
 <545B1D71.4000408@hartkopp.net>
 <20141106080940.GA22964@shlinux1.ap.freescale.net>
 <545B6AB4.70003@hartkopp.net> <545B6DD8.6010906@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	<linux-can@vger.kernel.org>, <wg@grandegger.com>,
	<varkabhadram@gmail.com>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0130.outbound.protection.outlook.com ([65.55.169.130]:50920
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751320AbaKGJK5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2014 04:10:57 -0500
Content-Disposition: inline
In-Reply-To: <545B6DD8.6010906@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 06, 2014 at 01:47:20PM +0100, Marc Kleine-Budde wrote:
> On 11/06/2014 01:33 PM, Oliver Hartkopp wrote:
> >> So i'm not sure memset() the entire TX FIFO element is neccesary...
> > 
> > It's no big deal - so we should be defensive here.
> > And memset() is not working as Marc pointed out in another mail.
> > 
> > So we would need to loop with
> > 
> >     m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(i), 0x0);
> > 
> >>
> >> Do you think we could keep the current solution firstly and updated later
> >> if needed?
> > 
> > No :-)
> > 
> > I would like to have all data bytes to be written at startup.
> 
> Me, too. As this happens only once during ifconfig up it should not hurt
> performance, either send an incremental or new patch. I'll sort it out.
> 

I will send a new patch for this.

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
