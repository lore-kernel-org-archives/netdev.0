From: Peter Stuge <peter@stuge.se>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be
	misaligned
Date: Fri, 31 Jan 2014 14:21:46 +0100
Message-ID: <20140131132146.2833.qmail@stuge.se>
References: <20140130211816.GB3787@xanatos> <063D6719AE5E284EB5DD2968C1650D6D0F6B5B78@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Sarah Sharp' <sarah.a.sharp@linux.intel.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Dan Williams <dan.j.williams@intel.com>,
	"Nyman, Mathias" <mathias.nyman@intel.com>,
	Mark Lord <mlord@pobox.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Freddy Xin <freddy@asix.com.tw>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foo.stuge.se ([212.116.89.98]:53494 "EHLO foo.stuge.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932269AbaAaNVt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Jan 2014 08:21:49 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6B5B78@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Laight wrote:
> > We shouldn't need to make userspace start to worry about alignment at
> > all.  libusb worked in the past, before the link TRB fix went in.  We
> > *cannot* break userspace USB drivers.  The breakage needs to be fixed in
> > the USB core or the xHCI driver.
> 
> Userspace doesn't care since everything gets copied into aligned
> kernel fragments - otherwise the other usb controllers wouldn't work.

OK, but not so great if someone wants to squeeze the most performance
possible out of USB also from userspace.

I'm going off on a tangent now but would it make sense to allow
userspace to do alignment if it wants to, and have a way to tell
the kernel when urb buffers are pre-aligned?


//Peter
