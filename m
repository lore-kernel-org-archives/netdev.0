From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/3] cgroups: Add an API to attach a task to current
	task's cgroup
Date: Thu, 27 May 2010 12:16:29 +0300
Message-ID: <20100527091629.GB6308@redhat.com>
References: <1274227488.2370.107.camel@w-sridhar.beaverton.ibm.com> <AANLkTinsrFoLVKDFM5pcKcL_6MvAzhR6IzbNmWKh3BDh@mail.gmail.com> <20100525165334.GA27307@redhat.com> <AANLkTilawCLv5_XlStsFdOdLh-dmlIR3aUTyrVS-JF_s@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <samudrala.sridhar@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	containers@lists.linux-foundation.org, lizf@cn.fujitsu.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Ben Blum <bblum@andrew.cmu.edu>,
	KAMEZAWA Hiroyuki <kamezawa.hioryu@jp.fujitsu.com>
To: Paul Menage <menage@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45429 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751946Ab0E0JVS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 May 2010 05:21:18 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTilawCLv5_XlStsFdOdLh-dmlIR3aUTyrVS-JF_s@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 25, 2010 at 11:34:12AM -0700, Paul Menage wrote:
> On Tue, May 25, 2010 at 9:53 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > On Thu, May 20, 2010 at 03:22:15PM -0700, Paul Menage wrote:
> >> On Tue, May 18, 2010 at 5:04 PM, Sridhar Samudrala
> >> <samudrala.sridhar@gmail.com> wrote:
> >> > Add a new kernel API to attach a task to current task's cgroup
> >> > in all the active hierarchies.
> >> >
> >> > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> >>
> >> Reviewed-by: Paul Menage <menage@google.com>
> >>
> >> It would be more efficient to just attach directly to current->cgroups
> >> rather than potentially creating/destroying one css_set for each
> >> hierarchy until we've completely converged on current->cgroups - but
> >> that would require a bunch of refactoring of the guts of
> >> cgroup_attach_task() to ensure that the right can_attach()/attach()
> >> callbacks are made. That doesn't really seem worthwhile right now for
> >> the initial use, that I imagine isn't going to be
> >> performance-sensitive.
> >>
> >> Paul
> >
> > Is this patch suitable for 2.6.35?
> 
> Should be OK, yes.
> 
> Paul

So I'll add your Acked-by tag then, and merge through the vhost tree
together with the patch that uses this.

-- 
MST
