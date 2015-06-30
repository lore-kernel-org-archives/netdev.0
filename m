From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: missing in stable 4.1.1 - was Re: pull-request: can 2015-06-21
Date: Tue, 30 Jun 2015 13:07:13 -0700
Message-ID: <20150630200713.GA10747@kroah.com>
References: <1434906299-19452-1-git-send-email-mkl@pengutronix.de>
 <20150623.064338.1193972764545855895.davem@davemloft.net>
 <5592EE98.8030705@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@vger.kernel.org, David Miller <davem@davemloft.net>,
	mkl@pengutronix.de, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, kernel@pengutronix.de
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5592EE98.8030705@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 30, 2015 at 09:31:36PM +0200, Oliver Hartkopp wrote:
> Hello Greg,
> 
> On 23.06.2015 15:43, David Miller wrote:
> >From: Marc Kleine-Budde <mkl@pengutronix.de>
> >Date: Sun, 21 Jun 2015 19:04:58 +0200
> >
> >>this is a, probably too late, pull request for v4.1.
> >>
> >>Oliver Hartkopp fixed a bug in the generic CAN frame handling code, which may
> >>lead to loss of CAN frames. It was introduced during v4.1 development.
> >>
> >>Please queue via net/master if possible, net-next/master otherwise. I've added
> >>stable on Cc, just in case.
> >
> >Pulled, thanks.
> 
> the patch "can: fix loss of CAN frames in raw_rcv" was sent to stable on
> 2015-06-21 but unfortunately did not find its way into 4.1.1 :-(
> 
> The upstream commit is:
> 
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=36c01245eb8046c16eee6431e7dbfbb302635fa8
> 
> which slipped into 4.2 at merge window opening time.
> 
> So it just got lost in the stable queue somehow.

No, it's still there.  I don't queue up patches for a stable release
until they have shown up in a public release from Linus.  So in this
case, it will be elgible to be in a stable kernel after 4.2-rc1 is out.

Unless you tell me otherwise, so if you want this in the next 4.1-stable
release, I can queue it up now.

thanks,

greg k-h
