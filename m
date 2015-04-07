From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: linux-next: manual merge of the tip tree with the net-next tree
Date: Tue, 07 Apr 2015 09:10:49 -0700
Message-ID: <55240189.4020406@plumgrid.com>
References: <20150407171148.7a41ee90@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150407171148.7a41ee90@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/7/15 12:11 AM, Stephen Rothwell wrote:
> Hi all,
>
> Today's linux-next merge of the tip tree got a conflict in
> include/uapi/linux/bpf.h between commit 96be4325f443 ("ebpf: add
> sched_cls_type and map it to sk_filter's verifier ops"), 03e69b508b6f
> ("ebpf: add prandom helper for packet sampling"), c04167ce2ca0 ("ebpf:
> add helper for obtaining current processor id"), 94caee8c312d ("ebpf:
> add sched_act_type and map it to sk_filter's verifier ops"),
> 608cd71a9c7c ("tc: bpf: generalize pedit action") and 91bc4822c3d6
> ("tc: bpf: add checksum helpers") from the net-next tree and commit
> 2541517c32be ("tracing, perf: Implement BPF programs attached to
> kprobes"), d9847d310ab4 ("tracing: Allow BPF programs to call
> bpf_ktime_get_ns()") and 9c959c863f82 ("tracing: Allow BPF programs to
> call bpf_trace_printk()") from the tip tree.
>
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).
>

Looks good. Thanks!
