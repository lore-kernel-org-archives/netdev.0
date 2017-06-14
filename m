From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/4] test_bpf: Add test to make conditional jump cross
 a large number of insns.
Date: Wed, 14 Jun 2017 02:20:09 +0200
Message-ID: <59408139.6010302@iogearbox.net>
References: <20170613234938.4823-1-david.daney@cavium.com> <20170613234938.4823-3-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org
To: David Daney <david.daney@cavium.com>,
        Alexei Starovoitov <ast@kernel.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613234938.4823-3-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/14/2017 01:49 AM, David Daney wrote:
> On MIPS, conditional branches can only span 32k instructions.  To
> exceed this limit in the JIT with the BPF maximum of 4k insns, we need
> to choose eBPF insns that expand to more than 8 machine instructions.
> Use BPF_LD_ABS as it is quite complex.  This forces the JIT to invert
> the sense of the branch to branch around a long jump to the end.
>
> This (somewhat) verifies that the branch inversion logic and target
> address calculation of the long jumps are done correctly.
>
> Signed-off-by: David Daney <david.daney@cavium.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
