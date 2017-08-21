From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] MIPS,bpf: Improvements for MIPS eBPF JIT
Date: Mon, 21 Aug 2017 10:31:52 -0700 (PDT)
Message-ID: <20170821.103152.1302932686530323238.davem@davemloft.net>
References: <20170818234033.5990-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org
To: david.daney@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170818234033.5990-1-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>
Date: Fri, 18 Aug 2017 16:40:30 -0700

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
> 
> Still pending are changes to reduce stack usage when the verifier can
> determine the maximum stack size.

Applied to net-next.
