From: Tony Zelenoff <antonz@parallels.com>
Subject: [PATCH rhel6 0/3] net/netfilter: minor refactoring of conntrack ecache
Date: Tue, 21 Feb 2012 21:26:28 +0400
Message-ID: <1329845191-484662-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <antonz@parallels.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:55548 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532Ab2BUR0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 12:26:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While working at my project, saw some issues that better to refactor and
save a bit of CPU cycles. So, here they are.

Patches based on net-next tree.

Tony Zelenoff (3):
  net/netfilter: whitespace removed
  net/netfilter: refactor notifier registration
  net/netfilter: refactor nf_ct_deliver_cached_events

 net/netfilter/nf_conntrack_ecache.c |   81 +++++++++++++++++------------------
 1 files changed, 39 insertions(+), 42 deletions(-)
