From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv3 vringh] caif_virtio: Introduce caif over virtio
Date: Mon, 18 Mar 2013 14:16:17 +1030
Message-ID: <87fvzts73q.fsf@rustcorp.com.au>
References: <1363340537-16011-1-git-send-email-erwan.yvin@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linus Walleij <linus.walleij@stericsson.com>,
	netdev <netdev@vger.kernel.org>, Erwan Yvin <erwan.yvin@stericsson.com>,
	virtualization <virtualization@lists.linux-foundation.org>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: Erwan Yvin <erwan.yvin@stericsson.com>,
	"David S. Miller" <davem@davemloft.net>,
	Rusty Russel <rusty@ruscorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1363340537-16011-1-git-send-email-erwan.yvin@stericsson.com>
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

Erwan Yvin <erwan.yvin@stericsson.com> writes:
> From: Erwan Yvin <erwan.yvin@stericsson.com>
>
> Add the CAIF Virtio shared memory driver for talking
> to a modem.

I've added a minor build fix:

caif_virtio: fix compilation

ERROR: "gen_pool_add_virt" [drivers/net/caif/caif_virtio.ko] undefined!
ERROR: "gen_pool_create" [drivers/net/caif/caif_virtio.ko] undefined!
ERROR: "gen_pool_destroy" [drivers/net/caif/caif_virtio.ko] undefined!
ERROR: "gen_pool_free" [drivers/net/caif/caif_virtio.ko] undefined!
ERROR: "gen_pool_alloc" [drivers/net/caif/caif_virtio.ko] undefined!

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/drivers/net/caif/Kconfig b/drivers/net/caif/Kconfig
index 676cfff..893f915 100644
--- a/drivers/net/caif/Kconfig
+++ b/drivers/net/caif/Kconfig
@@ -53,6 +53,7 @@ config CAIF_VIRTIO
 	depends on CAIF
 	select VHOST_RING
 	select VIRTIO
+	select GENERIC_ALLOCATOR
 	default n
 	---help---
 	The caif driver for CAIF over Virtio.
