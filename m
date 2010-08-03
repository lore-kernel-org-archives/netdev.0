From: "Gabor Z. Papp" <gzp@papp.hu>
Subject: Re: [ANNOUNCE]: Release of iptables-1.4.9
Date: Tue, 03 Aug 2010 19:16:06 +0200
Message-ID: <x6vd7rwrah@gzp>
References: <4C5832F9.50004@trash.net> <x6bp9jy7sj@gzp>
	<4C584C63.8010607@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"'netfilter\@vger.kernel.org'" <netfilter@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from odpn1.odpn.net ([212.40.96.53]:44384 "EHLO odpn1.odpn.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751453Ab0HCRQI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 13:16:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Patrick McHardy <kaber@trash.net>:

| Did you use a git checkout/patch against 1.4.8 or the tar.bz2?
| In case its the former, try running make clean, sh autogen.sh and
| sh configure again before the build.

Used the tarball, but tried git also:

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
/home/gzp/src/iptables/extensions/initext4.c:144: undefined reference to `libxt_IDLETIMER_init'
/home/gzp/src/iptables/extensions/initext4.c:145: undefined reference to `libxt_TEE_init'
make[2]: *** [iptables-multi] Error 1

Note the difference, new undefined reference: `libxt_IDLETIMER_init
