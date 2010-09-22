From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH 2/2] siw: Add support for CRC32C offload instruction
	using libcrypto crc32c-intel
Date: Wed, 22 Sep 2010 14:59:43 -0600
Message-ID: <20100922205943.GI11157@obsidianresearch.com>
References: <1285187425-10950-1-git-send-email-nab@linux-iscsi.org> <4C9A698B.90806@linux.intel.com> <1285187901.1849.85.camel@haakon2.linux-iscsi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Matthew Wilcox <willy-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
To: "Nicholas A. Bellinger" <nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1285187901.1849.85.camel-Y1+j5t8j3WgjMeEPmliV8E/sVC8ogwMJ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 22, 2010 at 01:38:21PM -0700, Nicholas A. Bellinger wrote:

> Indeed, this would clean up the explict RX/TX CRC32C case quite a
> bit..  Unfortuately I am too busy with other items atm to cook up
> this patch, but I would be happy to test it if someone wants to take
> it.  ;)

Do you even need to do anything at all? crc32c is provided by
crc32c-intel at a higher priority already, so it should be used if it
is available..
 
> > Need CPUID module auto probing. I have an older patch that needs
> > some fixes.

> Hmm, I don't see how that fits in here exactly.  Would you mind
> elaborating a bit..?

Unless the module is loaded the optimized algorithm will not be
available for automatic use. Maybe your patch causes it to autoload
because of the by-name reference? Identifying modules to load by CPUID
will let userspace auto load the appropriate ones based on CPU...

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
