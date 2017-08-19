From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 0/3] MIPS,bpf: Improvements for MIPS eBPF JIT
Date: Sat, 19 Aug 2017 03:18:38 +0200
Message-ID: <599791EE.7010701@iogearbox.net>
References: <20170818234033.5990-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org
To: David Daney <david.daney@cavium.com>,
        Alexei Starovoitov <ast@kernel.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170818234033.5990-1-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/19/2017 01:40 AM, David Daney wrote:
> Here are several improvements and bug fixes for the MIPS eBPF JIT.
>
> The main change is the addition of support for JLT, JLE, JSLT and JSLE
> ops, that were recently added.
>
> Also fix WARN output when used with preemptable kernel, and a small
> cleanup/optimization in the use of BPF_OP(insn->code).
>
> I suggest that the whole thing go via the BPF/net-next path as there
> are dependencies on code that is not yet merged to Linus' tree.

Yes, this would be via net-next.

> Still pending are changes to reduce stack usage when the verifier can
> determine the maximum stack size.

Awesome, thanks a lot!
