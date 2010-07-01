From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH repost] sched: export sched_set/getaffinity to modules
Date: Thu, 1 Jul 2010 16:33:26 +0200
Message-ID: <20100701143325.GA10090@redhat.com>
References: <20100625101022.GA16321@redhat.com> <20100701110708.GA27368@redhat.com> <1277983179.1917.10.camel@laptop> <1277984603.1917.15.camel@laptop> <20100701115507.GA31333@redhat.com> <20100701122340.GB31333@redhat.com> <1277987657.1917.32.camel@laptop> <1277988395.1917.47.camel@laptop> <20100701130816.GB32223@redhat.com> <1277991024.1917.108.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	Sridhar Samudrala <sri@us.ibm.com>, Tejun Heo <tj@kernel.org>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andi Kleen <ak@linux.intel.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44871 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756472Ab0GAOge (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jul 2010 10:36:34 -0400
Content-Disposition: inline
In-Reply-To: <1277991024.1917.108.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01, Peter Zijlstra wrote:
>
> On Thu, 2010-07-01 at 16:08 +0300, Michael S. Tsirkin wrote:
> > Maybe it makes sense to add kthread_clone (in addition to
> > kthread_create) that would do what you suggest?
> > If yes, any hints on an implementation?
>
> I think that's called kernel_thread() see
> kernel/kthread.c:create_kthread().

Well, strictly speaking kernel_thread() doesn't create the kernel thread.
Unless the caller is the kernel thread. And daemonize() is deprecated.
kernel_thread() just forks the CLONE_VM + flags child.

Oleg.

