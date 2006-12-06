From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 0/7] chelsio: lightweight review
Date: Wed, 6 Dec 2006 01:10:07 +0100
Message-ID: <20061206001007.GA27423@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:57997 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756807AbWLFANW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 19:13:22 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The serie applies against netdev-2.6#upstream-linus or linux-2.6#master

Patches have been compiled. No further test.

It is available as:

git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git#chelsio

Former 'chelsio' branch is archived as 'chelsio-20061206'.


Distance from 'master' (e62438630ca37539c8cc1553710bbfaa3cf960a7)
-----------------------------------------------------------------

c021b7a9f2dcb8867f513983c42049b46bc97999
e9c87a1d5674c56a33288177913b27911cefc7a3
b335493ac99e2a4c716e597d6a11108fc670db90
4cf12df7a8e19339038f4e7952abf85554733916
89e9d8ea4fbd032872e0a96b3f455b9de912b1f6
3c086dfee287469d5ee7b860eaec9be56b4ef0ef
9b59cb170afa01d1dd86383c5178b9c306dbd275

Diffstat
--------

 drivers/net/chelsio/common.h    |    2 
 drivers/net/chelsio/cpl5_cmd.h  |   18 ++--
 drivers/net/chelsio/cxgb2.c     |  161 ++++++++++++++++++-------------------
 drivers/net/chelsio/elmer0.h    |   40 +++++----
 drivers/net/chelsio/espi.c      |   44 +++++-----
 drivers/net/chelsio/fpga_defs.h |    6 +
 drivers/net/chelsio/gmac.h      |   11 ++
 drivers/net/chelsio/ixf1010.c   |   13 ++-
 drivers/net/chelsio/mv88e1xxx.c |   27 +++---
 drivers/net/chelsio/my3126.c    |   16 ++--
 drivers/net/chelsio/pm3393.c    |    8 +-
 drivers/net/chelsio/sge.c       |  172 ++++++++++++++++++---------------------
 drivers/net/chelsio/subr.c      |   89 ++++++++++----------
 drivers/net/chelsio/tp.c        |   62 +++++++-------
 drivers/net/chelsio/vsc7326.c   |   75 ++++++++---------
 drivers/net/chelsio/vsc8244.c   |   41 +++++----
 16 files changed, 388 insertions(+), 397 deletions(-)

Shortlog
--------

Francois Romieu:
      chelsio: move return, break and continue statements on their own line
      chelsio: the return statement is not a function
      chelsio: spaces, tabs and friends
      chelsio: use netdev_priv
      chelsio: useless curly braces
      chelsio: useless test in cxgb2::remove_one
      chelsio: misc cleanups in sge

Patch
-----

See following messages.

-- 
Ueimor
