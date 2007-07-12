From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [2.6.23 PATCH 13/18] dm: netlink
Date: Thu, 12 Jul 2007 16:31:15 -0700
Message-ID: <20070712163115.ee686f8d.akpm@linux-foundation.org>
References: <20070711210137.GE24114@agk.fab.redhat.com>
	<20070711142712.e646995b.akpm@linux-foundation.org>
	<20070712231920.GZ11166@waste.org>
Reply-To: device-mapper development <dm-devel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mike Anderson <andmike@us.ibm.com>, netdev@vger.kernel.org,
	dm-devel@redhat.com, linux-kernel@vger.kernel.org,
	Alasdair G Kergon <agk@redhat.com>
To: Matt Mackall <mpm@selenic.com>
Return-path: <dm-devel-bounces@redhat.com>
In-Reply-To: <20070712231920.GZ11166@waste.org>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/dm-devel>
List-Post: <mailto:dm-devel@redhat.com>
List-Help: <mailto:dm-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=subscribe>
Sender: dm-devel-bounces@redhat.com
Errors-To: dm-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Thu, 12 Jul 2007 18:19:20 -0500
Matt Mackall <mpm@selenic.com> wrote:

> On Wed, Jul 11, 2007 at 02:27:12PM -0700, Andrew Morton wrote:
> > On Wed, 11 Jul 2007 22:01:37 +0100
> > Alasdair G Kergon <agk@redhat.com> wrote:
> > 
> > > From: Mike Anderson <andmike@us.ibm.com>
> > > 
> > > This patch adds a dm-netlink skeleton support to the Makefile, and the dm
> > > directory.
> > > 
> > > ...
> > >  
> > > +config DM_NETLINK
> > > +	bool "DM netlink events (EXPERIMENTAL)"
> > > +	depends on BLK_DEV_DM && EXPERIMENTAL
> > > +	---help---
> > > +	Generate netlink events for DM events.
> > 
> > Need a dependency on NET there?
> 
> It's really sad to make DM dependent on the network layer.
> 

Yes, it would be somewhat sad.  However one can presumably continue to use
DM, just without "DM netlink events".

But that probably means that one will not be able to use the standard DM
admin tools without networking.  Maybe there will remain alternative but
cruder ways to get things done?
