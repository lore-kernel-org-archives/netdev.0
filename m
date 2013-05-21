From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net-next 0/2 V2] Xen network: split event channels support
Date: Tue, 21 May 2013 19:35:08 +0100
Message-ID: <1369161310-9529-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	<david.vrabel@citrix.com>, Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:43876 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265Ab3EUSfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 14:35:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds a new feature called split event channels.

In the original implementation, only one event channel is setup between
frontend and backend. This is not ideal as TX notification interferes with RX
notification. Using dedicated event channels for TX and RX solves this issue.

Changes since V1:
* change subject lines of commits to be more specific
* add parameter feature_split_event_channels for xen-netback
* remove two dev_info

Wei Liu (2):
  xen-netback: split event channels support for Xen backend driver
  xen-netfront: split event channels support for Xen frontend driver

 drivers/net/xen-netback/common.h    |   13 ++-
 drivers/net/xen-netback/interface.c |   84 ++++++++++++++---
 drivers/net/xen-netback/netback.c   |   14 ++-
 drivers/net/xen-netback/xenbus.c    |   40 ++++++--
 drivers/net/xen-netfront.c          |  173 +++++++++++++++++++++++++++++------
 5 files changed, 266 insertions(+), 58 deletions(-)

-- 
1.7.10.4
