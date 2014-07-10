From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net 1/7] net: cpmac: remove space in macro defination
Date: Thu, 10 Jul 2014 08:38:15 -0700
Message-ID: <1405006695.2796.3.camel@joe-AO725>
References: <1404967680-13206-1-git-send-email-varkabhadram@gmail.com>
	 <1404967680-13206-2-git-send-email-varkabhadram@gmail.com>
	 <CAGVrzcY7OpzGwY8eO-iJ9u6H91r8ywUu7y0doP5G_1pyzBd0Wg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	mugunthanvnm <mugunthanvnm@ti.com>,
	Ondrej Zary <linux@rainbow-software.org>, balbi@ti.com,
	george.cherian@ti.com, David Miller <davem@davemloft.net>,
	Varka Bhadram <varkab@cdac.in>
To: Florian Fainelli <florian@openwrt.org>,
	Varka Bhadram <varkabhadram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0015.hostedemail.com ([216.40.44.15]:48142 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750778AbaGJPiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 11:38:23 -0400
In-Reply-To: <CAGVrzcY7OpzGwY8eO-iJ9u6H91r8ywUu7y0doP5G_1pyzBd0Wg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 2014-07-09 21:47 GMT-07:00  <varkabhadram@gmail.com>:
[]
> > diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
> > index 7399a52..61eb691 100644
> > --- a/drivers/net/ethernet/ti/cpmac.c
> > +++ b/drivers/net/ethernet/ti/cpmac.c
> > @@ -67,42 +67,42 @@ MODULE_PARM_DESC(dumb_switch, "Assume switch is not connected to MDIO bus");
> >  #define CPMAC_RX_CONTROL               0x0014
> >  #define CPMAC_RX_TEARDOWN              0x0018
> >  #define CPMAC_MBP                      0x0100
> > -# define MBP_RXPASSCRC                 0x40000000
> > -# define MBP_RXQOS                     0x20000000
> > -# define MBP_RXNOCHAIN                 0x10000000
> > -# define MBP_RXCMF                     0x01000000
> > -# define MBP_RXSHORT                   0x00800000
> > -# define MBP_RXCEF                     0x00400000
> > -# define MBP_RXPROMISC                 0x00200000
> > -# define MBP_PROMISCCHAN(channel)      (((channel) & 0x7) << 16)
> > -# define MBP_RXBCAST                   0x00002000
> > -# define MBP_BCASTCHAN(channel)                (((channel) & 0x7) << 8)
> > -# define MBP_RXMCAST                   0x00000020
> > -# define MBP_MCASTCHAN(channel)                ((channel) & 0x7)

I think these are al relatively poor cleanups as
it is now no longer visually obvious that these
MBP_<FOO> defines are related to CPMAC_MBP

If you really want to do this I suggest something like:
#define CPMAC_MBP			0x0100
#define		MBP_RXPASSCRC		0x40000000
