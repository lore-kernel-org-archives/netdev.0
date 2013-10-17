From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Thu, 17 Oct 2013 11:48:07 -0700
Message-ID: <1382035687.2045.155.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381510298-20572-1-git-send-email-nhorman@tuxdriver.com>
	 <20131012172124.GA18241@gmail.com>
	 <20131014202854.GH26880@hmsreliant.think-freely.org>
	 <1381785560.2045.11.camel@edumazet-glaptop.roam.corp.google.com>
	 <1381789127.2045.22.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131017003421.GA31470@hmsreliant.think-freely.org>
	 <20131017084121.GC22705@gmail.com> <52602A29.506@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-kernel@vger.kernel.org, sebastien.dugue@bull.net,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, x86@kernel.org,
	netdev@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52602A29.506@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-10-17 at 11:19 -0700, H. Peter Anvin wrote:

> Seriously, though, how much does it matter?  All the above seems likely
> to do is to drown the signal by adding noise.

I don't think so.

> 
> If the parallel (threaded) checksumming is faster, which theory says it
> should and microbenchmarking confirms, how important are the
> macrobenchmarks?

Seriously, micro benchmarks are very misleading.

I spent time on this patch, and found no changes on real workloads.

I was excited first, then disappointed.

I hope we will find the real issue, as I really don't care of micro
benchmarks.
