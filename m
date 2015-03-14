From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH v4 3/3] can: kvaser_usb: Use can-dev unregistration
 mechanism
Date: Sat, 14 Mar 2015 17:41:22 +0200
Message-ID: <20150314154122.GB18736@vivalin-002>
References: <20150226152011.GA6075@linux>
 <20150314130249.GA20796@linux>
 <20150314130952.GB20796@linux>
 <20150314131147.GC20796@linux>
 <55045340.6050908@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andri Yngvason <andri.yngvason@marel.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55045340.6050908@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 14, 2015 at 04:26:56PM +0100, Marc Kleine-Budde wrote:
> On 03/14/2015 02:11 PM, Ahmed S. Darwish wrote:
> > From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> > 
> > Use can-dev's unregister_candev() instead of directly calling
> > networking unregister_netdev(). While both are functionally
> > equivalent, unregister_candev() might do extra stuff in the
> > future than just calling networking layer unregistration code.
> 
> Since 2 goes into can, I've applied this into can-next.
> 

Merci.

Was this a cherry-pick? Because I was going to send a new
series with patch #2 better worded, and with a new patch for
the endiannes issue.

Regards,
Darwish
