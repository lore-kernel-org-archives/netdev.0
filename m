From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: [Patch] pktgen: use vzalloc_node() instead of vmalloc_node() + memset()
Date: Sun, 22 May 2011 18:17:11 +0800
Message-ID: <BANLkTimWSEwkoP3GOjZ3C-yG9jZRVM+yNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=20cf3054961d7f025404a3daa8c9
Cc: "David S. Miller" <davem@davemloft.net>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:49957 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805Ab1EVKRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 06:17:12 -0400
Received: by iyb14 with SMTP id 14so3919674iyb.19
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 03:17:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--20cf3054961d7f025404a3daa8c9
Content-Type: text/plain; charset=UTF-8

Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>

---

--20cf3054961d7f025404a3daa8c9
Content-Type: text/x-patch; charset=US-ASCII; name="net-pktgen-use-vzalloc_node.diff"
Content-Disposition: attachment; filename="net-pktgen-use-vzalloc_node.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gnzu21r60

ZGlmZiAtLWdpdCBhL25ldC9jb3JlL3BrdGdlbi5jIGIvbmV0L2NvcmUvcGt0Z2VuLmMKaW5kZXgg
Njc4NzBlOS4uM2I4NWMwZCAxMDA2NDQKLS0tIGEvbmV0L2NvcmUvcGt0Z2VuLmMKKysrIGIvbmV0
L2NvcmUvcGt0Z2VuLmMKQEAgLTM1NDQsMTMgKzM1NDQsMTIgQEAgc3RhdGljIGludCBwa3RnZW5f
YWRkX2RldmljZShzdHJ1Y3QgcGt0Z2VuX3RocmVhZCAqdCwgY29uc3QgY2hhciAqaWZuYW1lKQog
CQlyZXR1cm4gLUVOT01FTTsKIAogCXN0cmNweShwa3RfZGV2LT5vZGV2bmFtZSwgaWZuYW1lKTsK
LQlwa3RfZGV2LT5mbG93cyA9IHZtYWxsb2Nfbm9kZShNQVhfQ0ZMT1dTICogc2l6ZW9mKHN0cnVj
dCBmbG93X3N0YXRlKSwKKwlwa3RfZGV2LT5mbG93cyA9IHZ6YWxsb2Nfbm9kZShNQVhfQ0ZMT1dT
ICogc2l6ZW9mKHN0cnVjdCBmbG93X3N0YXRlKSwKIAkJCQkgICAgICBub2RlKTsKIAlpZiAocGt0
X2Rldi0+Zmxvd3MgPT0gTlVMTCkgewogCQlrZnJlZShwa3RfZGV2KTsKIAkJcmV0dXJuIC1FTk9N
RU07CiAJfQotCW1lbXNldChwa3RfZGV2LT5mbG93cywgMCwgTUFYX0NGTE9XUyAqIHNpemVvZihz
dHJ1Y3QgZmxvd19zdGF0ZSkpOwogCiAJcGt0X2Rldi0+cmVtb3ZhbF9tYXJrID0gMDsKIAlwa3Rf
ZGV2LT5taW5fcGt0X3NpemUgPSBFVEhfWkxFTjsK
--20cf3054961d7f025404a3daa8c9--
