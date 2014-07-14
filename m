From: Pavel Machek <pavel@denx.de>
Subject: Re: socfpga/sockit ethernet problems
Date: Mon, 14 Jul 2014 14:36:22 +0200
Message-ID: <20140714123622.GG14300@amd.pavel.ucw.cz>
References: <20140507104518.GB18139@amd.pavel.ucw.cz>
 <20140703093548.GA9937@amd.pavel.ucw.cz>
 <1404764751.14294.3.camel@linux-builds1>
 <20140707214340.GA29061@amd.pavel.ucw.cz>
 <737g3ogvwq.fsf@unicorn.hi.pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dinh Nguyen <dinguyen@altera.com>, peppe.cavallaro@st.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	gsi@denx.de, dzu@denx.de
To: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:33509 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754439AbaGNMgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 08:36:23 -0400
Content-Disposition: inline
In-Reply-To: <737g3ogvwq.fsf@unicorn.hi.pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

> >> All of this stuff is not needed as it's already taken care of by the
> >> Micrel phy driver. The clock skew values are now represented in the DTS.
> >> Please look at:
> >> 
> >> Documentation/devicetree/bindings/net/micrel-ksz90x1.txt
> >
> > Aah, thanks for the pointer. 
> >
> > At least socfpga_cyclone5_socrates.dts is in the mainline, but it does
> > not have any skew configuration. That may explain why the board seems
> > to have problems with ethernet... (or not).
> 
> The socrates does not have these values, because it does not have a
> Micrel PHY...

Hmm, that is not it, then :-(. Is there any other setup that needs to
be done? Because from the experience with the socrates boards, they
are quite picky about cabling used.

Thanks and best regards,
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
