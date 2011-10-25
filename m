From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [RFC PATCH 06/17] phy_driver: Add and use
 phy_driver_[un]register_multiple()
Date: Tue, 25 Oct 2011 07:00:03 +0200
Message-ID: <20111025050003.GC798@ponder.secretlab.ca>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
 <1319144425-15547-7-git-send-email-Kyle.D.Moffett@boeing.com>
 <201110201715.58441.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kyle Moffett <Kyle.D.Moffett@boeing.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@conan.davemloft.net>,
	Greg Dietsche <Gregory.Dietsche@cuw.edu>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	David Daney <ddaney@caviumnetworks.com>,
	Arnaud Patard <arnaud.patard@rtp-net.org>,
	Baruch Siach <baruch@tkos.co.il>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201110201715.58441.vapier@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 20, 2011 at 05:15:54PM -0400, Mike Frysinger wrote:
> On Thursday 20 October 2011 17:00:13 Kyle Moffett wrote:
> > +	return phy_driver_register_multiple(bcm63xx_drivers,
> > +			ARRAY_SIZE(bcm63xx_drivers));
> 
> if only the arm ARRAY_AND_SIZE() macro could gain traction in the wider tree:
> 	return phy_driver_register_multiple(ARRAY_AND_SIZE(bcm63xx_drivers));

Propose a patch to move it from arch/arm to include/linux/kernel.h.
This is the first I've heard of this macro, but I would probably use
it.

> ignoring that, this patch looks cool
> 
> Acked-by: Mike Frysinger <vapier@gentoo.org>

Indeed, I like the diffstat.  :-)

Acked-by: Grant Likely <grant.likely@secretlab.ca>
