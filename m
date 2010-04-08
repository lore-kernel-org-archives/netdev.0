From: John Linn <John.Linn@xilinx.com>
Subject: RE: linux-next: build failure after merge of the final tree
Date: Thu, 8 Apr 2010 17:01:03 -0600
Message-ID: <afd3df96-2991-49f2-aa74-138ce67b8103@SG2EHSMHS003.ehs.local>
References: <20100408153505.eb205158.sfr@canb.auug.org.au><20100407.232500.184442638.davem@davemloft.net><6125d80a-81d5-4699-ac6e-9408bd0c1145@SG2EHSMHS010.ehs.local> <20100409085918.cc984fb1.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jtyner@cs.ucr.edu>, <grant.likely@secretlab.ca>
To: "Stephen Rothwell" <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Class: urn:content-classes:message
In-Reply-To: <20100409085918.cc984fb1.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Stephen Rothwell [mailto:sfr@canb.auug.org.au]
> Sent: Thursday, April 08, 2010 4:59 PM
> To: John Linn
> Cc: David Miller; netdev@vger.kernel.org; linux-next@vger.kernel.org;
linux-kernel@vger.kernel.org;
> jtyner@cs.ucr.edu; grant.likely@secretlab.ca
> Subject: Re: linux-next: build failure after merge of the final tree
> 
> Hi John,
> 
> On Thu, 8 Apr 2010 08:15:12 -0600 John Linn <John.Linn@xilinx.com>
wrote:
> >
> > I'm not pushing back here, just trying to make sure I understand and
> > do it better next time :)
> >
> > I don't see that my patch has touched that part of the driver as
that
> > call was already in the driver before my patch (but maybe I'm just
> > missing it).
> >
> > My patch did change the dependency in the Kconfig so that it only
> > depends on powerpc rather than powerpc DCR and maybe that exposed
> > something that wasn't previously exposed.
> 
> Yeah, virt_to_bus() is only defined on 32bit PowerPC, not 64 bit.
> 
> CONFIG_PPC is set for both 32 and 64 bit PowerPC builds.
> --

Thanks for confirming that.  Spun a new patch (set) to hopefully take
care of that.

-- John

> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
> http://www.canb.auug.org.au/~sfr/

This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.
