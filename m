From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: virtio_net: MAC address releated breakage if there is no MAC area in config
Date: Sun, 5 Apr 2009 14:11:07 +1030
Message-ID: <200904051311.08114.rusty@rustcorp.com.au>
References: <200904021333.25119.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alex Williamson <alex.williamson@hp.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38416 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756845AbZDEDlS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Apr 2009 23:41:18 -0400
In-Reply-To: <200904021333.25119.borntraeger@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 02 April 2009 22:03:24 Christian Borntraeger wrote:
> I read this as the mac config field is optional (similar to all the optional
> fields we added in virtio_blk later).
> 
> I see two options:
> 1. Change our sample userspace to always allocate the config (like lguest and
> qemu)
> 2. Change the kernel code to not write into the config unless a specific feature
> bit is set. (e.g. VIRTIO_NET_F_SETMAC)

I had assumed it would always exist.  Agreed it's unclear; I'm currently
writing down the actual standard to avoid such mistakes in the future.

Cheers,
Rusty.
