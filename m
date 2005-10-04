From: Jeff Garzik <jgarzik@pobox.com>
Subject: [git patches] (updated) net driver updates
Date: Tue, 04 Oct 2005 05:52:54 -0400
Message-ID: <434250F6.2040406@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev list <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew and Linus,

I pushed three more csets to the 'upstream-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git

This fixes some of the fixes :)

Changelog of added csets follows:

commit 832f8f0378ff1566f2a222352c7ad5df3f8d0d9d
Author: Randy Dunlap <rdunlap@xenotime.net>
Date:   Tue Oct 4 00:41:22 2005 -0700

     [PATCH] sungem: fix gfp flags type

     Fix nocast sparse warnings in sungen:
     drivers/net/sungem.h:1040:45: warning: implicit cast to nocast type

     Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
     Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

commit 81c58732277654a51bb52832e1bc74234bb977bc
Author: Randy Dunlap <rdunlap@xenotime.net>
Date:   Mon Oct 3 21:24:36 2005 -0700

     [PATCH] ns83820: fix gfp flags type

     Fix implicit nocast warnings in ns83820 code, including __nocast:
     drivers/net/ns83820.c:603:46: warning: implicit cast to nocast type

     Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
     Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

commit f36a29d5672c7698ffe55c7c05107ae77fa698cc
Author: Randy Dunlap <rdunlap@xenotime.net>
Date:   Mon Oct 3 21:24:45 2005 -0700

     [PATCH] ieee80211: fix gfp flags type

     Fix implicit nocast warnings in ieee80211 code, including __nocast:
     net/ieee80211/ieee80211_tx.c:215:9: warning: implicit cast to 
nocast type

     Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
     Signed-off-by: Jeff Garzik <jgarzik@pobox.com>
