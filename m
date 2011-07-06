From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH V8 1/4 net-next] sock.h: Add a new sock zero-copy flag
Date: Wed, 06 Jul 2011 15:17:30 -0700
Message-ID: <1309990650.10209.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, mst@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---

 include/net/sock.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index ae56da6..396f735 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -563,6 +563,7 @@ enum sock_flags {
 	SOCK_TIMESTAMPING_SYS_HARDWARE, /* %SOF_TIMESTAMPING_SYS_HARDWARE */
 	SOCK_FASYNC, /* fasync() active */
 	SOCK_RXQ_OVFL,
+	SOCK_ZEROCOPY, /* buffers from userspace */
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)


