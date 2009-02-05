From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: Allow setting the MAC address of the NIC
Date: Wed, 04 Feb 2009 16:36:43 -0800 (PST)
Message-ID: <20090204.163643.25832936.davem@davemloft.net>
References: <200901271305.16832.rusty@rustcorp.com.au>
	<20090204191826.2481.17875.stgit@debian.lart>
	<200902051007.13042.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.williamson@hp.com, markmc@redhat.com, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <200902051007.13042.rusty@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 5 Feb 2009 10:07:12 +1030

> On Thursday 05 February 2009 05:56:06 Alex Williamson wrote:
> > Many physical NICs let the OS re-program the "hardware" MAC
> > address.  Virtual NICs should allow this too.
> > 
> > Signed-off-by: Alex Williamson <alex.williamson@hp.com>
> > Acked-by: Mark McLoughlin <markmc@redhat.com>
> > ---
> > 
> > Rusty, you've already applied this to your patch queue, but that version
> > won't apply cleanly after the MAC and VLAN filtering patches I just sent
> > for net-next-2.6 (just diff context changes).  This version should apply
> > cleanly, so either drop the original and apply this after rebase, or
> > maybe it should just go directly into net-next-2.6?  Thanks,
> 
> Yes, it should go directly into net-next-2.6.

Applied to net-next-2.6
