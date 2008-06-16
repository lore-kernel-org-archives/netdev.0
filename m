From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6 1/2] ipv4: minor cleanup in net/ipv4/tcp_ipv4.c.
Date: Mon, 16 Jun 2008 12:07:31 +0300
Message-ID: <eb3ff54b0806160207r473055c3y329b6ec66b902572@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_38058_4184544.1213607251674"
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:42241 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755092AbYFPJHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 05:07:33 -0400
Received: by wf-out-1314.google.com with SMTP id 27so5125857wfd.4
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2008 02:07:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_38058_4184544.1213607251674
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

1) Remove ICMP_MIN_LENGTH, as it is unused.

2) Remove unneeded tcp_v4_send_check() declaration.


Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_38058_4184544.1213607251674
Content-Type: text/plain; name=patch1.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fhiudwfv0
Content-Disposition: attachment; filename=patch1.txt

RnJvbSBkMThiMTNmNGYxNDBiMGU0YmI2ODE0MmI1ZjljZWZhNTU4NDFkMGExIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiByb290IDxyb290QHNiYzU0Lihub25lKT4KRGF0ZTogTW9uLCAx
NiBKdW4gMjAwOCAxMTo0NDozMCArMDMwMApTdWJqZWN0OiBbUEFUQ0ggMTIxOS8xMjIwXSB0Y3Bf
aXB2NCBjbGVhbnVwCgoKU2lnbmVkLW9mZi1ieTogcm9vdCA8cm9vdEBzYmM1NC4obm9uZSk+Ci0t
LQogbmV0L2lwdjQvdGNwX2lwdjQuYyB8ICAgIDQgLS0tLQogMSBmaWxlcyBjaGFuZ2VkLCAwIGlu
c2VydGlvbnMoKyksIDQgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbmV0L2lwdjQvdGNwX2lw
djQuYyBiL25ldC9pcHY0L3RjcF9pcHY0LmMKaW5kZXggOTdhMjMwMC4uMTI2OTViZSAxMDA2NDQK
LS0tIGEvbmV0L2lwdjQvdGNwX2lwdjQuYworKysgYi9uZXQvaXB2NC90Y3BfaXB2NC5jCkBAIC04
NSwxMCArODUsNiBAQAogaW50IHN5c2N0bF90Y3BfdHdfcmV1c2UgX19yZWFkX21vc3RseTsKIGlu
dCBzeXNjdGxfdGNwX2xvd19sYXRlbmN5IF9fcmVhZF9tb3N0bHk7CiAKLS8qIENoZWNrIFRDUCBz
ZXF1ZW5jZSBudW1iZXJzIGluIElDTVAgcGFja2V0cy4gKi8KLSNkZWZpbmUgSUNNUF9NSU5fTEVO
R1RIIDgKLQotdm9pZCB0Y3BfdjRfc2VuZF9jaGVjayhzdHJ1Y3Qgc29jayAqc2ssIGludCBsZW4s
IHN0cnVjdCBza19idWZmICpza2IpOwogCiAjaWZkZWYgQ09ORklHX1RDUF9NRDVTSUcKIHN0YXRp
YyBzdHJ1Y3QgdGNwX21kNXNpZ19rZXkgKnRjcF92NF9tZDVfZG9fbG9va3VwKHN0cnVjdCBzb2Nr
ICpzaywKLS0gCjEuNS4zLjMKCg==
------=_Part_38058_4184544.1213607251674--
