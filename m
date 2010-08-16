From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: Using virtio as a physical (wire-level) transport
Date: Mon, 16 Aug 2010 09:49:40 +0930
Message-ID: <201008160949.41348.rusty@rustcorp.com.au>
References: <20100804230441.GJ23951@ovro.caltech.edu> <20100806153427.GB12392@ovro.caltech.edu> <4C336074-FC8C-4BDF-B945-5295133CDB38@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alexander Graf <agraf@suse.de>,
	"Ira W. Snyder" <iws@ovro.caltech.edu>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Zang Roy <r61911@freescale.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: virtualization@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46082 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751219Ab0HPATr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Aug 2010 20:19:47 -0400
In-Reply-To: <4C336074-FC8C-4BDF-B945-5295133CDB38@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 14 Aug 2010 09:04:19 pm Alexander Graf wrote:
> 
> Am 06.08.2010 um 11:34 schrieb "Ira W. Snyder" <iws@ovro.caltech.edu>:
> > This problem is not limited to my new use of virtio. Virtio is
> > completely useless in a relatively common virtualization scenario:
> > x86 host with qemu-ppc guest. Or any other big endian guest system.
> 
> This one actually works because we know that we're building for a BE guest.
> But I agree that it's a mess and clearly a very incorrect design decision.

Yes, since you need to know the guest's endian to virtualize it, the
correct interpretation of the virtio ring seemed the least problem.  Perhaps
I went overboard in simplification here, but it seemed pure legacy.

If we did a virtio2, as has been suggested, it would be possible to address
this.  You could of course do a hack where you detect the ring endianness
the first time they use it (based on avail.flags, avail.index and the
descriptor it would be quite reliable in practice).

Cheers,
Rusty.
