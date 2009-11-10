From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv9 3/3] vhost_net: a kernel-level virtio server
Date: Tue, 10 Nov 2009 13:49:09 +1030
Message-ID: <200911101349.09783.rusty@rustcorp.com.au>
References: <cover.1257786516.git.mst@redhat.com> <20091109172230.GD4724@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
 virtualization@lists.linux-foundation.org,
 kvm@vger.kernel.org,
 linux-kernel@vger.kernel.org,
 mingo@elte.hu,
 linux-mm@kvack.org,
 akpm@linux-foundation.org,
 hpa@zytor.com,
 gregory.haskins@gmail.com,
 s.hetze@linux-ag.com,
 Daniel Walker <dwalker@fifo99.com>,
 Eric Dumazet <eric.dumazet@gmail.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20091109172230.GD4724@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

One fix:

vhost: fix TUN=m VHOST_NET=y

	drivers/built-in.o: In function `get_tun_socket':
	net.c:(.text+0x15436e): undefined reference to `tun_get_socket'

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/vhost/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
--- a/drivers/vhost/Kconfig
+++ b/drivers/vhost/Kconfig
@@ -1,6 +1,6 @@
 config VHOST_NET
 	tristate "Host kernel accelerator for virtio net (EXPERIMENTAL)"
-	depends on NET && EVENTFD && EXPERIMENTAL
+	depends on NET && EVENTFD && TUN && EXPERIMENTAL
 	---help---
 	  This kernel module can be loaded in host kernel to accelerate
 	  guest networking with virtio_net. Not to be confused with virtio_net

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
