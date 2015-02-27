From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next v2 0/5] tipc: bug fix and some improvements
Date: Fri, 27 Feb 2015 08:56:53 +0100
Message-ID: <1425023818-12880-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
	<richard.alpe@ericsson.com>, <ying.xue@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:55321 "EHLO
	sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbbB0IBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 03:01:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

Most important is a fix for a nullptr exception that would occur when
name table subscriptions fail. The remaining patches are performance
improvements and cosmetic changes.

v2: remove unnecessary whitespace in patch #2 

Erik Hugne (5):
  tipc: only create header copy for name distr messages
  tipc: fix nullpointer bug when subscribing to events
  tipc: purge links when bearer is disabled
  tipc: rename media/msg related definitions
  tipc: make media address offset a common define

 net/tipc/bearer.c     |  2 +-
 net/tipc/bearer.h     |  5 +++--
 net/tipc/eth_media.c  |  8 +++-----
 net/tipc/ib_media.c   |  2 +-
 net/tipc/msg.h        |  4 ++--
 net/tipc/name_distr.c |  2 +-
 net/tipc/subscr.c     | 23 ++++-------------------
 7 files changed, 15 insertions(+), 31 deletions(-)

-- 
2.1.4
