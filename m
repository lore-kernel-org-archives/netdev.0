From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: [PATCH trivial] net: add bbr to config DEFAULT_TCP_CONG
Date: Fri, 14 Oct 2016 09:33:33 +0200
Message-ID: <20161014073333.GA10006@x4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud10.udmedia.de ([194.117.254.50]:57718 "EHLO
        mail.ud10.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755693AbcJNHdh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 03:33:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While playing with BBR I noticed that it was missing in the list of
possible config DEFAULT_TCP_CONG choices. Fixed thusly.

Signed-off-by: Markus Trippelsdorf <markus@trippelsdorf.de>

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 300b06888fdf..b54b3ca939db 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -715,6 +715,7 @@ config DEFAULT_TCP_CONG
 	default "reno" if DEFAULT_RENO
 	default "dctcp" if DEFAULT_DCTCP
 	default "cdg" if DEFAULT_CDG
+	default "bbr" if DEFAULT_BBR
 	default "cubic"
 
 config TCP_MD5SIG

-- 
Markus
