From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] lsm: add the missing documentation for the
 security_skb_owned_by() hook
Date: Wed, 10 Apr 2013 15:34:14 -0400
Message-ID: <20130410193414.11364.7314.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unfortunately we didn't catch the missing comments earlier when the
patch was merged.

Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 include/linux/security.h |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/security.h b/include/linux/security.h
index eee7478..9284c84 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1012,6 +1012,10 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	This hook can be used by the module to update any security state
  *	associated with the TUN device's security structure.
  *	@security pointer to the TUN devices's security structure.
+ * @skb_owned_by:
+ *	This hook sets the packet's owning sock.
+ *	@skb is the packet.
+ *	@sk the sock which owns the packet.
  *
  * Security hooks for XFRM operations.
  *

