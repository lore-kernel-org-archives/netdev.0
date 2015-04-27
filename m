From: Michael Grzeschik <mgr@pengutronix.de>
Subject: Re: [PATCH 06/21] ARCNET: com20020: remove unneeded macros
Date: Mon, 27 Apr 2015 16:13:39 +0200
Message-ID: <20150427141339.GB23151@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
 <1429896055-31680-7-git-send-email-m.grzeschik@pengutronix.de>
 <1429916685.23327.32.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kernel@pengutronix.de,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:47466 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932671AbbD0ONp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 10:13:45 -0400
Content-Disposition: inline
In-Reply-To: <1429916685.23327.32.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 24, 2015 at 04:04:45PM -0700, Joe Perches wrote:
> On Fri, 2015-04-24 at 19:20 +0200, Michael Grzeschik wrote:
> > The macros SET_SUBADR, ARCRESET, ARCRESET0, ACOMMAND, ASTATUS, AINTMASK
> > and ADIAGSTATUS are unnecessary indirections to the use of registers.
> > This patch removes them and improves the readability of the code.
> 
> This breaks compilation.
> 
> Please compile test your patches before sending them.

Sorry, but I can not reproduce this break.
What was your base you applied this series on?

Can you send me the failure you get?

Thanks,
Michael

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
