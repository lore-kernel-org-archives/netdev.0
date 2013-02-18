From: Andy King <acking@vmware.com>
Subject: [PATCH 3/4] VSOCK: Remove hypervisor-only socket option
Date: Mon, 18 Feb 2013 08:04:12 -0800
Message-ID: <1361203453-1347-4-git-send-email-acking@vmware.com>
References: <1361203453-1347-1-git-send-email-acking@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, Andy King <acking@vmware.com>, davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1361203453-1347-1-git-send-email-acking@vmware.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Remove hypervisor-only socket option.

Reported-by: Gerd Hoffmann <kraxel@redhat.com>
Acked-by: Dmitry Torokhov <dtor@vmware.com>
Signed-off-by: Andy King <acking@vmware.com>
---
 include/uapi/linux/vm_sockets.h |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/vm_sockets.h b/include/uapi/linux/vm_sockets.h
index f7f2e99..df91301 100644
--- a/include/uapi/linux/vm_sockets.h
+++ b/include/uapi/linux/vm_sockets.h
@@ -52,14 +52,6 @@
 
 #define SO_VM_SOCKETS_PEER_HOST_VM_ID 3
 
-/* Option name for socket's service label.  Use as the option name in
- * setsockopt(3) or getsockopt(3) to set or get the service label for a socket.
- * The service label is a C-style NUL-terminated string.  Only available for
- * hypervisor endpoints.
- */
-
-#define SO_VM_SOCKETS_SERVICE_LABEL 4
-
 /* Option name for determining if a socket is trusted.  Use as the option name
  * in getsockopt(3) to determine if a socket is trusted.  The value is a
  * signed integer.
-- 
1.7.4.1
