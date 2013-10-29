From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Tue, 29 Oct 2013 14:11:49 +0100
Message-ID: <20131029131149.GB20408@gmail.com>
References: <20131028160131.GA31048@hmsreliant.think-freely.org>
 <20131028162438.GB14350@gmail.com>
 <20131028174630.GB31048@hmsreliant.think-freely.org>
 <20131028182913.GD31048@hmsreliant.think-freely.org>
 <20131029082542.GA24625@gmail.com>
 <20131029112022.GA24477@neilslaptop.think-freely.org>
 <20131029113031.GA16897@gmail.com>
 <20131029114907.GE24477@neilslaptop.think-freely.org>
 <20131029125233.GA17449@gmail.com>
 <20131029130712.GA25078@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, sebastien.dugue@bull.net,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131029130712.GA25078@neilslaptop.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Neil Horman <nhorman@tuxdriver.com> wrote:

> I'm sure it worked properly on my system here, I specificially 
> checked it, but I'll gladly run it again.  You have to give me an 
> hour as I have a meeting to run to, but I'll have results shortly.

So what I tried to react to was this observation of yours:

> > > Heres my data for running the same test with taskset 
> > > restricting execution to only cpu0.  I'm not quite sure whats 
> > > going on here, but doing so resulted in a 10x slowdown of the 
> > > runtime of each iteration which I can't explain. [...]

A 10x slowdown would be consistent with not running your testcase 
but 'perf bench sched messaging' by accident, or so.

But I was really just guessing wildly here.

Thanks,

	Ingo
