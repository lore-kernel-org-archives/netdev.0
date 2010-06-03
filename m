From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next-2.6] [PPPOE] fix return value of __pppoe_xmit()
	method.
Date: Thu, 3 Jun 2010 18:02:29 +0300
Message-ID: <AANLkTimW3olb9_3Wo8HvtYRP_LOCEeHDGWuVQvGMvFxd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016e65a085cdaa7770488217eb9
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57623 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755262Ab0FCPDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 11:03:20 -0400
Received: by wyi11 with SMTP id 11so125962wyi.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 08:03:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0016e65a085cdaa7770488217eb9
Content-Type: text/plain; charset=ISO-8859-1

Hi,
 __pppoe_xmit() in drivers/net/pppoe always returns 1.
When the methods fails (via goto abort), it should return 0 and not 1.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

--0016e65a085cdaa7770488217eb9
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g9zprw8u0

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3BwcG9lLmMgYi9kcml2ZXJzL25ldC9wcHBvZS5jCmlu
ZGV4IDgwNWI2NGQuLjdlYmI4ZTggMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L3BwcG9lLmMKKysr
IGIvZHJpdmVycy9uZXQvcHBwb2UuYwpAQCAtOTQ5LDcgKzk0OSw3IEBAIHN0YXRpYyBpbnQgX19w
cHBvZV94bWl0KHN0cnVjdCBzb2NrICpzaywgc3RydWN0IHNrX2J1ZmYgKnNrYikKIAogYWJvcnQ6
CiAJa2ZyZWVfc2tiKHNrYik7Ci0JcmV0dXJuIDE7CisJcmV0dXJuIDA7CiB9CiAKIC8qKioqKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioqKioK
--0016e65a085cdaa7770488217eb9--
