From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH] pch_gbe: Use a randomly generated MAC instead of
 failing probe
Date: Mon, 16 Jan 2012 16:44:24 +0000
Message-ID: <20120116164424.GA19621@sirena.org.uk>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF47@saturn3.aculab.com>
 <4F1451BD.9030904@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	Darren Hart <dvhart@linux.intel.com>,
	Alan Cox <alan@linux.intel.com>,
	Tomoya MORINAGA <tomoya.rohm@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	paul.gortmaker@windriver.com, jdmason@kudzu.us,
	netdev@vger.kernel.org
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F1451BD.9030904@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 16, 2012 at 08:35:09AM -0800, Arjan van de Ven wrote:
> On 1/16/2012 8:20 AM, David Laight wrote:

> > Since multiple interfaces on a single system are unlikely
> > to be connected to the same LAN segment, it doesn't really
> > matter if they use same MAC address.

> I think you missed the point. All embedded devices have the same fs, so
> if you have 2 boxes of the same model/brand on the same network, they'd
> have the same MAC. That's generally frowned upon by network
> administrators ;-)

This is generally handled by putting the MAC into a board-specific bit
of flash that isn't part the main firmware (for example, the bootloader
configuration) - for a lot of applications random generation doesn't
help that much as entropy is hard to come by.
