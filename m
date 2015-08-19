From: Meelis Roos <mroos@linux.ee>
Subject: inet_hashtables.c: warning: division by zero
Date: Wed, 19 Aug 2015 18:24:35 +0300 (EEST)
Message-ID: <alpine.LRH.2.20.1508191823130.6342@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:44616 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751824AbbHSPYN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 11:24:13 -0400
Received: from math.ut.ee (unknown [IPv6:2001:bb8:2002:2400:5054:ff:fe3b:8db9])
	by smtp2.it.da.ut.ee (Postfix) with ESMTP id E6BBE741985
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 18:24:10 +0300 (EEST)
Received: from localhost (localhost [127.0.0.1])
	by math.ut.ee (Postfix) with ESMTP id 5339F2211A5
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 18:24:35 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed this while compiling 4.2-rc7+git on i386 with gcc 4.9.2:

  CC      net/ipv4/inet_hashtables.o
In file included from include/linux/list.h:8:0,
                 from include/linux/module.h:9,
                 from net/ipv4/inet_hashtables.c:16:
net/ipv4/inet_hashtables.c: In function =A1inet_ehash_locks_alloc=A2:
net/ipv4/inet_hashtables.c:632:24: warning: division by zero [-Wdiv-by-=
zero]
     2 * L1_CACHE_BYTES / sizeof(spinlock_t),
                        ^
include/linux/kernel.h:769:17: note: in definition of macro =A1max_t=A2
  type __max1 =3D (x);   \
                 ^

--=20
Meelis Roos (mroos@linux.ee)
