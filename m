From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: You have to fix this
Date: Wed, 03 Oct 2012 14:17:54 -0700
Message-ID: <506CAB82.8020208@xenotime.net>
References: <20120927.183406.962014014858457666.davem@davemloft.net> <5065911A.3000509@chelsio.com> <20120928.134313.2263654281720915031.davem@davemloft.net> <506C0F75.4080309@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vipul Pandya <vipul@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy9.bluehost.com ([69.89.24.6]:32812 "HELO
	oproxy9.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755577Ab2JCVSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 17:18:07 -0400
In-Reply-To: <506C0F75.4080309@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/2012 03:12 AM, Vipul Pandya wrote:

> 
> 
> On 28-09-2012 23:13, David Miller wrote:
>> From: Vipul Pandya <vipul@chelsio.com>
>> Date: Fri, 28 Sep 2012 17:29:22 +0530
>>
>>> Please let me know how else would I get above warning message?
>>
>> Maybe your compiler is too old.  Does -Wframe-larger-than= show up in your
>> build logs with "make V=1"?
>>
> 
> I am using gcc version 4.4.4 20100726. Yes -Wframe-larger-than=2048 does
> show up in my build logs as shown below:
> ===
> gcc -Wp,-MD,arch/x86/kernel/.hw_breakpoint.o.d  -nostdinc -isystem
> /usr/lib/gcc/x86_64-redhat-linux/4.4.4/include
> -I/root/git_kernel_tree/net-next/arch/x86/include
> -Iarch/x86/include/generated -Iinclude  -include
> /root/git_kernel_tree/net-next/include/linux/kconfig.h -D__KERNEL__
> -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing
> -fno-common -Werror-implicit-function-declaration -Wno-format-security
> -fno-delete-null-pointer-checks -O2 -m64 -mtune=generic -mno-red-zone
> -mcmodel=kernel -funit-at-a-time -maccumulate-outgoing-args
> -DCONFIG_AS_CFI=1 -DCONFIG_AS_CFI_SIGNAL_FRAME=1
> -DCONFIG_AS_CFI_SECTIONS=1 -DCONFIG_AS_FXSAVEQ=1 -DCONFIG_AS_AVX=1 -pipe
> -Wno-sign-compare -fno-asynchronous-unwind-tables -mno-sse -mno-mmx
> -mno-sse2 -mno-3dnow -mno-avx -Wframe-larger-than=2048
> -fno-stack-protector -Wno-unused-but-set-variable -fomit-frame-pointer
> -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow
> -fconserve-stack -DCC_HAVE_ASM_GOTO    -D"KBUILD_STR(s)=#s"
> -D"KBUILD_BASENAME=KBUILD_STR(hw_breakpoint)"
> -D"KBUILD_MODNAME=KBUILD_STR(hw_breakpoint)" -c -o
> arch/x86/kernel/hw_breakpoint.o arch/x86/kernel/hw_breakpoint.c
> ===


Regardless, you could just go ahead and fix it and use
scripts/checkstack.pl (or make checkstack) to check it for stack
usage as well as test the binary code to make sure that it works OK.

-- 
~Randy
