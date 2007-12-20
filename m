From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] One more XFRM audit fix
Date: Thu, 20 Dec 2007 07:25:03 -0500
Message-ID: <200712200725.03888.paul.moore@hp.com>
References: <20071219192309.15561.9843.stgit@flek.americas.hpqcorp.net> <20071220.000009.173158004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:27836 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758050AbXLTMZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 07:25:16 -0500
In-Reply-To: <20071220.000009.173158004.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 20 December 2007 3:00:09 am David Miller wrote:
> From: Paul Moore <paul.moore@hp.com>
> Date: Wed, 19 Dec 2007 14:29:31 -0500
>
> > The following patch is backed against David's net-2.6 tree and is pretty
> > trivial.  I know we're late in the 2.6.24 cycle but I think this is worth
> > merging, if you guys don't feel that way let me know and I'll resubmit it
> > for 2.6.25.
>
> Where is that patch?  Or do you mean the fix you emailed
> seperately today (which I will apply, thanks)?

Yes, it was the patch you applied, "XFRM: Audit function arguments 
misordered".  I was using stacked-git to post the patch and it apparently 
doesn't annotate the cover email's subject line with "0/1" when you only send 
one patch.

Sorry about that.

> > As a side note, I'm unable to actually test the patch because I can't get
> > the kernel to compile (M=net/xfrm works just fine).  The problem I keep
> > seeing is below:
> >
> > make[3]: *** No rule to make target \
> >  `/blah/kernels/net-2.6_xfrm-auid-secid-fix/include/linux/ticable.h', \
> >   needed by \
> >  `/blah/kernels/net-2.6_xfrm-auid-secid-fix/usr/include/linux/ticable.h'.
> > \ Stop.
>
> Remove ticable.h from include/linux/Kbuild
>
> This is already cured in Linus's tree.

Noted, thanks.

-- 
paul moore
linux security @ hp
