From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH 23/31] [CCID3]: Add documentation for socket options
Date: Tue, 20 Mar 2007 20:17:02 -0300
Message-ID: <20070320231702.GL17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:40598 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933822AbXCTXRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:17:06 -0400
Received: by wx-out-0506.google.com with SMTP id h31so67362wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:17:06 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This updates the documentation on CCID3-specific options.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 Documentation/networking/dccp.txt |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/dccp.txt b/Documentation/networking/dccp.txt
index 387482e..4504cc5 100644
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -57,6 +57,16 @@ DCCP_SOCKOPT_SEND_CSCOV is for the receiver and has a different meaning: it
 	coverage value are also acceptable. The higher the number, the more
 	restrictive this setting (see [RFC 4340, sec. 9.2.1]).
 
+The following two options apply to CCID 3 exclusively and are getsockopt()-only.
+In either case, a TFRC info struct (defined in <linux/tfrc.h>) is returned.
+DCCP_SOCKOPT_CCID_RX_INFO
+	Returns a `struct tfrc_rx_info' in optval; the buffer for optval and
+	optlen must be set to at least sizeof(struct tfrc_rx_info).
+DCCP_SOCKOPT_CCID_TX_INFO
+	Returns a `struct tfrc_tx_info' in optval; the buffer for optval and
+	optlen must be set to at least sizeof(struct tfrc_tx_info).
+
+
 Sysctl variables
 ================
 Several DCCP default parameters can be managed by the following sysctls
-- 
1.5.0.3

