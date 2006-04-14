From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 00/10] e1000: Driver fixes and update to 7.0.38-k2
Date: Fri, 14 Apr 2006 11:34:23 -0700
Message-ID: <20060414183423.3461.32772.stgit@gitlost.site>
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeff" <Jeffrey.t.kirsher@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:44548 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751396AbWDNSdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2006 14:33:15 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Miller, David" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

This patch series implements two fixes, a series of cleanups and
two optimization patches.

The version of the driver was bumped to 7.0.38-k2. Year changes to 2006.

As I'm taking over patch duties from Jeff Kirsher, I added myself
to the MAINTAINERS file.

These changes are available through git.

Jeff, please pull from:

git://63.64.152.142/~ahkok/git/netdev-2.6 e1000-7.0.38-k2


Cheers,

Auke Kok


---
01/10: [FIX] Remove PM warning DPRINTKs breaking 2.4.x kernels
02/10: [FIX] Esb2 wol link cycle bug and uninitialized registers
03/10: [PATCH] De-inline functions to benefit from compiler smartness
04/10: [PATCH] Made an adapter struct variable into a local (txb2b)
05/10: [PATCH] Update truesize with the length of the packet for
                      packet split
06/10: [PATCH] Dead variable cleanup
07/10: [PATCH] Buffer optimizations for small MTU
08/10: [PATCH] implement more efficient tx queue locking
09/10: [DOC] Version bump, contact fix, year string change
10/10: [MAINTAINERS] {e100{,0},ixgb}: Add Auke Kok as new patch maintainer
                     for e{100,1000} and ixgb


---
 MAINTAINERS                       |    6 +
 drivers/net/e1000/Makefile        |    1 
 drivers/net/e1000/e1000.h         |    6 -
 drivers/net/e1000/e1000_ethtool.c |    3 
 drivers/net/e1000/e1000_hw.c      |    3 
 drivers/net/e1000/e1000_hw.h      |    3 
 drivers/net/e1000/e1000_main.c    |  198 ++++++++++++++++++--------------------
 drivers/net/e1000/e1000_osdep.h   |    3 
 drivers/net/e1000/e1000_param.c   |    3 
 9 files changed, 118 insertions(+), 108 deletions(-)


--
Auke Kok <auke-jan.h.kok@intel.com>
Intel Pro Ethernet Driver Group
LAN Access Division / Digital Enterprise Group 
