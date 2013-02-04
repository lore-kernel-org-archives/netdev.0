From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [TRIVIAL PATCH V2] Doc: percpu_counter doc code for better readability
Date: Mon, 04 Feb 2013 23:14:12 +0100
Message-ID: <20130204221356.29548.35746.stgit@dragon>
References: <20130204214952.GJ27963@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	joe@perches.com
To: Jiri Kosina <trivial@kernel.org>, Tejun Heo <tj@kernel.org>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130204214952.GJ27963@mtj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Help people reading the percpu_counter code, to notice the ifdef
else statement that seperates CONFIG_SMP.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Tejun Heo <tj@kernel.org>
---

 include/linux/percpu_counter.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/percpu_counter.h b/include/linux/percpu_counter.h
index b9df9ed..d5dd465 100644
--- a/include/linux/percpu_counter.h
+++ b/include/linux/percpu_counter.h
@@ -83,7 +83,7 @@ static inline int percpu_counter_initialized(struct percpu_counter *fbc)
 	return (fbc->counters != NULL);
 }
 
-#else
+#else /* !CONFIG_SMP */
 
 struct percpu_counter {
 	s64 count;
