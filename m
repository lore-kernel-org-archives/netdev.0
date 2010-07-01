From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH repost] sched: export sched_set/getaffinity to modules
Date: Thu, 01 Jul 2010 13:43:23 +0200
Message-ID: <1277984603.1917.15.camel@laptop>
References: <4BFEA434.6080405@kernel.org>
	 <20100527173207.GA21880@redhat.com> <4BFEE216.2070807@kernel.org>
	 <20100528150830.GB21880@redhat.com> <4BFFE742.2060205@kernel.org>
	 <20100530112925.GB27611@redhat.com> <4C02C99D.9070204@kernel.org>
	 <20100624081135.GA937@redhat.com>
	 <1277419551.27868.27.camel@w-sridhar.beaverton.ibm.com>
	 <20100625101022.GA16321@redhat.com>  <20100701110708.GA27368@redhat.com>
	 <1277983179.1917.10.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Ingo Molnar <mingo@elte.hu>, Sridhar Samudrala <sri@us.ibm.com>,
	Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andi Kleen <ak@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1277983179.1917.10.camel@laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-07-01 at 13:19 +0200, Peter Zijlstra wrote:
> On Thu, 2010-07-01 at 14:07 +0300, Michael S. Tsirkin wrote:
> > Author: Sridhar Samudrala <sri@us.ibm.com>
> > 
> > sched: export sched_set/getaffinity to modules
> > 
> > vhost-net driver wants to copy the affinity from the
> > owner thread to thread it creates. Export
> > sched_set/get affinity to modules to make this possible
> > when vhost is built as a module.

> Urgh,.. so why again is that a good idea?

In particular:
 - who sets the affinity of the task? 
 - why can't it set the kernel thread's affinity too?
 - what happens if someone changes the tasks' affinity?

So no, I don't think this is a sensible thing to do at all.
