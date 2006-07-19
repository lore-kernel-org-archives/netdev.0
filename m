From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] skge: chip clock rate typo
Date: Wed, 19 Jul 2006 14:03:23 -0700
Message-ID: <20060719140323.6f8bd5b2@localhost.localdomain>
References: <200607222330.30842.mb@bu3sch.de>
	<20060719133535.40e490fc@localhost.localdomain>
	<44C53CF6.7040400@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, Jeff Garzik <jgarzik@pobox.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:421 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932248AbWGXVo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 17:44:29 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44C53CF6.7040400@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 24 Jul 2006 16:34:46 -0500
Larry Finger <Larry.Finger@lwfinger.net> wrote:

> Stephen Hemminger wrote:
> > Michael Buesch spotted this typo.  The impact is that the incorrect value
> > was being computed for blinking LED and interrupt moderation values.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> > 
> > --- skge-2.6.orig/drivers/net/skge.c
> > +++ skge-2.6/drivers/net/skge.c
> > @@ -519,7 +519,7 @@ static inline u32 hwkhz(const struct skg
> >  	if (hw->chip_id == CHIP_ID_GENESIS)
> >  		return 53215; /* or:  53.125 MHz */
> -------------------------^   Should this be 53125?
> 
> Larry
> 
yup
