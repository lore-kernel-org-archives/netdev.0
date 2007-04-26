From: David Howells <dhowells@redhat.com>
Subject: [PATCH 03/14] AF_RXRPC: Make it possible to merely try to cancel
	timers from a module [net-2.6]
Date: Thu, 26 Apr 2007 20:54:31 +0100
Message-ID: <20070426195431.24531.46117.stgit@warthog.cambridge.redhat.com>
References: <20070426195415.24531.78794.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57769 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754984AbXDZTyn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 15:54:43 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3QJsgdZ028317
	for <netdev@vger.kernel.org>; Thu, 26 Apr 2007 15:54:42 -0400
In-Reply-To: <20070426195415.24531.78794.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Export try_to_del_timer_sync() for use by the AF_RXRPC module.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 kernel/timer.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/kernel/timer.c b/kernel/timer.c
index dd6c2c1..b22bd39 100644
--- a/kernel/timer.c
+++ b/kernel/timer.c
@@ -505,6 +505,8 @@ out:
 	return ret;
 }
 
+EXPORT_SYMBOL(try_to_del_timer_sync);
+
 /**
  * del_timer_sync - deactivate a timer and wait for the handler to finish.
  * @timer: the timer to be deactivated

