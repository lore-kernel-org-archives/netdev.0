From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] net: fix up hash documentation
Date: Tue, 6 Jun 2017 19:01:37 +0300
Message-ID: <1496764881-12502-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Tom Herbert <therbert@google.com>,
        Jonathan Corbet <corbet@lwn.net>, netdev@vger.kernel.org,
        David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 61b905da33 ("net: Rename skb->rxhash to skb->hash")
didn't update the documentation, fix this up.

Cc: Tom Herbert <therbert@google.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 Documentation/networking/scaling.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/networking/scaling.txt b/Documentation/networking/scaling.txt
index 59f4db2..f55639d 100644
--- a/Documentation/networking/scaling.txt
+++ b/Documentation/networking/scaling.txt
@@ -122,7 +122,7 @@ associated flow of the packet. The hash is either provided by hardware
 or will be computed in the stack. Capable hardware can pass the hash in
 the receive descriptor for the packet; this would usually be the same
 hash used for RSS (e.g. computed Toeplitz hash). The hash is saved in
-skb->rx_hash and can be used elsewhere in the stack as a hash of the
+skb->hash and can be used elsewhere in the stack as a hash of the
 packet’s flow.
 
 Each receive hardware queue has an associated list of CPUs to which
-- 
MST
