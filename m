From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net-next 0/2] Xen network: split event channels support
Date: Tue, 21 May 2013 00:02:09 +0100
Message-ID: <1369090931-27306-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:50183 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755400Ab3ETXCN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 May 2013 19:02:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds a new feature called split event channels.

In the original implementation, only one event channel is setup between
frontend and backend. This is not ideal as TX notification interferes with RX
notification. Using dedicated event channels for TX and RX solves this issue.

Wei Liu (2):
  xen-netback: split event channels feature support
  xen-netfront: split event channels feature support

 drivers/net/xen-netback/common.h    |   11 ++-
 drivers/net/xen-netback/interface.c |   87 ++++++++++++++---
 drivers/net/xen-netback/netback.c   |    7 +-
 drivers/net/xen-netback/xenbus.c    |   40 ++++++--
 drivers/net/xen-netfront.c          |  181 +++++++++++++++++++++++++++++------
 5 files changed, 269 insertions(+), 57 deletions(-)

-- 
1.7.10.4
