From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH repost] sched: export sched_set/getaffinity to modules
Date: Fri, 02 Jul 2010 20:11:10 +0200
Message-ID: <1278094270.1917.288.camel@laptop>
References: <1277983179.1917.10.camel@laptop>
	 <1277984603.1917.15.camel@laptop> <20100701115507.GA31333@redhat.com>
	 <20100701122340.GB31333@redhat.com> <1277987657.1917.32.camel@laptop>
	 <1277988395.1917.47.camel@laptop> <20100701130816.GB32223@redhat.com>
	 <1277991024.1917.108.camel@laptop> <20100701133956.GD32223@redhat.com>
	 <4C2CA5C5.4040402@kernel.org> <20100701144624.GA11171@redhat.com>
	 <4C2CABF2.2020801@kernel.org> <1277996135.1917.198.camel@laptop>
	 <4C2E2987.9040702@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@elte.hu>,
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
In-Reply-To: <4C2E2987.9040702@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-07-02 at 11:01 -0700, Sridhar Samudrala wrote:
>  
>  Does  it (Tejun's kthread_clone() patch) also  inherit the 
> cgroup of the caller?

Of course, its a simple do_fork() which inherits everything just as you
would expect from a similar sys_clone()/sys_fork() call.
