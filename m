From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] try parent numa_node at first before using default
Date: Thu, 12 Jul 2007 20:16:22 -0700
Message-ID: <20070713031622.GC2395@kroah.com>
References: <200707101641.17672.yinghai.lu@sun.com> <469610D4.70009@s5r6.in-berlin.de> <20070712172310.4d662e1f@gondolin.boeblingen.de.ibm.com> <200707121059.54320.yinghai.lu@sun.com> <20070712183141.GB22471@kroah.com> <86802c440707121206i3186fe9chba55fe2e5e5e4c5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andi Kleen <ak@suse.de>, rientjes@google.com,
	Christoph Lameter <clameter@sgi.com>,
	Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([209.217.80.40]:59589 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757419AbXGMDP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 23:15:27 -0400
Content-Disposition: inline
In-Reply-To: <86802c440707121206i3186fe9chba55fe2e5e5e4c5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 12, 2007 at 12:06:00PM -0700, Yinghai Lu wrote:
>  On 7/12/07, Greg KH <greg@kroah.com> wrote:
> > On Thu, Jul 12, 2007 at 10:59:53AM -0700, Yinghai Lu wrote:
> > Please split this into two separate patches, as they are doing two
> > different things.  One for the driver core, and one for pci devices.
> 
>  they need to applied together, otherwise all pci_dev numa_node will be
>  change to device_add to -1 after pci_device_add.

Hm, good point.

> > Also, what kind of performance issues have you seen with this patch in
> > place?  As your previous patches were incorrect, I am guessing that you
> > are not able to test this?
>  forcedeth on second node. without this patch in addition to
>  get_mpbus_to_node patch, the numa_node is always 0.

But you were not able to test USB, right?  Does that work properly now
with this patch?

thanks,

greg k-h
