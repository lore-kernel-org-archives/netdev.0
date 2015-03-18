From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 0/3] tipc: small bugfix an support for datagram connect()
Date: Wed, 18 Mar 2015 10:17:40 +0100
Message-ID: <1426670263-30358-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <richard.alpe@ericsson.com>, <jon.maloy@ericsson.com>,
	<ying.xue@windriver.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:51819 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754782AbbCRJWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 05:22:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

Most notable in this series is patch#3 that allows programs to associate
a tipc address with a connectionless (RDM/DGRAM) socket.

Erik Hugne (3):
  tipc: remove redundant call to tipc_node_remove_conn
  tipc: do not report -EHOSTUNREACH for failed local delivery
  tipc: add support for connect() on dgram/rdm sockets

 net/tipc/link.c   |  6 ++++--
 net/tipc/socket.c | 39 ++++++++++++++++++++++++---------------
 2 files changed, 28 insertions(+), 17 deletions(-)

-- 
2.1.4
