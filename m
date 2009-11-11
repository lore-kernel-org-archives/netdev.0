From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: [PATCH] add HAVE_UNREGISTER_NETDEV_QUEUE define for out-of-tree modules
Date: Wed, 11 Nov 2009 14:49:16 -0500
Message-ID: <20091111194916.GB21704@kvack.org>
References: <20091110220004.GT21704@kvack.org> <20091111.112457.54237892.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:46845 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758672AbZKKTtL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 14:49:11 -0500
Content-Disposition: inline
In-Reply-To: <20091111.112457.54237892.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 11, 2009 at 11:24:57AM -0800, David Miller wrote:
> From: Benjamin LaHaise <bcrl@lhnet.ca>
> Date: Tue, 10 Nov 2009 17:00:04 -0500
> 
> > I have an out of tree network driver (GPL'd) that would like to make use of 
> > the unregister_netdevice_queue interface for bulk unregister of devices.  
> > Add a #define HAVE_UNREGISTER_NETDEV_QUEUE to allow the source to detect 
> > that the kernel supports this.
> 
> Please get your code upstream :-)

It's a completely separate PPP & L2TP / PPPoE from the existing code that 
is in tree.  Somehow, I don't think people are interested in merging duplicate 
functionality regardless of what differences there are in the interfaces.

> We're already overcluttered with these "HAVE_PANTS", "HAVE_JACKET",
> "HAVE_KITCHEN", "HAVE_SINK" ugly defines spewed all over netdevice.h,
> and I'm not adding any more of that.

If there was some other way of detecting that the interface is present, 
I'd use it, but there isn't.

		-ben
