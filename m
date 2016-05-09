From: Christian Kujau <lists@nerdbynature.de>
Subject: networking/ip-sysctl.txt: SRR or SSRR
Date: Sun, 8 May 2016 18:23:59 -0700 (PDT)
Message-ID: <alpine.DEB.2.20.12.1605081823420.3193@trent.utfs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from trent.utfs.org ([94.185.90.103]:37162 "EHLO trent.utfs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750885AbcEIBbc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2016 21:31:32 -0400
Received: from localhost (localhost [127.0.0.1])
	by trent.utfs.org (Postfix) with ESMTP id 6CA123DC89
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 03:23:59 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In Documentation/networking/ip-sysctl.txt, the accept_source_route 
parameter is described with:

  Accept packets with SRR option.

I could not find anything describing an "SRR option". The closest thing 
was something called "SSR - Strict Source Route"[0] - is that what is 
meant here? If so, RFC791 then refers to the same as "SSRR", as in "strict 
source and record route". Does the patch below clears that up or did I 
confuse it with something else?

Thanks,
Christian.

Signed-off-by: Christian Kujau <lists@nerdbynature.de>

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index b183e2b..db6b538 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1057,9 +1057,9 @@ bootp_relay - BOOLEAN
 	Not Implemented Yet.
 
 accept_source_route - BOOLEAN
-	Accept packets with SRR option.
+	Accept packets with SSRR option (RFC791 3.1).
 	conf/all/accept_source_route must also be set to TRUE to accept packets
-	with SRR option on the interface
+	with SSRR option on the interface
 	default TRUE (router)
 		FALSE (host)
 

[0] https://www.iana.org/assignments/ip-parameters/ip-parameters.xhtml
-- 
BOFH excuse #224:

Jan  9 16:41:27 huber su: 'su root' succeeded for .... on /dev/pts/1
