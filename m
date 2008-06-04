From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 0/6] [SCTP] Bug fixes
Date: Wed,  4 Jun 2008 14:25:45 -0400
Message-ID: <1212603951-24932-1-git-send-email-vladislav.yasevich@hp.com>
Cc: linux-sctp@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:45193 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbYFDSZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 14:25:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The following is a series of patches that correct the following bugs:
  1.  Correctly pick the a retransmission path when we have more the one
      path, but only 1 is active.

  2.  Fix multiple problems with fast retransmit.  These include: not
      restrating retransmission timers, incorrectly decrementing congestion
      widow, and sending multiple packets during fast retransmit.

  3.  Fix ECN markings when sending over IPv6.  SCTP be default marks
      that it's ECN capable.  I found that it has changed not too long
      ago.

There was also a small cleanup.

Please apply.

Thanks
-vlad
