From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 0/7] chelsio: introduction
Date: Tue, 12 Dec 2006 00:15:58 +0100
Message-ID: <20061211231558.GA8568@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59705 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750716AbWLKXRG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 18:17:06 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The serie applies against netdev-2.6#upstream-linus or linux-2.6#master

Patches have been compiled. No further test.

It is available as:

git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git#chelsio

Former 'chelsio' branch is archived as 'chelsio-20061211'.

Distance from Linus's trunk (8af905b4a403ce74b8d907b50bccc453a58834bc)
----------------------------------------------------------------------

6822b9d59faceb62a7044849cff012d6cf20ad7a
1f3d073359a4f78731fabc1ef2d9b8cc8dcff16b
e4b382e3b6df583f53bd56285ab32d25924fe653
1699093b113c327f0b8e79aeae73eba5c6b30910
e284e11a7ede38ed441c52aa51c7bf48a6623e0d
18f6e5536f6c00fe27b19745eb8577432bb6bc95
36959faf64235eb0509420b91d950279f797f58e

Diffstat
--------

 drivers/net/chelsio/common.h      |    2 
 drivers/net/chelsio/cpl5_cmd.h    |   18 ++--
 drivers/net/chelsio/cxgb2.c       |  149 ++++++++++++-------------------
 drivers/net/chelsio/elmer0.h      |   40 ++++----
 drivers/net/chelsio/espi.c        |   44 +++++----
 drivers/net/chelsio/fpga_defs.h   |    6 +
 drivers/net/chelsio/gmac.h        |   11 ++
 drivers/net/chelsio/ixf1010.c     |  100 ++++++++++++---------
 drivers/net/chelsio/mv88e1xxx.c   |   27 +++---
 drivers/net/chelsio/my3126.c      |   16 ++-
 drivers/net/chelsio/pm3393.c      |   91 +++++++++++--------
 drivers/net/chelsio/sge.c         |  178 +++++++++++++++++--------------------
 drivers/net/chelsio/subr.c        |   89 +++++++++----------
 drivers/net/chelsio/tp.c          |   62 ++++++-------
 drivers/net/chelsio/vsc7326.c     |  139 +++++++++++++++--------------
 drivers/net/chelsio/vsc7326_reg.h |  139 ++++++++++++++++-------------
 drivers/net/chelsio/vsc8244.c     |   41 ++++-----
 17 files changed, 580 insertions(+), 572 deletions(-)

Shortlog
--------

Francois Romieu:
      chelsio: move return, break and continue statements on their own line
      chelsio: the return statement is not a function
      chelsio: spaces, tabs and friends
      chelsio: useless curly braces
      chelsio: useless test in cxgb2::remove_one
      chelsio: misc cleanups in sge
      chelsio: tabulate the update of the statistic counters

Patch
-----

See following messages.

-- 
Ueimor
