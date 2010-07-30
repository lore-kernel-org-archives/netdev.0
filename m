From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH repost] sched: export sched_set/getaffinity to modules
Date: Fri, 30 Jul 2010 16:31:11 +0200
Message-ID: <4C52E22F.9060102@kernel.org>
References: <20100701144624.GA11171@redhat.com> <4C2CABF2.2020801@kernel.org> <1277996135.1917.198.camel@laptop> <4C2E2987.9040702@us.ibm.com> <1278094270.1917.288.camel@laptop> <20100702210637.GA12433@redhat.com> <20100726171230.GA27644@redhat.com> <1280166688.3375.5.camel@localhost> <20100726180834.GA26988@redhat.com> <20100727154155.GA13419@redhat.com> <20100730141901.GA9076@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andi Kleen <ak@linux.intel.com>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100730141901.GA9076@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 07/30/2010 04:19 PM, Oleg Nesterov wrote:
> But I must admit, I personally dislike this idea. A kernel thread which
> is the child of the user-space process, and in fact it is not the "real"
> kernel thread. I think this is against the common case. If you do not
> care the signals/reparenting, why can't you fork the user-space process
> which does all the work via ioctl's ? OK, I do not understand the problem
> domain, probably this can't work.

Having kernel threads which are children of user process is plain
scary considering the many things parent/children relationship implies
and various bugs and security vulnerabilities in the area.  I can't
pinpoint any problem but I think we really shouldn't be adding
something like this for this specific use case.  If we can get away
with exporting a few symbols, let's go that way.

Thanks.

-- 
tejun
