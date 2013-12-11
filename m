From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 0/7] tipc: cleanups in media and bearer layer
Date: Tue, 10 Dec 2013 20:45:37 -0800
Message-ID: <1386737144-32334-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.ne1.yahoo.com ([98.138.207.11]:45324 "HELO
	smtp104.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750862Ab3LKEqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 23:46:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit series performs a number cleanups in order to make the 
bearer and media part of the code more comprehensible and manageable.


Jon Maloy (2):
  tipc: initiate media type array at compile time
  tipc: improve naming and comment consistency in media layer

Ying Xue (5):
  tipc: eliminate redundant code with kfree_skb_list routine
  tipc: remove TIPC usage of field af_packet_priv in struct net_device
  tipc: relocate common functions from media to bearer
  tipc: eliminate code duplication in media layer
  tipc: remove unused 'blocked' flag from tipc_link struct

 include/linux/netdevice.h |    3 +
 net/tipc/bearer.c         |  292 ++++++++++++++++++++++++++++++++---------
 net/tipc/bearer.h         |   48 +++----
 net/tipc/core.c           |    8 +-
 net/tipc/eth_media.c      |  316 +++------------------------------------------
 net/tipc/ib_media.c       |  309 +++-----------------------------------------
 net/tipc/link.c           |   69 +++-------
 net/tipc/link.h           |    7 -
 net/tipc/node.c           |    6 +-
 9 files changed, 311 insertions(+), 747 deletions(-)

-- 
1.7.9.5
