From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH 2.6.20] kobject net ifindex + rename
Date: Wed, 28 Feb 2007 10:43:14 -0800
Message-ID: <20070228184314.GC6134@bougret.hpl.hp.com>
References: <20070228012741.GA3988@bougret.hpl.hp.com> <20070228153617.GA5670@suse.de>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux kernel mailing list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:63109 "EHLO madara.hpl.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932227AbXB1Sn3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 13:43:29 -0500
Content-Disposition: inline
In-Reply-To: <20070228153617.GA5670@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 28, 2007 at 07:36:17AM -0800, Greg KH wrote:
> On Tue, Feb 27, 2007 at 05:27:41PM -0800, Jean Tourrilhes wrote:
> > diff -u -p linux/drivers/base/class.j1.c linux/drivers/base/class.c
> > --- linux/drivers/base/class.j1.c	2007-02-26 18:38:10.000000000 -0800
> > +++ linux/drivers/base/class.c	2007-02-27 15:52:37.000000000 -0800
> > @@ -841,6 +841,8 @@ int class_device_rename(struct class_dev
> 
> This function is not in the 2.6.21-rc2 kernel, so you might want to
> rework this patch a bit :)

	It was a trial balloon to gather feedback. I will do.

> Also, it's userspace that causes the rename to happen, so it knows it
> did it, why should the kernel have to emit a message to tell userspace
> again what just happened?

	Username is not one big program, but a collection of program,
and one program does not know what another program do.
	In particular, udev does not know when people are using
iproute2 to rename interface and loose its marbles. We don't really
want to ban iproute2 or udev ;-)

> thanks,
> 
> greg k-h

	Have fun...

	Jean
