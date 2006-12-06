From: jamal <hadi@cyberus.ca>
Subject: [IPROUTE2 PATCH][DOC] clarify "ok" and "pass"
Date: Wed, 06 Dec 2006 12:44:26 -0500
Message-ID: <1165427067.3749.19.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-G7R7kDjOgLGy51aQjpj3"
Cc: Marco Berizzi <pupilla@hotmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.234]:55283 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936942AbWLFRo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 12:44:29 -0500
Received: by wr-out-0506.google.com with SMTP id i7so422611wra
        for <netdev@vger.kernel.org>; Wed, 06 Dec 2006 09:44:29 -0800 (PST)
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-G7R7kDjOgLGy51aQjpj3
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


a small one.
I have a few more but just run out of cycles for now; 
if you dont mind holding before releasing for a short while so i can
get them out I will appreciate it.

cheers,
jamal


--=-G7R7kDjOgLGy51aQjpj3
Content-Disposition: attachment; filename=ipr-doc-p1
Content-Type: text/plain; name=ipr-doc-p1; charset=us-ascii
Content-Transfer-Encoding: 7bit

[DOC]: clarify "ok" and "pass"

A small fixup to elucidate the mysteries of accepting ..

---
commit d3f9d336f524d2aa36442212d72f39de15b1e585
tree cba1f16ca21fd70ad2d2b59b460166929157ba59
parent 241e28d5d5d326d33b2d71752d574e2ae118f671
author Marco Berizzi <pupilla@hotmail.com> Wed, 06 Dec 2006 12:39:19 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Wed, 06 Dec 2006 12:39:19 -0500

 doc/actions/actions-general |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/doc/actions/actions-general b/doc/actions/actions-general
index bb2295d..6561eda 100644
--- a/doc/actions/actions-general
+++ b/doc/actions/actions-general
@@ -65,7 +65,7 @@ action police mtu 4000 rate 1500kbit burst 90k
 { drop, pass, reclassify, continue}
 (If you have others, no listed here give me a reason and we will add them)
 +drop says to drop the packet
-+pass says to accept it
++pass and ok (are equivalent) says to accept it
 +reclassify requests for reclassification of the packet
 +continue requests for next lookup to match
 

--=-G7R7kDjOgLGy51aQjpj3--

