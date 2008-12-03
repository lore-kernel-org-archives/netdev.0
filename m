From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH]  remove isa stuff from smc91x driver
Date: Wed, 3 Dec 2008 16:30:23 +0000
Message-ID: <OF69EAE3F6.7E12E2A6-ON80257514.0059AB2C-80257514.005ABFB9@smsc.com>
References: <20081203151919.GD5559@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org,
	Luotao Fu <l.fu@pengutronix.de>, netdev@vger.kernel.org,
	Ian.Saturley@smsc.com
To: Luotao Fu <l.fu@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:1248 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751005AbYLCQbd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2008 11:31:33 -0500
In-Reply-To: <20081203151919.GD5559@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

> > > ISA support in smc91x is incomplete. I doubt there're any smc91xisa 
card.
> > > This driver is greatly used on arm pxa platforms. Hence we remove 
the
> > > isa stuff from smc91x driver.
> > 
> > This makes no sense. It is protected by an ifdef anyway so doesn't 
affect
> > ARM
> 
> The isa part in smc91x does nothing at all. Get you a unused 
> variable warning if
> you turn ISA on and compile it. The io table is defined and not used at 
all.
> Neither does the io address and irq by parameter. I think that theseare 
waste
> code and should be removed.

SMSC LAN91C111 *does* still exist on ISA platforms (for example PC104), 
but
Luotao is right: the smc91x driver support for it is broken.

I have one here on an ISA board (and it took me a long time to find 
working PC
hardware old enough to use this!).  I'll send a patch when I can find time 
to
fix it, but until then I agree this broken code should be removed.

Acked-by: Steve Glendinning <steve.glendinning@smsc.com>

--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com

