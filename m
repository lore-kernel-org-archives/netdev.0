From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/2] Trivial cleanups
Date: Mon, 23 Nov 2009 23:24:10 -0800
Message-ID: <cover.1259047344.git.joe@perches.com>
Cc: adapter_linux_open_src_team@brocade.com, netdev@vger.kernel.org
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1115 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753590AbZKXHYH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 02:24:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just a couple of cleanup patches on your latest submission.

Joe Perches (2):
  drivers/net/bna: Use pr_<level>, dev_<level>, remove DPRINTK
  drivers/net/bna: Use kcalloc

 drivers/net/bna/bfa_csdebug.c |   10 +-
 drivers/net/bna/bfa_ioc.c     |    5 +-
 drivers/net/bna/bfad_fwimg.c  |    8 +-
 drivers/net/bna/bna_fn.c      |    7 +-
 drivers/net/bna/bna_if.c      |   48 ++++------
 drivers/net/bna/bnad.c        |  216 ++++++++++++++++-------------------------
 drivers/net/bna/bnad_compat.h |   13 ---
 drivers/net/bna/cna.h         |    5 -
 8 files changed, 116 insertions(+), 196 deletions(-)

