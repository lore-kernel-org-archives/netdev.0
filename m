From: "Gabor Z. Papp" <gzp@papp.hu>
Subject: Re: [ANNOUNCE]: Release of iptables-1.4.9
Date: Tue, 03 Aug 2010 18:34:20 +0200
Message-ID: <x6bp9jy7sj@gzp>
References: <4C5832F9.50004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"'netfilter\@vger.kernel.org'" <netfilter@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net>:

|     iptables version 1.4.9

make[2]: Entering directory `/home/gzp/src/iptables-1.4.9'
/bin/sh ./libtool --tag=CC   --mode=link gcc -D_LARGEFILE_SOURCE=1
-D_LARGE_FILES -D_FILE_OFFSET_BITS=64        -D_REENTRANT -Wall
-Waggregate-return -Wmissing-declarations  -Wmissing-prototypes
-Wredundant-decls -Wshadow -Wstrict-prototypes     -Winline -pipe
-DXTABLES_LIBDIR=\"/pkg/lib/xtables\" -DXTABLES_INTERNAL -I./include
-I./include  -DIPTABLES_MULTI -DALL_INCLUSIVE -g -O2 -rdynamic  -o
iptables-multi iptables_multi-iptables-multi.o
iptables_multi-iptables-save.o iptables_multi-iptables-restore.o
iptables_multi-iptables-xml.o iptables_multi-iptables-standalone.o
iptables_multi-iptables.o iptables_multi-xshared.o libiptc/libip4tc.la
extensions/libext4.a libxtables.la -lm 
libtool: link: gcc -D_LARGEFILE_SOURCE=1 -D_LARGE_FILES
-D_FILE_OFFSET_BITS=64 -D_REENTRANT -Wall -Waggregate-return
-Wmissing-declarations -Wmissing-prototypes -Wredundant-decls -Wshadow
-Wstrict-prototypes -Winline -pipe
-DXTABLES_LIBDIR=\"/pkg/lib/xtables\" -DXTABLES_INTERNAL -I./include
-I./include -DIPTABLES_MULTI -DALL_INCLUSIVE -g -O2 -rdynamic -o
iptables-multi iptables_multi-iptables-multi.o
iptables_multi-iptables-save.o iptables_multi-iptables-restore.o
iptables_multi-iptables-xml.o iptables_multi-iptables-standalone.o
iptables_multi-iptables.o iptables_multi-xshared.o
libiptc/.libs/libip4tc.a extensions/libext4.a ./.libs/libxtables.a -lm
collect2: ld terminated with signal 11 [Segmentation fault]
extensions/libext4.a(initext4.o): In function `init_extensions':
/home/gzp/src/iptables-1.4.9/extensions/initext4.c:138: undefined reference to `libxt_TEE_init'
make[2]: *** [iptables-multi] Error 1

[kernel]
Linux gzp1 2.6.32.17-gzp1 #1 SMP PREEMPT Tue Aug 3 17:17:10 CEST 2010
i686 GNU/Linux

[glibc]
GNU C Library stable release version 2.11.2, by Roland McGrath et al.
Compiled by GNU CC version 4.4.4.
Compiled on a Linux 2.6.34 system on 2010-06-01.
        Native POSIX Threads Library by Ulrich Drepper et al

[gcc]
gcc (GCC) 4.4.4

[binutils]
GNU ld (Linux/GNU Binutils) 2.20.51.0.10.20100707
