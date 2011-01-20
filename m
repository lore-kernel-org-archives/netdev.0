From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH clean-up] dccp: clean up unused DCCP_STATE_MASK definition
Date: Thu, 20 Jan 2011 17:12:54 +0800
Message-ID: <4D37FC96.9000407@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: acme@ghostprotocols.net, dccp@vger.kernel.org,
	Network-Maillist <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52133 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754984Ab1ATJQe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jan 2011 04:16:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused DCCP_STATE_MASK macro.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 include/linux/dccp.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 010e2d8..d638e85 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -279,8 +279,6 @@ enum dccp_state {
 	DCCP_MAX_STATES
 };
 
-#define DCCP_STATE_MASK 0x1f
-
 enum {
 	DCCPF_OPEN	      = TCPF_ESTABLISHED,
 	DCCPF_REQUESTING      = TCPF_SYN_SENT,
-- 
1.6.3.3
