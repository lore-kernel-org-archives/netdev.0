From: "Jouke Witteveen" <j.witteveen@gmail.com>
Subject: [PATCH] Move if_mii to userspace in mii.h
Date: Wed, 5 Nov 2008 10:42:35 +0100
Message-ID: <3993a4980811050142u913819ek5ef7824efce45a1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_22765_24110666.1225878156085"
Cc: wtarreau@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:4528 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753682AbYKEJmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 04:42:37 -0500
Received: by yx-out-2324.google.com with SMTP id 8so1356880yxm.1
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2008 01:42:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_22765_24110666.1225878156085
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Dear all,

There is a convenient routine in include/linux/mii.h called if_mii. It
is, however, kept away from userspace. A patch is attached that moves
it back to userspace so that it can be included from outside the
kernel.

Note that the current mii.h in kernel 2.4 does not hide the function.

Regards,
Jouke Witteveen

------=_Part_22765_24110666.1225878156085
Content-Type: application/octet-stream; name=include-linux-mii.h.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fn5s2b580
Content-Disposition: attachment; filename=include-linux-mii.h.patch

LS0tIGluY2x1ZGUtbGludXgtbWlpLmgub3JpZwkyMDA4LTExLTA1IDEwOjMxOjQ5LjAwMDAwMDAw
MCArMDEwMAorKysgaW5jbHVkZS1saW51eC1taWkuaAkyMDA4LTExLTA1IDEwOjMyOjQxLjAwMDAw
MDAwMCArMDEwMApAQCAtMTQzLDYgKzE0MywxMSBAQAogCV9fdTE2CQl2YWxfb3V0OwogfTsKIAor
c3RhdGljIGlubGluZSBzdHJ1Y3QgbWlpX2lvY3RsX2RhdGEgKmlmX21paShzdHJ1Y3QgaWZyZXEg
KnJxKQoreworCXJldHVybiAoc3RydWN0IG1paV9pb2N0bF9kYXRhICopICZycS0+aWZyX2lmcnU7
Cit9CisKICNpZmRlZiBfX0tFUk5FTF9fIAogCiAjaW5jbHVkZSA8bGludXgvaWYuaD4KQEAgLTE3
OCwxMiArMTgzLDYgQEAKIAkJCSAgICAgdW5zaWduZWQgaW50ICpkdXBsZXhfY2hhbmdlZCk7CiAK
IAotc3RhdGljIGlubGluZSBzdHJ1Y3QgbWlpX2lvY3RsX2RhdGEgKmlmX21paShzdHJ1Y3QgaWZy
ZXEgKnJxKQotewotCXJldHVybiAoc3RydWN0IG1paV9pb2N0bF9kYXRhICopICZycS0+aWZyX2lm
cnU7Ci19Ci0KLQogLyoqCiAgKiBtaWlfbndheV9yZXN1bHQKICAqIEBuZWdvdGlhdGVkOiB2YWx1
ZSBvZiBNSUkgQU5BUiBhbmQnZCB3aXRoIEFOTFBBUgo=
------=_Part_22765_24110666.1225878156085--
