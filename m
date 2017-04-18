From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH net-next 1/2] sparc: Split BPF JIT into 32-bit and 64-bit.
Date: Tue, 18 Apr 2017 21:31:57 +0200
Message-ID: <20170418193157.GA29862@ravnborg.org>
References: <20170418.145806.845080704857445577.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sparclinux@vger.kernel.org, netdev@vger.kernel.org, ast@kernel.org,
        daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <sparclinux-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170418.145806.845080704857445577.davem@davemloft.net>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 18, 2017 at 02:58:06PM -0400, David Miller wrote:
> 
> This is in preparation for adding the 64-bit eBPF JIT.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  arch/sparc/net/Makefile          |   2 +-
>  arch/sparc/net/bpf_jit.h         |  68 ----
>  arch/sparc/net/bpf_jit_32.h      |  68 ++++
>  arch/sparc/net/bpf_jit_asm.S     | 208 ----------
>  arch/sparc/net/bpf_jit_asm_32.S  | 208 ++++++++++
>  arch/sparc/net/bpf_jit_asm_64.S  |   1 +
>  arch/sparc/net/bpf_jit_comp.c    | 815 ---------------------------------------
>  arch/sparc/net/bpf_jit_comp_32.c | 815 +++++++++++++++++++++++++++++++++++++++
>  arch/sparc/net/bpf_jit_comp_64.c |   1 +
>  9 files changed, 1094 insertions(+), 1092 deletions(-)
>  delete mode 100644 arch/sparc/net/bpf_jit.h
>  create mode 100644 arch/sparc/net/bpf_jit_32.h
>  delete mode 100644 arch/sparc/net/bpf_jit_asm.S
>  create mode 100644 arch/sparc/net/bpf_jit_asm_32.S
>  create mode 100644 arch/sparc/net/bpf_jit_asm_64.S
>  delete mode 100644 arch/sparc/net/bpf_jit_comp.c
>  create mode 100644 arch/sparc/net/bpf_jit_comp_32.c
>  create mode 100644 arch/sparc/net/bpf_jit_comp_64.c

Adding options "-M -C" to git format-patch would have helped readability
of this patch.
As it is now we cannot see what changes were made to the varoious files
when they were renamed.

(I trust you have made no irrelevant but wanted to mention it anyway)

	Sam
