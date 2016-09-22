From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 6/9] rxrpc: Add ktime_sub_ms() [ver #2]
Date: Thu, 22 Sep 2016 09:22:42 +0100
Message-ID: <147453256225.14579.11409295892023461008.stgit@warthog.procyon.org.uk>
References: <147453251987.14579.17230566511204847506.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147453251987.14579.17230566511204847506.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a ktime_sub_ms() to go with ktime_add_ms() and co. for use in AF_RXRPC
RTT determination.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/ktime.h |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/ktime.h b/include/linux/ktime.h
index 2b6a204bd8d4..aa118bad1407 100644
--- a/include/linux/ktime.h
+++ b/include/linux/ktime.h
@@ -231,6 +231,11 @@ static inline ktime_t ktime_sub_us(const ktime_t kt, const u64 usec)
 	return ktime_sub_ns(kt, usec * NSEC_PER_USEC);
 }
 
+static inline ktime_t ktime_sub_ms(const ktime_t kt, const u64 msec)
+{
+	return ktime_sub_ns(kt, msec * NSEC_PER_MSEC);
+}
+
 extern ktime_t ktime_add_safe(const ktime_t lhs, const ktime_t rhs);
 
 /**
