From: Shirley Ma <mashirle@us.ibm.com>
Subject: RFC PATCH 1/2] macvtap: A new sock zero copy flag
Date: Mon, 13 Sep 2010 13:47:01 -0700
Message-ID: <1284410821.13351.13.camel@localhost.localdomain>
References: <1284410580.13351.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>, mst@redhat.com,
	Avi Kivity <avi@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1284410580.13351.10.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

/* Add a new flag to support sock zero copy from user space to kernel */

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---

 include/net/sock.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index adab9dc..80172de 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -543,6 +543,7 @@ enum sock_flags {
 	SOCK_TIMESTAMPING_SYS_HARDWARE, /* %SOF_TIMESTAMPING_SYS_HARDWARE */
 	SOCK_FASYNC, /* fasync() active */
 	SOCK_RXQ_OVFL,
+	SOCK_ZEROCOPY, /* zerocopy from user space to kernel */
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
