From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [patch] checkpatch: remove the ether_addr_copy warning
Date: Fri, 3 Oct 2014 16:30:00 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1410031628420.2371@hadrien>
References: <20141003093505.GA7393@mwanda> <1412346147.3247.97.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	Andy Whitcroft <apw@canonical.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	gregkh@linuxfoundation.org
To: Joe Perches <joe@perches.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1412346147.3247.97.camel@joe-AO725>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 3 Oct 2014, Joe Perches wrote:

> On Fri, 2014-10-03 at 12:35 +0300, Dan Carpenter wrote:
> > Most people sending checkpatch.pl fixes don't know how to verify the
> > alignment.  This checkpatch warning just encourages newbies to try
> > introduce bugs.  Patch submitters tell us that they just sed the code
> > and it's the job for the maintainer to check that it's correct.
>
> I haven't seen many instances of bad patch submittals
> on netdev.  Is this mostly an issue for staging?
>
> Maybe a downgrade to CHK requiring --strict is OK.
>
> > If you want to work on these then you can get the same information by
> > typing `grep -nw memcpy drivers/net/ -R | grep ETH_ALEN`
>
> That's not much of an argument for or against anything in
> checkpatch as every operation done by it can be reproduced
> by a series of grep operations.

I think it is too bad to have a piece of knowledge that was apparent be
made more obscure.  Why not just change the checkpatch warning to make
more explicit that a lot of expertise is required to make the change?

julia
