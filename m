From: Greg KH <greg@kroah.com>
Subject: Re: Problem with non aligned DMA in usbnet on ARM
Date: Wed, 11 Aug 2010 08:04:43 -0700
Message-ID: <20100811150443.GB8867@kroah.com>
References: <AANLkTi=ycg=adcizNWKMCb7EdfDANM=6Es7r_gF1LbhV@mail.gmail.com>
 <20100811095454.GA22543@n2100.arm.linux.org.uk>
 <AANLkTimX46QKAGhiyo8AodaXVjuzoxr5-5z2V4gRr1Vu@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	linux-usb <linux-usb@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Martin Fuzzey <mfuzzey@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:44614 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753531Ab0HKPEv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Aug 2010 11:04:51 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTimX46QKAGhiyo8AodaXVjuzoxr5-5z2V4gRr1Vu@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 11, 2010 at 12:11:52PM +0200, Martin Fuzzey wrote:
> > You haven't said what HCD you're using.
> >
> imx21_hcd  (submitted by me and mainlined in 2.6.34)
> 
> > In that case, I'd say the HCD must handle misaligned URBs itself so
> > behaviour is consistent between all implementations on different
> > platforms.
> >
> Here is a pointer to the thread where it was stated that HCD's don't
> have to handle this.
> 
> http://kerneltrap.org/mailarchive/linux-usb/2009/4/20/5528164

No, that thread is about stack vs. heap allocations, not about alignment
issues.

thanks,

greg k-h
