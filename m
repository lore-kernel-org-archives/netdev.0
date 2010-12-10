From: Shirley Ma <mashirle@us.ibm.com>
Subject: [RFC PATCH V2 1/5] Add a new sock flag for zero-copy
Date: Fri, 10 Dec 2010 01:55:24 -0800
Message-ID: <1291974924.2167.28.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Shirley Ma <xma@us.ibm.com>

 include/net/sock.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index a6338d0..ff34ea7 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -543,6 +543,7 @@ enum sock_flags {
 	SOCK_TIMESTAMPING_SYS_HARDWARE, /* %SOF_TIMESTAMPING_SYS_HARDWARE */
 	SOCK_FASYNC, /* fasync() active */
 	SOCK_RXQ_OVFL,
+	SOCK_ZEROCOPY,
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
