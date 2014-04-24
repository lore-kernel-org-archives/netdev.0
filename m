From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next v2 0/2] tipc: add support for link state subscriptions
Date: Thu, 24 Apr 2014 16:26:45 +0200
Message-ID: <1398349607-16012-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	<richard.alpe@ericsson.com>, Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:42994 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756018AbaDXOZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 10:25:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

Low level topology information like TIPC link up/down is useful for
applications like teamd to make smarter failover decisions in a
HA cluster environment. Fetching logical link names through an ioctl
may hurt the eyes of some. Suggestions for a more elegant way of doing
this would be appreciated in that case. :)

v2: 
   -Properly based on net-next
   -Off-list comments from Billie Alsup:
    -Add a string length parameter to tipc_node_get_linkname
    -Use TIPC_MAX_LINK_NAME definition instead of hardcoded
     value in tipc_sioc_ln_req linkname

Erik Hugne (2):
  tipc: add support for link state subscriptions
  tipc: add ioctl to fetch link names

 include/uapi/linux/tipc.h        | 23 +++++++++++++++++++++++
 include/uapi/linux/tipc_config.h | 10 +---------
 net/tipc/node.c                  | 33 ++++++++++++++++++++++++++++++++-
 net/tipc/node.h                  |  1 +
 net/tipc/socket.c                | 29 ++++++++++++++++++++++++++---
 5 files changed, 83 insertions(+), 13 deletions(-)

-- 
1.8.3.2
