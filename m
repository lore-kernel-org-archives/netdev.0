From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 0/2] tipc: link state processing improvements
Date: Tue, 1 Jul 2014 10:22:39 +0200
Message-ID: <1404202961-30262-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	<carl.sigurjonsson@ericsson.com>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <jon.maloy@ericsson.com>,
	<ying.xue@windriver.com>, <richard.alpe@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:58954 "EHLO
	sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755903AbaGAITn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 04:19:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

Message delivery is separated from the link state processing, and
we fix a bug in receive-path triggered acks.

Erik Hugne (2):
  tipc: refactor message delivery out of tipc_rcv
  tipc: fix link acknowledge logic in receive path

 net/tipc/link.c | 130 ++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 83 insertions(+), 47 deletions(-)

-- 
1.8.3.2
