From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [2.6 patch] forgotten bits of Sangoma drivers removal
Date: Tue, 1 Apr 2008 10:50:58 +0300
Message-ID: <20080401075058.GF23259@cs181133002.pp.htv.fi>
References: <20080330224901.GW28445@cs181133002.pp.htv.fi> <20080331.193329.195976331.davem@davemloft.net> <alpine.LFD.1.00.0803312313210.21490@localhost.localdomain> <20080331.201702.119420148.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: rpjday@crashcourse.ca, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:43934 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753253AbYDAHvB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2008 03:51:01 -0400
Content-Disposition: inline
In-Reply-To: <20080331.201702.119420148.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 31, 2008 at 08:17:02PM -0700, David Miller wrote:
> From: "Robert P. J. Day" <rpjday@crashcourse.ca>
> Date: Mon, 31 Mar 2008 23:14:46 -0400 (EDT)
> 
> > On Mon, 31 Mar 2008, David Miller wrote:
> > 
> > > From: Adrian Bunk <bunk@kernel.org>
> > > Date: Mon, 31 Mar 2008 01:49:01 +0300
> > >
> > > > Robert P. J. Day spotted that my removal of the Sangoma drivers missed a
> > > > few bits.
> > > >
> > > > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> > >
> > > I must have missed some context or another patch, but
> > > linux/if_wanpipe.h is still there, so I can't see why
> > > we can remove it from linux/Kbuild
> > 
> > AFAICT, nothing in the source tree includes that header file, so i'm
> > guessing that the patch should also include simply deleting it if it
> > has no further value.
> 
> Ok, that makes sense.
> 
> Adrian, if you agree, please respin your patch with that
> modification.

My patch already removes include/linux/if_wanpipe.h

> Thanks.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

