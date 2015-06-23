From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lib: test_bpf: purge CPP register redefinitions
Date: Tue, 23 Jun 2015 06:47:04 -0700 (PDT)
Message-ID: <20150623.064704.865365468192165721.davem@davemloft.net>
References: <87twu0df3k.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	richard@nod.at
To: nicstange@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87twu0df3k.fsf@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolai Stange <nicstange@gmail.com>
Date: Sun, 21 Jun 2015 21:41:03 +0200

> Fix compilation failer with allmodconfig on ARCH=um:
>   lib/test_bpf.c:50:0: warning: "R8" redefined
>    #define R8  BPF_REG_8
>    ^
>   In file included from arch/um/include/asm/ptrace-generic.h:11:0,
>                    from arch/x86/um/asm/ptrace.h:8,
>                    from arch/x86/include/asm/alternative.h:8,
>                    from arch/x86/include/asm/bitops.h:16,
>                    from include/linux/bitops.h:36,
>                    from include/linux/kernel.h:10,
>                    from include/linux/list.h:8,
>                    from include/linux/module.h:9,
>                    from lib/test_bpf.c:19:
>   arch/x86/include/uapi/asm/ptrace-abi.h:42:0:
>     note: this is the location of the previous definition
>      #define R8 72
> 
> Get rid of the
>   #define Rx BPF_REG_x
> defines by substituting the Rx macros with their BPF_REG_x expansion
> in test_bpf.c.
> 
> Signed-off-by: Nicolai Stange <nicstange@gmail.com>

Applied, thanks.
