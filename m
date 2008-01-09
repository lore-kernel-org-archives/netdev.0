From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6.25] [IPVS] Added include for ip_vs.h for ctl_path (build was broken)
Date: Wed, 9 Jan 2008 13:33:49 +0200
Message-ID: <eb3ff54b0801090333r4c1770dakd65f61e356aa0304@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_11708_9951866.1199878429344"
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:35369 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024AbYAILdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 06:33:52 -0500
Received: by fg-out-1718.google.com with SMTP id e21so228913fga.17
        for <netdev@vger.kernel.org>; Wed, 09 Jan 2008 03:33:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_11708_9951866.1199878429344
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
   The build was broken with this error:
	
  In file included from net/ipv4/ipvs/ip_vs_rr.c:27:
  include/net/ip_vs.h:857: error: array type has incomplete element type
  make[3]: *** [net/ipv4/ipvs/ip_vs_rr.o] Error 1

	This was due to missing include to the header file for ctl_path.
	
	This patch added #include <linux/sysctl.h> to ip_vs_.h to avoid it

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_11708_9951866.1199878429344
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fb7skc170
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2lwX3ZzLmggYi9pbmNsdWRlL25ldC9pcF92cy5oCmlu
ZGV4IDAyYWI3Y2EuLjU2ZjNjOTQgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbmV0L2lwX3ZzLmgKKysr
IGIvaW5jbHVkZS9uZXQvaXBfdnMuaApAQCAtOSw2ICs5LDggQEAKICNpbmNsdWRlIDxhc20vdHlw
ZXMuaD4JCS8qIEZvciBfX3VYWCB0eXBlcyAqLwogI2luY2x1ZGUgPGxpbnV4L3R5cGVzLmg+CS8q
IEZvciBfX2JlWFggdHlwZXMgaW4gdXNlcmxhbmQgKi8KIAorI2luY2x1ZGUgPGxpbnV4L3N5c2N0
bC5oPgkvKiBGb3IgY3RsX3BhdGggKi8KKwogI2RlZmluZSBJUF9WU19WRVJTSU9OX0NPREUJMHgw
MTAyMDEKICNkZWZpbmUgTlZFUlNJT04odmVyc2lvbikJCQlcCiAJKHZlcnNpb24gPj4gMTYpICYg
MHhGRiwJCQlcCg==
------=_Part_11708_9951866.1199878429344--
