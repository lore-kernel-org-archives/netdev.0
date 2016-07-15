From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 00/14] Present useful limits to user (v2)
Date: Fri, 15 Jul 2016 15:59:56 +0200
Message-ID: <20160715135956.GA3115@twins.programming.kicks-ass.net>
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
 <20160715124330.GR30154@twins.programming.kicks-ass.net>
 <28b4b919-4f50-d9f6-c5e1-d1e92ea1ba1c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
	Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>,
	Alexander Graf <agraf@suse.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim Kr??m???? <rkrcmar@redhat.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	"maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Christian Benvenuti <benve@cisco.com>,
	Dave Goodell <dgoodell@cisco.com>,
	Sudeep Dutt <sudeep.dutt@intel.com>,
	Ashutosh Dixit <a
To: Topi Miettinen <toiwoton@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <28b4b919-4f50-d9f6-c5e1-d1e92ea1ba1c@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 15, 2016 at 01:52:48PM +0000, Topi Miettinen wrote:
> On 07/15/16 12:43, Peter Zijlstra wrote:
> > On Fri, Jul 15, 2016 at 01:35:47PM +0300, Topi Miettinen wrote:
> >> Hello,
> >>
> >> There are many basic ways to control processes, including capabilities,
> >> cgroups and resource limits. However, there are far fewer ways to find out
> >> useful values for the limits, except blind trial and error.
> >>
> >> This patch series attempts to fix that by giving at least a nice starting
> >> point from the highwater mark values of the resources in question.
> >> I looked where each limit is checked and added a call to update the mark
> >> nearby.
> > 
> > And how is that useful? Setting things to the high watermark is
> > basically the same as not setting the limit at all.
> 
> What else would you use, too small limits?

That question doesn't make sense.

What's the point of setting a limit if it ends up being the same as
no-limit (aka unlimited).

If you cannot explain; and you have not so far; what use these values
are, why would we look at the patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
