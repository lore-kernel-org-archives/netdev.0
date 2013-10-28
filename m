From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Mon, 28 Oct 2013 10:49:37 -0600
Message-ID: <526E95A1.7080701@gmail.com>
References: <1381510298-20572-1-git-send-email-nhorman@tuxdriver.com> <20131012172124.GA18241@gmail.com> <20131014202854.GH26880@hmsreliant.think-freely.org> <1381785560.2045.11.camel@edumazet-glaptop.roam.corp.google.com> <1381789127.2045.22.camel@edumazet-glaptop.roam.corp.google.com> <20131017003421.GA31470@hmsreliant.think-freely.org> <20131017084121.GC22705@gmail.com> <20131028160131.GA31048@hmsreliant.think-freely.org> <20131028162438.GB14350@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, sebastien.dugue@bull.net,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>, Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131028162438.GB14350@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/28/13 10:24 AM, Ingo Molnar wrote:

> The most accurate method of measurement for such single-threaded
> workloads is something like:
>
> 	taskset 0x1 perf stat -a -C 1 --repeat 20 ...
>
> this will bind your workload to CPU#0, and will do PMU measurements
> only there - without mixing in other CPUs or workloads.

you can drop the -a if you only want a specific CPU (-C arg). And -C in 
perf is cpu number starting with 0, so in your example above -C 1 means 
cpu1, not cpu0.

David
