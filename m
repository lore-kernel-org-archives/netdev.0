From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH v4 3/3] can: kvaser_usb: Use can-dev unregistration
 mechanism
Date: Sat, 14 Mar 2015 18:06:06 +0200
Message-ID: <20150314160606.GA18950@vivalin-002>
References: <20150226152011.GA6075@linux>
 <20150314130249.GA20796@linux>
 <20150314130952.GB20796@linux>
 <20150314131147.GC20796@linux>
 <55045340.6050908@pengutronix.de>
 <20150314154122.GB18736@vivalin-002>
 <550459DF.1050804@pengutronix.de>
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
In-Reply-To: <550459DF.1050804@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 14, 2015 at 04:55:11PM +0100, Marc Kleine-Budde wrote:
> On 03/14/2015 04:41 PM, Ahmed S. Darwish wrote:
> > On Sat, Mar 14, 2015 at 04:26:56PM +0100, Marc Kleine-Budde wrote:
> >> On 03/14/2015 02:11 PM, Ahmed S. Darwish wrote:
> >>> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> >>>
> >>> Use can-dev's unregister_candev() instead of directly calling
> >>> networking unregister_netdev(). While both are functionally
> >>> equivalent, unregister_candev() might do extra stuff in the
> >>> future than just calling networking layer unregistration code.
> >>
> >> Since 2 goes into can, I've applied this into can-next.
> 
> > Was this a cherry-pick? Because I was going to send a new
> > series with patch #2 better worded, and with a new patch for
> > the endiannes issue.
> 
> Yes, no need to resend patch #3, as it's already applied to can-next.
> 
> regards,
> Marc
> 
> 1 = can: kvaser_usb: Fix tx queue start/stop race conditions
> 2 = can: kvaser_usb: Utilize all possible tx URBs
> 3 = can: kvaser_usb: Use can-dev unregistration mechanism
> 4 = the endianess issue
> 
> 1 = is in linux-can and included in linux-can-fixes-for-4.0-20150314
> 2 = will go into linux-can with a better commit message
>     which is currently prepare by you
>     will be in the next pull request for net
> 3 = is in linux-can-next and will be included in the next pull request
>     for net-next
> 4 = is currently prepared by you
>     will be in the next pull request for net
> 
> This means, you'll send me patches 2 and 4 in a new v5 series. (This
> patches will of course have new numbers, 1 and 2.)
> 

A piece of cake :D
