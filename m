From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 0/3] sctp: Fixes for SNMP counters
Date: Thu,  9 Oct 2008 09:29:31 -0400
Message-ID: <1223558975-1550-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:16805 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758564AbYJIN3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 09:29:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The following three patches fix a few SNMP counters.

1) When the Add-Ip timer expires and we tear down the association, the
SCTP_MIB_CURRESTAB should be decremented.

2) When processing a violation and discrding the packet instead of tearning
down the association, do not change SCTP_MIB_ABORTEDS since we didn't really
abort.

3) When the T5-timer expires and we abort the association, count
SCTP_MIB_ABORTEDS.

-vlad
