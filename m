From: Pavel Machek <pavel@denx.de>
Subject: Re: socfpga/sockit ethernet problems
Date: Mon, 14 Jul 2014 14:34:16 +0200
Message-ID: <20140714123416.GF14300@amd.pavel.ucw.cz>
References: <20140507104518.GB18139@amd.pavel.ucw.cz>
 <20140703093548.GA9937@amd.pavel.ucw.cz>
 <1404764751.14294.3.camel@linux-builds1>
 <20140707214340.GA29061@amd.pavel.ucw.cz>
 <53BBA219.8000607@roese.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dinh Nguyen <dinguyen@altera.com>, dzu@denx.de,
	netdev@vger.kernel.org, gsi@denx.de, peppe.cavallaro@st.com,
	s.trumtrar@pengutronix.de, linux-arm-kernel@lists.infradead.org
To: Stefan Roese <mail@roese.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:33442 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754326AbaGNMeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 08:34:18 -0400
Content-Disposition: inline
In-Reply-To: <53BBA219.8000607@roese.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

> >Are there suitable default values?
> >
> >u-boot uses these defaults:
> >
> >include/configs/socfpga_common.h:#define CONFIG_KSZ9021_CLK_SKEW_VAL
> >0xf0f0
> >include/configs/socfpga_common.h:#define CONFIG_KSZ9021_DATA_SKEW_VAL
> >0x0
> >
> >...that should correspond to txc-skew-ps == rxc-skew-ps == 3000, all
> >other skew values == 0?
> >
> >Could someone with socrates board and network problems test if this
> >makes any difference?
> 
> SoCrates uses a different PHY, the Lantiq PEF7071 (PHY11G). So those
> dts additions have no effect on SoCrates.

Oops, I guess I was confused.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
