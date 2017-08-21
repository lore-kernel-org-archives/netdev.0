From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 0/3] MIPS,bpf: Improvements for MIPS eBPF JIT
Date: Mon, 21 Aug 2017 10:24:23 +0200
Message-ID: <599A98B7.6070909@iogearbox.net>
References: <20170818234033.5990-1-david.daney@cavium.com> <20170820.200619.821714603187353951.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org
To: David Miller <davem@davemloft.net>, david.daney@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170820.200619.821714603187353951.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/21/2017 05:06 AM, David Miller wrote:
> From: David Daney <david.daney@cavium.com>
> Date: Fri, 18 Aug 2017 16:40:30 -0700
>
>> I suggest that the whole thing go via the BPF/net-next path as there
>> are dependencies on code that is not yet merged to Linus' tree.
>
> What kind of dependency?  On networking or MIPS changes?

On networking, David implemented the JLT, JLE, JSLT and JSLE
ops for the JIT in the patch set. Back then the MIPS JIT wasn't
in net-next tree, thus this is basically just a follow-up, so
that we have all covered with JIT support for net-next.

Thanks,
Daniel
