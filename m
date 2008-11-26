From: Gleb Natapov <gleb@redhat.com>
Subject: Re: Host<->guest channel interface advice needed
Date: Wed, 26 Nov 2008 15:20:06 +0200
Message-ID: <20081126132006.GD3521@redhat.com>
References: <20081126123919.GC3521@redhat.com> <20081126130701.GB8921@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48896 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752413AbYKZNUO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2008 08:20:14 -0500
Content-Disposition: inline
In-Reply-To: <20081126130701.GB8921@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 26, 2008 at 04:07:01PM +0300, Evgeniy Polyakov wrote:
> On Wed, Nov 26, 2008 at 02:39:19PM +0200, Gleb Natapov (gleb@redhat.com) wrote:
> > The interfaces that are being considered are netlink socket (only datagram
> > semantics, linux specific), new socket family or character device with
> > different minor number for each channel. Which one better suits for
> > the purpose?  Is there other kind of interface to consider? New socket
> > family looks like a good choice, but it would be nice to hear other
> > opinions before starting to work on it.
> 
> What about X (or whatever else) protocol running over host-guest network
> device, which are in the kernel already?
> 
I should have mentioned that in my original mail. We don't want to
use IP stack for communication between host and guest for variety of
reasons. User of the VM may interfere with our communication by mis
configuring firewall for instance (and he/she may even not be aware
that an OS running inside a VM). We also want be able to communicate
with agent inside a guest even when guest's network is not yet configured.

--
			Gleb.
