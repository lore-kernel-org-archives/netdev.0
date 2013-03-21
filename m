From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH 0/4] ss: Get netlink sockets info via sock-diag
Date: Thu, 21 Mar 2013 13:33:22 +0400
Message-ID: <1363858406-1489-1-git-send-email-avagin@openvz.org>
References: <1363857669-19990-1-git-send-email-avagin@openvz.org>
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Andrey Vagin <avagin@openvz.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:31021 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752151Ab3CUJfD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Mar 2013 05:35:03 -0400
In-Reply-To: <1363857669-19990-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Stephen Hemminger <stephen@networkplumber.org>

Andrey Vagin (4):
  ss: handle socket diag request in a separate function
  ss: create a frunction to print info about netlink sockets
  ss: show destination address for netlink sockets
  ss: Get netlink sockets info via sock-diag

 include/linux/netlink_diag.h |  40 ++++++++
 misc/ss.c                    | 235 +++++++++++++++++++++++++++++--------------
 2 files changed, 198 insertions(+), 77 deletions(-)
 create mode 100644 include/linux/netlink_diag.h

-- 
1.7.11.7
