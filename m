From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [2.6 patch] security/selinux/netlabel.c: fix double free
Date: Tue, 29 Jan 2008 00:35:40 +0200
Message-ID: <20080128223540.GN8767@does.not.exist>
References: <20080128220938.GH8767@does.not.exist> <200801281723.46273.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: James Morris <jmorris@namei.org>, sds@tycho.nsa.gov,
	eparis@parisplace.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:53380 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753574AbYA1WfP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2008 17:35:15 -0500
Content-Disposition: inline
In-Reply-To: <200801281723.46273.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 28, 2008 at 05:23:46PM -0500, Paul Moore wrote:
> On Monday 28 January 2008 5:09:38 pm Adrian Bunk wrote:
> > This patch fixes a double free (security_netlbl_sid_to_secattr()
> > already calls netlbl_secattr_destroy() when it returns !0) introduced
> > by commit 45c950e0f839fded922ebc0bfd59b1081cc71b70 and spotted by the
> > Coverity checker.
> 
> Hi Adrian,

Hi Paul,

> Thanks for finding this mistake, however, I'd rather see it fixed by 
> removing the netlbl_secattr_destroy() call in 
> security_netlbl_sid_to_secattr() as it really shouldn't be there 
> anymore.  We moved the matching _init() call into 
> selinux_netlbl_sock_setsid() and I'd like to see the _init() and 
> _destroy() calls done in the same function.  I can push a revised patch 
> for this if you would prefer, otherwise I'll be happy to ack an updated 
> version ...

doing the patch is trivial but you are able to write a better 
changelog for it - just push a revised patch.

> paul moore

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

