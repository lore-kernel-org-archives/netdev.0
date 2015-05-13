From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: gone with the spring cleanup..
Date: Wed, 13 May 2015 12:12:45 +0300
Message-ID: <5553158D.7000108@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jiri Pirko <jiri@resnulli.us>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0058.outbound.protection.outlook.com ([157.55.234.58]:58560
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754341AbbEMJN3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 05:13:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Scott, Jiri

So, following the spring cleanup, my builder (which turns to have pretty 
old GCC 4.4.6) isn't functional anymore w.r.t net-next... I checked on 
different station and it works on GCC 4.9.2.

I would love us to get this fixed, please let me know if you need more 
info, below is the build verbose command line build error.

Few more pieces of info, changing -std=gnu89to -std=gnu99didn't help. 
Also the command line where it does work (4.9.2) uses -std=gnu89

Or.



gcc -Wp,-MD,net/switchdev/.switchdev.o.d  -nostdinc -isystem 
/usr/lib/gcc/x86_64-redhat-linux/4.4.6/include -I./arch/x86/include 
-Iarch/x86/include/generated/uapi -Iarch/x86/include/generated  
-Iinclude -I./arch/x86/include/uapi -Iarch/x86/include/generated/uapi 
-I./include/uapi -Iinclude/generated/uapi -include 
./include/linux/kconfig.h -D__KERNEL__ -Wall -Wundef -Wstrict-prototypes 
-Wno-trigraphs -fno-strict-aliasing -fno-common 
-Werror-implicit-function-declaration -Wno-format-security -std=gnu89 
-m64 -mno-80387 -mno-fp-ret-in-387 -mtune=generic -mno-red-zone 
-mcmodel=kernel -funit-at-a-time -maccumulate-outgoing-args 
-DCONFIG_AS_CFI=1 -DCONFIG_AS_CFI_SIGNAL_FRAME=1 
-DCONFIG_AS_CFI_SECTIONS=1 -DCONFIG_AS_FXSAVEQ=1 -DCONFIG_AS_SSSE3=1 
-DCONFIG_AS_CRC32=1 -DCONFIG_AS_AVX=1 -pipe -Wno-sign-compare 
-fno-asynchronous-unwind-tables -mno-sse -mno-mmx -mno-sse2 -mno-3dnow 
-mno-avx -fno-delete-null-pointer-checks -Os -Wframe-larger-than=2048 
-fno-stack-protector -Wno-unused-but-set-variable 
-fno-omit-frame-pointer -fno-optimize-sibling-calls 
-fno-var-tracking-assignments -g -Wdeclaration-after-statement 
-Wno-pointer-sign -fno-strict-overflow -fconserve-stack 
-Werror=implicit-int -Werror=strict-prototypes -DCC_HAVE_ASM_GOTO 
-D"KBUILD_STR(s)=#s" -D"KBUILD_BASENAME=KBUILD_STR(switchdev)" 
-D"KBUILD_MODNAME=KBUILD_STR(switchdev)" -c -o 
net/switchdev/.tmp_switchdev.o net/switchdev/switchdev.c
net/switchdev/switchdev.c: In function 'switchdev_fib_ipv4_add':
net/switchdev/switchdev.c:646: error: unknown field 'ipv4_fib' specified 
in initializer
net/switchdev/switchdev.c:646: warning: braces around scalar initializer
net/switchdev/switchdev.c:646: warning: (near initialization for 
'fib_obj.trans')
net/switchdev/switchdev.c:647: error: field name not in record or union 
initializer
net/switchdev/switchdev.c:647: error: (near initialization for 
'fib_obj.trans')
net/switchdev/switchdev.c:648: error: field name not in record or union 
initializer
net/switchdev/switchdev.c:648: error: (near initialization for 
'fib_obj.trans')
net/switchdev/switchdev.c:648: warning: excess elements in scalar 
initializer
net/switchdev/switchdev.c:648: warning: (near initialization for 
'fib_obj.trans')
net/switchdev/switchdev.c:649: error: field name not in record or union 
initializer
net/switchdev/switchdev.c:649: error: (near initialization for 
'fib_obj.trans')
net/switchdev/switchdev.c:649: warning: excess elements in scalar 
initializer
net/switchdev/switchdev.c:649: warning: (near initialization for 
'fib_obj.trans')
net/switchdev/switchdev.c:650: error: field name not in record or union 
initializer
net/switchdev/switchdev.c:650: error: (near initialization for 
'fib_obj.trans')
net/switchdev/switchdev.c:650: warning: excess elements in scalar 
initializer
net/switchdev/switchdev.c:650: warning: (near initialization for 
'fib_obj.trans')
net/switchdev/switchdev.c:651: error: field name not in record or union 
initializer
net/switchdev/switchdev.c:651: error: (near initialization for 
'fib_obj.trans')
net/switchdev/switchdev.c:651: warning: excess elements in scalar 
initializer
net/switchdev/switchdev.c:651: warning: (near initialization for 
'fib_obj.trans')
net/switchdev/switchdev.c:652: error: field name not in record or union 
initializer
net/switchdev/switchdev.c:652: error: (near initialization for 
'fib_obj.trans')
net/switchdev/switchdev.c:652: warning: excess elements in scalar 
initializer
net/switchdev/switchdev.c:652: warning: (near initialization for 
'fib_obj.trans')
net/switchdev/switchdev.c:653: error: field name not in record or union 
initializer
net/switchdev/switchdev.c:653: error: (near initialization for 
'fib_obj.trans')
net/switchdev/switchdev.c:653: warning: excess elements in scalar 
initializer
net/switchdev/switchdev.c:653: warning: (near initialization for 
'fib_obj.trans')
