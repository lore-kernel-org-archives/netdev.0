From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: Fix compiler warning.
Date: Fri, 11 Dec 2009 00:44:03 +0100 (CET)
Message-ID: <alpine.LSU.2.01.0912110043320.11964@obet.zrqbmnf.qr>
References: <pvmein2bj1p.fsf@chavey.mtv.corp.google.com> <alpine.LSU.2.01.0912102301380.5189@obet.zrqbmnf.qr> <20091210.140843.142337259.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: chavey@google.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, eric.dumazet@gmail.com,
	akpm@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20091210.140843.142337259.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Donnerstag 2009-12-10 23:08, David Miller wrote:
>> On Donnerstag 2009-12-10 22:44, chavey@google.com wrote:
>> 
>>>Fix compiler warning "discards qualifiers from pointer target type",
>>>by allowing explicit discard of const qualifier thru type casting.
>>>The const_cast() macro is taken from a patch from Kaveh R. Ghazi
>> 
>> Uhm, I am not getting any warning on xt_time with either gcc-4.4.1
>> or gcc-4.5_20091126, so what case are we actually trying to fix?
>
>I get this warning with gcc-4.3.x all the time.

Seems they fixed it in gcc-4.3 too?

00:41 borg:~/code/linux > make net/netfilter/xt_time.o -j8 CC=gcc-4.3
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  SYMLINK include/asm -> include/asm-x86
  CC      scripts/mod/empty.o
  MKELF   scripts/mod/elfconfig.h
  HOSTCC  scripts/mod/file2alias.o
  HOSTCC  scripts/mod/modpost.o
  HOSTCC  scripts/mod/sumversion.o
  HOSTLD  scripts/mod/modpost
  CC      kernel/bounds.s
  GEN     include/linux/bounds.h
  CC      arch/x86/kernel/asm-offsets.s
  GEN     include/asm/asm-offsets.h
  CALL    scripts/checksyscalls.sh
  CC [M]  net/netfilter/xt_time.o
00:42 borg:~/code/linux > gcc-4.3 -v
Using built-in specs.
Target: x86_64-suse-linux
Configured with: ../configure --prefix=/usr --infodir=/usr/share/info 
--mandir=/usr/share/man --libdir=/usr/lib64 --libexecdir=/usr/lib64 
--enable-languages=c,c++,objc,fortran,obj-c++,java,ada 
--enable-checking=release --with-gxx-include-dir=/usr/include/c++/4.3 
--enable-ssp --disable-libssp --with-bugurl=http://bugs.opensuse.org/ 
--with-pkgversion='SUSE Linux' --disable-libgcj --disable-libmudflap 
--with-slibdir=/lib64 --with-system-zlib --enable-__cxa_atexit 
--enable-libstdcxx-allocator=new --disable-libstdcxx-pch 
--enable-version-specific-runtime-libs --program-suffix=-4.3 
--enable-linux-futex --without-system-libunwind --with-cpu=generic 
--build=x86_64-suse-linux
Thread model: posix
gcc version 4.3.4 (SUSE Linux)

