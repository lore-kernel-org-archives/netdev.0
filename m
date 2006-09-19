From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.18-rc7-mm1: networking breakage on HPC nx6325 + SUSE 10.1
Date: Wed, 20 Sep 2006 00:56:57 +0200
Message-ID: <200609200056.57858.rjw@sisk.pl>
References: <20060919133606.f0c92e66.akpm@osdl.org> <20060919.150629.109607267.davem@davemloft.net> <20060919223015.GA23088@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akpm@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:53145 "EHLO ogre.sisk.pl")
	by vger.kernel.org with ESMTP id S1750715AbWISWxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 18:53:48 -0400
To: Greg KH <greg@kroah.com>
In-Reply-To: <20060919223015.GA23088@kroah.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, 20 September 2006 00:30, Greg KH wrote:
> On Tue, Sep 19, 2006 at 03:06:29PM -0700, David Miller wrote:
> > From: "Rafael J. Wysocki" <rjw@sisk.pl>
> > Date: Wed, 20 Sep 2006 00:06:52 +0200
> > 
> > > I _guess_ the problem is caused by
> > > gregkh-driver-network-class_device-to-device.patch, but I can't verify this,
> > > because the kernel (obviously) doesn't compile if I revert it.
> > 
> > Indeed.
> > 
> > I thought we threw this patch out because we knew it would cause
> > problems for existing systems?  I do remember Greg making an argument
> > as to why we needed the change, but that doesn't make breaking people's
> > systems legitimate in any way.
> 
> It's now thrown out, and I think Andrew already had a patch in his tree
> that reverted this.
> 
> I'll be bringing it back eventually, but first we are going to work out
> all the kinks by probably putting these changes in the next few SuSE
> alpha releases to see what shakes out in userspace that we need to go
> fix.
> 
> It's not 2.6.19 material at all, so don't worry :)

Please note, however, that by including such changes in -mm we make _other_
things be not tested.

For example, if I can't install a new kernel and use it on my system without
replacing some other pieces of software, I just won't be using it, because I
have no time for playing with udev, hal, powersaved, acpid, ...
Then, if there are any bugs in it that would have shown up on my system,
we won't know about them unless they show up on someone else's system,
which may not happen.

The more changes that break existing setups are there in -mm, the less
people will acutally try to use -mm kernels and that will result in buggier
-rc kernels and more bugs propagating to the "stable" ones.  Do we really
want that to happen?

Rafael


-- 
You never change things by fighting the existing reality.
		R. Buckminster Fuller
