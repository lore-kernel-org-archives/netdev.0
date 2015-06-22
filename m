From: Daniel Wagner <daniel.wagner@bmw-carit.de>
Subject: Re: [PATCH v2] bpf: BPF based latency tracing
Date: Mon, 22 Jun 2015 09:34:18 +0200
Message-ID: <5587BA7A.6050208@bmw-carit.de>
References: <1434722444-10200-1-git-send-email-daniel.wagner@bmw-carit.de> <558520DB.6000904@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <558520DB.6000904@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/20/2015 10:14 AM, Daniel Borkmann wrote:
> I think it would be useful to perhaps have two options:
> 
> 1) User specifies a specific CPU and gets one such an output above.

Good point. Will do.

> 2) Summary view, i.e. to have the samples of each CPU for comparison
>    next to each other in columns and maybe the histogram view a bit
>    more compressed (perhaps summary of all CPUs).

I agree, the current view is not really optimal. I'll look into this as
well.

Alexei indicated that he is working on per-cpu variables support. I
think that would be extremely useful to drop the hard coded limit of
CPUs and turning this sample code into some more generic code.

> Anyway, it's sample code people can go with and modify individually.

I am interested to turn this code into a more useful tool. Though I
think I miss some background information why this code is kept as
samples. Obviously, there is the API and ARCH dependency. As long as an
API change can reliable be detected I don't see a real show stopper.
Maybe I am too naive. Furthermore I expected that trace_preempt_[on|off]
wont change that often.

> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks,
Daniel
