From: Eric Paris <eparis@redhat.com>
Subject: Re: LSPP kernels (was Re: [PATCH]: SAD sometimes has double SAs).
Date: Wed, 28 Mar 2007 12:49:00 -0400
Message-ID: <1175100540.13618.67.camel@localhost.localdomain>
References: <200703232258.l2NMwKqH016994@faith.austin.ibm.com>
	 <1174944899.17953.20.camel@localhost.localdomain>
	 <20070326.144843.72708308.davem@davemloft.net>
	 <1174957467.3085.461.camel@faith.austin.ibm.com>
	 <1175094915.3085.503.camel@faith.austin.ibm.com>
	 <Line.LNX.4.64.0703281213060.2266@d.namei>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Joy Latten <latten@austin.ibm.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Moore <paul.moore@hp.com>,
	Venkat Yekkirala <vyekkirala@trustedcs.com>,
	Steve G <linux_4ever@yahoo.com>,
	Stephen Smalley <sds@tycho.nsa.gov>, selinux@tycho.nsa.gov
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45981 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933140AbXC1Q4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 12:56:24 -0400
In-Reply-To: <Line.LNX.4.64.0703281213060.2266@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-03-28 at 12:20 -0400, James Morris wrote:
> On Wed, 28 Mar 2007, Joy Latten wrote:
> 
> > Eric, sorry as I know you already patched lspp kernel
> > for testing.
> 
> I think it'd be better to have the lspp kernel join the upstream workflow 
> process, rather than being a shortcut into RHEL.
> 
> Please consider creating an lspp git tree (based off Linus' tree), then 
> once patches there are tested and ready to submit upstream, post them here 
> or selinux-list, where they can be reviewed and applied to either my or 
> DaveM's git tree.
> 
> From there, they'll be picked up in -mm for even wider testing then be 
> merged into mainline as appropriate.  Then, they can be incorporated into 
> distro devel kernels when they update their kernels, or backported to 
> stable distro kernels as already reviewed & tested upstream patches.
> 
> If there are any objections, please respond.

It is definitely NOT a shortcut into RHEL.  Nor is this government cert
effort (LSPP) being driven primary on RHEL code.  Not a single patch
will go into RHEL until it is upstream or in a tree to go upstream.
That is a given.  All development is being done upstream and then being
ported back to RHEL.  The LSPP kernel she mentioned is at this time
merely a testing ground for patches which may not quite be upstream
ready or are upstream but aren't in RHEL proper yet.  As it stands now
the LSPP kernel is carrying 22 patches on top of RHEL 5 GA (which is
2.6.18 based)  of those let me give you a breakdown.

12 are network related.
10 of those are in Linus's kernel
1 is not yet in miller's tree but i would expect it soon
1 is going to likely be dropped according to this thread

10 remaining patches are audit patches.

There is already a viro/audit-current.git tree on kernel.org where these
should be appearing.  I could make this a little easier for the audit
tree maintainer and make my own tree which he could pull from and then
push to Linus but a tree which should hold all of these does exist.  All
of them have been sent to the linux-audit mailing list and have been
commented on there.

I don't want to give the impression that upstream is not coming first.
All the work is being done upstream either on netdev or linux-audit and
then I pull it back into this LSPP kernel she talked about so that
people interested primarily in the testing necessary to meet that
particular government standard have a neat tidy little prebuild rpm to
work with.  Eventually all of these will show up in RHEL, but not until
all of the patches i'm dealing with are upstream.

-Eric

