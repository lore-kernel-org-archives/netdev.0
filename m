From: Bernard Metzler <BMT@zurich.ibm.com>
Subject: Re: [PATCH 2/2] siw: Add support for CRC32C offload instruction	using
 libcrypto crc32c-intel
Date: Thu, 23 Sep 2010 17:31:23 +0200
Message-ID: <OF8F21A2C4.F0CC977E-ONC12577A7.0054E314-C12577A7.00554592@ch.ibm.com>
References: <1285194989.1849.130.camel@haakon2.linux-iscsi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-rdma <linux-rdma@vger.kernel.org>,
	linux-rdma-owner@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285194989.1849.130.camel@haakon2.linux-iscsi.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



linux-rdma-owner@vger.kernel.org wrote on 09/23/2010 12:36:29 AM:

> On Wed, 2010-09-22 at 16:06 -0600, Jason Gunthorpe wrote:
> > On Wed, Sep 22, 2010 at 02:38:31PM -0700, Nicholas A. Bellinger wrote:
> >
> > > So I think the main bit here is the ability to request
> > > crc32c-intel.ko first, and then fall back to crc32c.ko when the
> > > former is not available on CONFIG_X86.
> >
> > Well, it is what Andi said, everything is working fine but there is no
> > mechanism to autoload the accelerated crypto module. If you did
> > modprobe crc32c_intel prior to loading your driver it would
> > automatically get crc32c-intel when it asks for crc32c since it is
> > loaded and a higher priority.
> >
>
> Ah, OK.  I see what you mean now here wrt to libcrypto priorities and
> crc32c + crc32c_intel modules.   My apologies for the in-experience with
> libcrypto here..
>
> > So, the drivers are correct to just request crc32c .. The work around
> > to limited autoprobing is so trivial (modprob crc32_intel) I'm not
> > sure including extra autoprobing code in the drivers is worthwhile?
> >
>
> Indeed, I am happy to drop this patch if Bernard would be nice enough to
> add a 'modprobe crc32_intel' into the SIW scripts.
>

Ok, thanks for the CRC comments, quite instructive.  To sum up, now I'll
add
a minimum siw bringup script to the kernel part.

Bernard
