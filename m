From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH] [PPPOL2TP] Label unused warning when CONFIG_PROC_FS is not set.
Date: Tue, 5 Feb 2008 14:15:34 +0200
Message-ID: <eb3ff54b0802050415h3c4672b1r7048143b599303dd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_6456_4426760.1202213734294"
To: netdev@vger.kernel.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:23353 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799AbYBEMPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 07:15:35 -0500
Received: by fg-out-1718.google.com with SMTP id e21so2184281fga.17
        for <netdev@vger.kernel.org>; Tue, 05 Feb 2008 04:15:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_6456_4426760.1202213734294
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

When CONFIG_PROC_FS is not set and CONFIG_PPPOL2TP is set,
we have the following warning in build:
  drivers/net/pppol2tp.c: In function 'pppol2tp_init':
  drivers/net/pppol2tp.c:2472: warning: label
'out_unregister_pppox_proto' defined but not used

This patches fixes this warning by adding appropriate #ifdef.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_6456_4426760.1202213734294
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fcaexqwq0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3BwcG9sMnRwLmMgYi9kcml2ZXJzL25ldC9wcHBvbDJ0
cC5jCmluZGV4IDFiNTFiYjYuLjVhYTBhODAgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L3BwcG9s
MnRwLmMKKysrIGIvZHJpdmVycy9uZXQvcHBwb2wydHAuYwpAQCAtMjQ2OCw5ICsyNDY4LDEwIEBA
IHN0YXRpYyBpbnQgX19pbml0IHBwcG9sMnRwX2luaXQodm9pZCkKIAogb3V0OgogCXJldHVybiBl
cnI7Ci0KKyNpZmRlZiBDT05GSUdfUFJPQ19GUwogb3V0X3VucmVnaXN0ZXJfcHBwb3hfcHJvdG86
CiAJdW5yZWdpc3Rlcl9wcHBveF9wcm90byhQWF9QUk9UT19PTDJUUCk7CisjZW5kaWYKIG91dF91
bnJlZ2lzdGVyX3BwcG9sMnRwX3Byb3RvOgogCXByb3RvX3VucmVnaXN0ZXIoJnBwcG9sMnRwX3Nr
X3Byb3RvKTsKIAlnb3RvIG91dDsK
------=_Part_6456_4426760.1202213734294--
