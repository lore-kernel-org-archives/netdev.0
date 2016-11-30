From: Bernhard Held <berny156@gmx.de>
Subject: [PATCH] tcp_bbr: fix Kconfig to be able to make BBR the default
 congestion algorithm
Date: Wed, 30 Nov 2016 23:31:29 +0100
Message-ID: <b37e4220-b857-4853-f2e2-b77bb08115e5@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>
To: "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add missing line to be able to make BBR the default
congestion algorithm.

Signed-off-by: Bernhard Held <berny156@gmx.de>
---
  net/ipv4/Kconfig | 1 +
  1 file changed, 1 insertion(+)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 300b068..b54b3ca 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -715,6 +715,7 @@ config DEFAULT_TCP_CONG
         default "reno" if DEFAULT_RENO
         default "dctcp" if DEFAULT_DCTCP
         default "cdg" if DEFAULT_CDG
+       default "bbr" if DEFAULT_BBR
         default "cubic"

  config TCP_MD5SIG
