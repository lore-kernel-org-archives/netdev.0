From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.23-rc1-mm1: net/ipv4/fib_trie.c compile error
Date: Wed, 25 Jul 2007 20:15:57 +0200
Message-ID: <20070725181557.GF3572@stusta.de>
References: <20070725040304.111550f4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>, Josh Triplett <josh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:44196 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754247AbXGYSQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 14:16:24 -0400
Content-Disposition: inline
In-Reply-To: <20070725040304.111550f4.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 25, 2007 at 04:03:04AM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.22-rc6-mm1:
>...
> +immunize-rcu_dereference-against-crazy-compiler-writers.patch
>...
>  Misc new patches
>...

This patch causes the following compile error:

<--  snip  -->

=2E..
  CC      net/ipv4/fib_trie.o
/home/bunk/linux/kernel-2.6/linux-2.6.23-rc1-mm1/net/ipv4/fib_trie.c: I=
n function =E2=80=98trie_rebalance=E2=80=99:
/home/bunk/linux/kernel-2.6/linux-2.6.23-rc1-mm1/net/ipv4/fib_trie.c:96=
9: error: lvalue required as unary =E2=80=98&=E2=80=99 operand
/home/bunk/linux/kernel-2.6/linux-2.6.23-rc1-mm1/net/ipv4/fib_trie.c:97=
1: error: lvalue required as unary =E2=80=98&=E2=80=99 operand
/home/bunk/linux/kernel-2.6/linux-2.6.23-rc1-mm1/net/ipv4/fib_trie.c:97=
7: error: lvalue required as unary =E2=80=98&=E2=80=99 operand
/home/bunk/linux/kernel-2.6/linux-2.6.23-rc1-mm1/net/ipv4/fib_trie.c:98=
0: error: lvalue required as unary =E2=80=98&=E2=80=99 operand
=2E..
make[3]: *** [net/ipv4/fib_trie.o] Error 1

<--  snip  -->


cu
Adrian

--=20

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

