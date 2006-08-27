From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.18-rc4-mm3: NF_CONNTRACK_FTP=y compile error
Date: Sun, 27 Aug 2006 04:42:19 +0200
Message-ID: <20060827024219.GO4765@stusta.de>
References: <20060826160922.3324a707.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	coreteam@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:9482 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1751103AbWH0CmU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Aug 2006 22:42:20 -0400
To: Andrew Morton <akpm@osdl.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	davem@davemloft.net
Content-Disposition: inline
In-Reply-To: <20060826160922.3324a707.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 26, 2006 at 04:09:22PM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.18-rc4-mm2:
>...
>  git-net.patch
>...
>  git trees
>...

<--  snip  -->

=2E..
  CC      net/netfilter/nf_conntrack_ftp.o
/home/bunk/linux/kernel-2.6/linux-2.6.18-rc4-mm3/net/netfilter/nf_connt=
rack_ftp.c: In function =E2=80=98get_ipv6_addr=E2=80=99:
/home/bunk/linux/kernel-2.6/linux-2.6.18-rc4-mm3/net/netfilter/nf_connt=
rack_ftp.c:117: warning: implicit declaration of function =E2=80=98in6_=
pton=E2=80=99
/home/bunk/linux/kernel-2.6/linux-2.6.18-rc4-mm3/net/netfilter/nf_connt=
rack_ftp.c:117: error: =E2=80=98end=E2=80=99 undeclared (first use in t=
his function)
/home/bunk/linux/kernel-2.6/linux-2.6.18-rc4-mm3/net/netfilter/nf_connt=
rack_ftp.c:117: error: (Each undeclared identifier is reported only onc=
e
/home/bunk/linux/kernel-2.6/linux-2.6.18-rc4-mm3/net/netfilter/nf_connt=
rack_ftp.c:117: error: for each function it appears in.)
make[3]: *** [net/netfilter/nf_conntrack_ftp.o] Error 1

<--  snip  -->
=20
cu
Adrian

--=20

    Gentoo kernels are 42 times more popular than SUSE kernels among
    KLive users  (a service by SUSE contractor Andrea Arcangeli that
    gathers data about kernels from many users worldwide).

       There are three kinds of lies: Lies, Damn Lies, and Statistics.
                                                    Benjamin Disraeli

