From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2] bpf: BPF based latency tracing
Date: Fri, 19 Jun 2015 17:53:57 -0700
Message-ID: <5584B9A5.9030602@plumgrid.com>
References: <1434722444-10200-1-git-send-email-daniel.wagner@bmw-carit.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Daniel Wagner <daniel.wagner@bmw-carit.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434722444-10200-1-git-send-email-daniel.wagner@bmw-carit.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/19/15 7:00 AM, Daniel Wagner wrote:
> BPF offers another way to generate latency histograms. We attach
> kprobes at trace_preempt_off and trace_preempt_on and calculate the
> time it takes to from seeing the off/on transition.
...
> Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
...
> With the rebase on net-next no additinal patches are needed and this
> thing here runs fine.
...
> samples/bpf/Makefile       |   4 ++
>   samples/bpf/lathist_kern.c |  99 +++++++++++++++++++++++++++++++++++++++++++
>   samples/bpf/lathist_user.c | 103 +++++++++++++++++++++++++++++++++++++++++++++
>   3 files changed, 206 insertions(+)
>   create mode 100644 samples/bpf/lathist_kern.c
>   create mode 100644 samples/bpf/lathist_user.c

Thanks. That's a useful example.
Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Dave,
this patch is for net-next and I hope it's not too late
for this merge window.
