From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm tree with the net-next tree
Date: Tue, 7 Feb 2017 16:23:22 +1100
Message-ID: <20170207162322.3732a5a1@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Masahiro Yamada <yamada.masahiro@socionext.com>
To: Andrew Morton <akpm@linux-foundation.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Today's linux-next merge of the akpm tree got a conflict in:

  drivers/net/can/flexcan.c

between commits:

  9eb7aa891101 ("can: flexcan: add quirk FLEXCAN_QUIRK_ENABLE_EACEN_RRS")
  b3cf53e988ce ("can: flexcan: add support for timestamp based rx-offload")

from the net-next tree and commit:

  "scripts/spelling.txt: add "disble(d)" pattern and fix typo instances"

from the akpm tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/can/flexcan.c
index ea57fed375c6,4dc71bce525c..000000000000
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@@ -195,9 -189,7 +195,9 @@@
   */
  #define FLEXCAN_QUIRK_BROKEN_ERR_STATE	BIT(1) /* [TR]WRN_INT not connected */
  #define FLEXCAN_QUIRK_DISABLE_RXFG	BIT(2) /* Disable RX FIFO Global mask */
 -#define FLEXCAN_QUIRK_DISABLE_MECR	BIT(3) /* Disable Memory error detection */
 +#define FLEXCAN_QUIRK_ENABLE_EACEN_RRS	BIT(3) /* Enable EACEN and RRS bit in ctrl2 */
- #define FLEXCAN_QUIRK_DISABLE_MECR	BIT(4) /* Disble Memory error detection */
++#define FLEXCAN_QUIRK_DISABLE_MECR	BIT(4) /* Disbale Memory error detection */
 +#define FLEXCAN_QUIRK_USE_OFF_TIMESTAMP	BIT(5) /* Use timestamp based offloading */
  
  /* Structure of the message buffer */
  struct flexcan_mb {
