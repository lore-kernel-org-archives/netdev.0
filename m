From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH] Doc: percpu_counter doc code for better readability
Date: Tue, 29 Jan 2013 09:31:56 +0100
Message-ID: <20130129083156.20701.33948.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
To: joe@perches.com, linux-kernel@vger.kernel.org, tj@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27484 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753190Ab3A2I1g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 03:27:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Help people reading the percpu_counter code, to notice the ifdef
else statement that seperates CONFIG_SMP.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/linux/percpu_counter.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/percpu_counter.h b/include/linux/percpu_counter.h
index b9df9ed..eded1aa 100644
--- a/include/linux/percpu_counter.h
+++ b/include/linux/percpu_counter.h
@@ -83,7 +83,7 @@ static inline int percpu_counter_initialized(struct percpu_counter *fbc)
 	return (fbc->counters != NULL);
 }
 
-#else
+#else /* No CONFIG_SMP */
 
 struct percpu_counter {
 	s64 count;
