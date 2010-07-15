From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH repost] sched: export sched_set/getaffinity to modules
Date: Thu, 15 Jul 2010 02:05:07 +0200
Message-ID: <20100715000506.GB27258@redhat.com>
References: <20100701144624.GA11171@redhat.com> <4C2CABF2.2020801@kernel.org> <1277996135.1917.198.camel@laptop> <4C2E2987.9040702@us.ibm.com> <1278094270.1917.288.camel@laptop> <20100702210637.GA12433@redhat.com> <20100704090005.GA8078@redhat.com> <4C3C0EBC.40305@us.ibm.com> <20100713110939.GA3446@redhat.com> <1279149996.32374.5.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andi Kleen <ak@linux.intel.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1279149996.32374.5.camel@w-sridhar.beaverton.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/14, Sridhar Samudrala wrote:
>
> OK. So we want to create a thread that is a child of kthreadd, but inherits the cgroup/cpumask
> from the caller. How about an exported kthread function kthread_create_in_current_cg()
> that does this?

Well. I must admit, this looks a bit strange to me ;)

Instead of exporting sched_xxxaffinity() we export the new function
which calls them. And I don't think this new helper is very useful
in general. May be I am wrong...

Oleg.
