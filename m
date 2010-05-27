From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 2/3] workqueue: Add an API to create a singlethread
	workqueue attached to the current task's cgroup
Date: Thu, 27 May 2010 15:48:13 +0200
Message-ID: <20100527134812.GA8291@redhat.com>
References: <1274227491.2370.110.camel@w-sridhar.beaverton.ibm.com> <20100527091426.GA6308@redhat.com> <20100527124448.GA4241@redhat.com> <20100527131254.GB7974@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Tejun Heo <tj@kernel.org>, Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100527131254.GB7974@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/27, Michael S. Tsirkin wrote:
>
> On Thu, May 27, 2010 at 02:44:48PM +0200, Oleg Nesterov wrote:
> > On 05/27, Michael S. Tsirkin wrote:
> > >
> > > On Tue, May 18, 2010 at 05:04:51PM -0700, Sridhar Samudrala wrote:
> > > > Add a new kernel API to create a singlethread workqueue and attach it's
> > > > task to current task's cgroup and cpumask.
> > > >
> > > > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> > >
> > > Could someone familiar with workqueue code please comment on whether
> > > this patch is suitable for 2.6.35?
> > >
> > > It is needed to fix the case where vhost user might cause a kernel
> > > thread to consume more CPU than allowed by the cgroup.
> > > Should I merge it through the vhost tree?
> > > Ack for this?
> >
> > I don't understand the reasons for this patch, but this doesn't matter.
>
> Depending on userspace application, driver can create a lot of work
> for a workqueue to handle. By making the workqueue thread
> belong in a cgroup, we make it possible to the CPU and other
> resources thus consumed.

OK, I see, thanks for your explanation.


in case I wasn't clear... I didn't mean I dislike this idea, only the
the implementation of create_singlethread_workqueue_in_current_cg(),
it doesn't belong to workqueue.c imho.

Oleg.
