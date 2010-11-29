From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH 3/3] tcp: use TCP_BASE_MSS to set basic mss value
Date: Mon, 29 Nov 2010 14:54:00 +0800
Message-ID: <4CF34E08.9000401@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Network-Maillist <netdev@vger.kernel.org>,
	Shan Wei <shanwei@cn.fujitsu.com>
To: David Miller <davem@davemloft.net>, jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54458 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753341Ab0K2Gzm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Nov 2010 01:55:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP_BASE_MSS initroduced by commit 5d424d5a is defined, but never be used.
So use it to initialise sysctl_tcp_base_mss.

commit 5d424d5a674f782d0659a3b66d951f412901faee
Author: John Heffner <jheffner@psc.edu>
Date:   Mon Mar 20 17:53:41 2006 -0800

    [TCP]: MTU probing

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv4/tcp_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index bb8f547..7f65ce6 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -55,7 +55,7 @@ int sysctl_tcp_workaround_signed_windows __read_mostly = 0;
 int sysctl_tcp_tso_win_divisor __read_mostly = 3;
 
 int sysctl_tcp_mtu_probing __read_mostly = 0;
-int sysctl_tcp_base_mss __read_mostly = 512;
+int sysctl_tcp_base_mss __read_mostly = TCP_BASE_MSS;
 
 /* By default, RFC2861 behavior.  */
 int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
-- 
1.6.3.3
