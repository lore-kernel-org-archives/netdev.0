From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [GIT PATCHES]: Crit SCTP updates
Date: Tue,  3 Jul 2007 15:52:38 -0400
Message-ID: <11834923583821-git-send-email-vladislav.yasevich@hp.com>
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:59727 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757191AbXGCTxK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 15:53:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David

This is a pull request for some critical SCTP fixes that I just pushed out.
The fix some important issues and I think should be candidates for stable.

Do you want to me to generate the stable patches from these, or do you
take of it usually?

Thanks
-vlad

The following changes since commit 5f0212174db33828f8bddcff501b73d2bc734f72:
  Randy Dunlap (1):
        [IRDA]: fix printk format

are found in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/vxy/lksctp-dev.git

Vlad Yasevich (3):
      SCTP: Fix thinko in sctp_copy_laddrs()
      SCTP: Check to make sure file is valid before setting timeout
      SCTP: Add scope_id validation for link-local binds

 net/sctp/ipv6.c   |    4 ++++
 net/sctp/socket.c |   12 +++++++++---
 2 files changed, 13 insertions(+), 3 deletions(-)
