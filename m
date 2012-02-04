From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] arch: net: bpf_jit_comp: Fixed coding style issues.
Date: Sat, 04 Feb 2012 16:51:22 -0500 (EST)
Message-ID: <20120204.165122.841855829159259361.davem@davemloft.net>
References: <1328229495-7603-1-git-send-email-mbarekfiras@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, tglx@linutronix.de, mingo@redhat.com,
	hpa@zytor.com, x86@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mbarekfiras@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328229495-7603-1-git-send-email-mbarekfiras@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mbarek Firas <mbarekfiras@gmail.com>
Date: Fri,  3 Feb 2012 01:38:15 +0100

> -			COND_SEL(BPF_S_JMP_JGT_K, X86_JA, X86_JBE);
> -			COND_SEL(BPF_S_JMP_JGE_K, X86_JAE, X86_JB);
> -			COND_SEL(BPF_S_JMP_JEQ_K, X86_JE, X86_JNE);
> -			COND_SEL(BPF_S_JMP_JSET_K,X86_JNE, X86_JE);
> -			COND_SEL(BPF_S_JMP_JGT_X, X86_JA, X86_JBE);
> -			COND_SEL(BPF_S_JMP_JGE_X, X86_JAE, X86_JB);
> -			COND_SEL(BPF_S_JMP_JEQ_X, X86_JE, X86_JNE);
> -			COND_SEL(BPF_S_JMP_JSET_X,X86_JNE, X86_JE);
> +			COND_SEL(BPF_S_JMP_JGT_K,  X86_JA,  X86_JBE);
> +			COND_SEL(BPF_S_JMP_JGE_K,  X86_JAE, X86_JB);
> +			COND_SEL(BPF_S_JMP_JEQ_K,  X86_JE,  X86_JNE);
> +			COND_SEL(BPF_S_JMP_JSET_K, X86_JNE, X86_JE);

This is rediculious, it's not fixing anything.

There is no requirement that all the arguments have to line up
to the same column on every line.

I'm not applying this patch.
