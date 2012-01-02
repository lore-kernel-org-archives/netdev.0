From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [ANNOUNCE] libnetfilter_queue 1.0.1 release
Date: Mon, 2 Jan 2012 22:40:09 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1201022233510.29809@frira.zrqbmnf.qr>
References: <20120102195845.GA26867@1984> <alpine.LNX.2.01.1201022221470.29809@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1201022221470.29809@frira.zrqbmnf.qr>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 2012-01-02 22:22, Jan Engelhardt wrote:

>On Monday 2012-01-02 20:58, Pablo Neira Ayuso wrote:
>
>>Hi!
>>
>>The Netfilter project proudly presents:
>>
>>        libnetfilter_queue 1.0.1
>
>In commit 390b0c0f45597c72fa93a40f4f7f9ffeec371f42
>Author: Pablo Neira Ayuso <pablo@netfilter.org>
>Date:   Mon Jan 2 20:28:45 2012 +0100
>
>    build: bump version to 1.0.1
>    
>    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
>
>diff --git a/src/Makefile.am b/src/Makefile.am
>index 0bd037f..bc27625 100644
>--- a/src/Makefile.am
>+++ b/src/Makefile.am
>@@ -18,7 +18,7 @@
> # set age to 0.
> # </snippet>
> #
>-LIBVERSION=2:0:1
>+LIBVERSION=2:0:2
> 
> include ${top_srcdir}/Make_global.am
> 
>
>You wrongly changed LIBVERSION. It went from .so.1.1 to so.0.2, and that 
>just does not sound right. Perhaps you intended 2:1:1.
>
>Or just leaving r alone, like proposed? :)

Upon closer review, you ought to select 3:0:2, since you added functions 
since libnetfilter_queue-1.0.0.

===

origin git://dev.medozas.de/libnetfilter_queue master

parent 390b0c0f45597c72fa93a40f4f7f9ffeec371f42 (libnetfilter_queue-1.0.1)
commit a192d817a16ba08193a90043b46b6e2cf2d05091
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Mon Jan 2 22:36:03 2012 +0100

build: properly bump SO version

The last SO version update was bogus: 2:0:1 (.so.1.1.0) -> 2:0:2
(.so.0.2.0).

Since two functions were added between v1.0.0..v1.0.1, CURRENT needs
to be bumped at the least.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 src/Makefile.am |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/src/Makefile.am b/src/Makefile.am
index bc27625..d49e738 100644
--- a/src/Makefile.am
+++ b/src/Makefile.am
@@ -18,7 +18,7 @@
 # set age to 0.
 # </snippet>
 #
-LIBVERSION=2:0:2
+LIBVERSION=3:0:2
 
 include ${top_srcdir}/Make_global.am
 
-- 
# Created with git-export-patch
