From: Joe Perches <joe@perches.com>
Subject: Re: [patch] checkpatch: remove the ether_addr_copy warning
Date: Fri, 03 Oct 2014 08:10:28 -0700
Message-ID: <1412349028.3247.113.camel@joe-AO725>
References: <20141003093505.GA7393@mwanda>
	 <1412346147.3247.97.camel@joe-AO725>
	 <alpine.DEB.2.10.1410031628420.2371@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	Andy Whitcroft <apw@canonical.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	gregkh@linuxfoundation.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1410031628420.2371@hadrien>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-10-03 at 16:30 +0200, Julia Lawall wrote:
> On Fri, 3 Oct 2014, Joe Perches wrote:
> > On Fri, 2014-10-03 at 12:35 +0300, Dan Carpenter wrote:
> > > Most people sending checkpatch.pl fixes don't know how to verify the
> > > alignment.  This checkpatch warning just encourages newbies to try
> > > introduce bugs.  Patch submitters tell us that they just sed the code
> > > and it's the job for the maintainer to check that it's correct.
> >
> > I haven't seen many instances of bad patch submittals
> > on netdev.  Is this mostly an issue for staging?
> >
> > Maybe a downgrade to CHK requiring --strict is OK.
[]
> I think it is too bad to have a piece of knowledge that was apparent be
> made more obscure.  Why not just change the checkpatch warning to make
> more explicit that a lot of expertise is required to make the change?

Any wordsmithing appreciated.  Maybe something like:

from: Prefer ether_addr_copy() over memcpy() if the Ethernet addresses are __aligned(2)
to: Where both Ethernet addresses are guaranteed to be __aligned(2), prefer ether_addr_copy() over memcpy() 

That won't stop people from blindly following any message.



