From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH] [updated] PHY fixed driver: rework release path and
	update phy_id notation
Date: Fri, 20 Jul 2007 11:47:43 -0500
Message-ID: <20070720164743.GA9659@ld0162-tx32.am.freescale.net>
References: <20070718233804.24451.22543.stgit@localhost.localdomain>
	<20070719232337.184942e0.akpm@linux-foundation.org>
	<20070720115039.05f50f0f@localhost.localdomain>
	<20070720005702.b2b644e7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, linuxppc-dev@ozlabs.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20070720005702.b2b644e7.akpm@linux-foundation.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 20, 2007 at 12:57:02AM -0700, Andrew Morton wrote:
> On Fri, 20 Jul 2007 11:50:39 +0400 Vitaly Bordug <vitb@kernel.crashing.org> wrote:
> > On Thu, 19 Jul 2007 23:23:37 -0700
> > Andrew Morton wrote:
> > > Shouldn't these be runtime options (ie: module parameters)?
> > > 
> > I thought about it but this thing is more like the one that will never tend/required to change while\
> > configured.. Will add if you see it appropriate though.
> 
> 99% of users don't compile their own kernels: their vendor will have to
> make this decision for them, and it sounds like any decision which they
> make will be wrong for some of their users?

This is mostly of use on embedded hardware where the kernel will be
rebuilt by someone who knows the hardware...  That said, I don't see why
it needs to be configured at all.  Couldn't it use an idr table instead? 

-Scott
