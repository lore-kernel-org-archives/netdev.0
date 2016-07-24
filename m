From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v4 1/2] bpf: Add bpf_probe_write BPF helper to be called
 in tracers (kprobes)
Date: Sat, 23 Jul 2016 18:19:05 -0700
Message-ID: <20160724011904.GC33568@ast-mbp.thefacebook.com>
References: <20160722010915.GA22992@ircssh.c.rugged-nimbus-611.internal>
 <20160722021454.GA135@ast-mbp.thefacebook.com>
 <5791ED30.3000409@iogearbox.net>
 <20160723000526.GA11650@ircssh.c.rugged-nimbus-611.internal>
 <20160723193510.GA23128@ast-mbp>
 <20160724003941.GA31582@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160724003941.GA31582@ircssh.c.rugged-nimbus-611.internal>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 23, 2016 at 05:39:42PM -0700, Sargun Dhillon wrote:
> The example has been modified to act like a test in the follow up set. It tests 
> for the positive case (Did the helper work or not) as opposed to the negative 
> case (is the helper able to violate the safety constraints we set forth)? I 
> could do that as well, in another patch by mprotecting those pages, or some 
> such. Should I add an additional negative test?

That would be awesome, but doesn't have to be in this patch set.
It can be done as a follow up.

Thanks!
