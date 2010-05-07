From: Greg KH <greg@kroah.com>
Subject: Re: [stable]  ixgbe: Fix return of invalid txq
Date: Fri, 7 May 2010 15:25:59 -0700
Message-ID: <20100507222559.GE26579@kroah.com>
References: <alpine.WNT.2.00.1005031333200.4376@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, brandon@ifup.org,
	David Miller <davem@davemloft.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:60539 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752679Ab0EGWjm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 May 2010 18:39:42 -0400
Content-Disposition: inline
In-Reply-To: <alpine.WNT.2.00.1005031333200.4376@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 03, 2010 at 01:56:57PM -0700, Brandeburg, Jesse wrote:
> Please consider commit fdd3d631cddad20ad9d3e1eb7dbf26825a8a121f for 
> inclusion in 2.6.32.y (it is already in 2.6.33.y)
> 
> Here is the commit message, it fixes a panic on machines with a larger 
> number of cpus than ixgbe has tx queues (64).
> 
> commit fdd3d631cddad20ad9d3e1eb7dbf26825a8a121f

This doesn't apply at all on the .32-stable tree, as the logic has
changed there.  Care to properly backport it if you really need it
there?

thanks,

greg k-h
