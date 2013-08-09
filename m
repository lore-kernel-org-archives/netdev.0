From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v4 0/4] USB & USBNET: loose SG check and support usbnet
 DMA SG
Date: Fri, 9 Aug 2013 14:13:23 -0700
Message-ID: <20130809211323.GA20120@kroah.com>
References: <1375969705-24877-1-git-send-email-ming.lei@canonical.com>
 <20130809.141217.555889385998745188.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ming.lei@canonical.com, oneukum@suse.de,
	sarah.a.sharp@linux.intel.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:37348 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031149Ab3HIVNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 17:13:24 -0400
Content-Disposition: inline
In-Reply-To: <20130809.141217.555889385998745188.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 09, 2013 at 02:12:17PM -0700, David Miller wrote:
> From: Ming Lei <ming.lei@canonical.com>
> Date: Thu,  8 Aug 2013 21:48:21 +0800
> 
> > This patchset allows drivers to pass sg buffers which size can't be divided
> > by max packet size of endpoint if the host controllers(such ax xHCI) support
> > this kind of sg buffers.
> > 
> > Previously we added check[1] on the situation and don't allow these sg buffers
> > passed to USB HCD, looks the check is too strict to make use of new feature of
> > new hardware(xHCI) for some applications(such as network stack) which can't
> > provide this kind of sg buffers to usbnet driver, so the patch looses the check
> > in case that the host controller supports it.
> > 
> > Patch 3/4 implements DMA SG on usbnet driver, and patch 4/4 uses it on ax88179_178a
> > USB3 NIC for supporting TSO, so both CPU utilization and tx throughput can be
> > improved with TSO and DMA SG in case of the USB NIC is attached to xHCI controller.
> > 
> > This patchset depends on both net-next and usb-next tree, so hope David and Greg
> > to figure out one elegent way to merge it.
> 
> Greg feel free to merge this in via your USB tree with my:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Thanks, will do.

greg k-h
