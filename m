From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [SCTP] Bug fixes to the migrate/accept code path.
Date: Thu,  6 Dec 2007 12:48:22 -0500
Message-ID: <1196963304-32494-1-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:6614 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829AbXLFRs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 12:48:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave

The following two patches fix some bugs in the SCTP accept code path.
The first one fixes a slab corruption bug that we found during stress
testing.  The second one is just a clean-up and the right way to do things.

You can also pull both from:
  master.kernel.org:/pub/scm/linux/kernel/git/lksctp-dev.git pending

Thanks
-vlad
