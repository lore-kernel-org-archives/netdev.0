From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: Allow setting the MAC address of the NIC
Date: Thu, 5 Feb 2009 10:07:12 +1030
Message-ID: <200902051007.13042.rusty@rustcorp.com.au>
References: <200901271305.16832.rusty@rustcorp.com.au> <20090204191826.2481.17875.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090204191826.2481.17875.stgit@debian.lart>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 05 February 2009 05:56:06 Alex Williamson wrote:
> Many physical NICs let the OS re-program the "hardware" MAC
> address.  Virtual NICs should allow this too.
> 
> Signed-off-by: Alex Williamson <alex.williamson@hp.com>
> Acked-by: Mark McLoughlin <markmc@redhat.com>
> ---
> 
> Rusty, you've already applied this to your patch queue, but that version
> won't apply cleanly after the MAC and VLAN filtering patches I just sent
> for net-next-2.6 (just diff context changes).  This version should apply
> cleanly, so either drop the original and apply this after rebase, or
> maybe it should just go directly into net-next-2.6?  Thanks,

Yes, it should go directly into net-next-2.6.

I like to keep some variant in my tree so I can see when they go upstream
(and ideally notice if they haven't for some reason).

Thanks,
Rusty.
