From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6 2/2] ipv6: minor cleanup in net/ipv6/tcp_ipv6.c.
Date: Mon, 16 Jun 2008 12:09:31 +0300
Message-ID: <eb3ff54b0806160209g62d8dec8h90756af506207e37@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_38067_27486383.1213607371685"
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:44645 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757066AbYFPJJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 05:09:33 -0400
Received: by wf-out-1314.google.com with SMTP id 27so5126558wfd.4
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2008 02:09:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_38067_27486383.1213607371685
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

In net/ipv6/tcp_ipv6.c:

1) Remove unneeded tcp_v6_send_check() declaration.

2) Unify two consecutive #ifdef CONFIG_TCP_MD5SIG (with nothing in
   between them) into one #ifdef CONFIG_TCP_MD5SIG.


Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_38067_27486383.1213607371685
Content-Type: text/plain; name=patch2.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fhiugnhn0
Content-Disposition: attachment; filename=patch2.txt

RnJvbSAyMjc0ZDk0ZmFmY2ZhOGUxNDIwZmJhN2I1ZjA4MWNhYTI3ZDg2ODhjIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiByb290IDxyb290QHNiYzU0Lihub25lKT4KRGF0ZTogTW9uLCAx
NiBKdW4gMjAwOCAxMTo0NTowNSArMDMwMApTdWJqZWN0OiBbUEFUQ0ggMTIyMC8xMjIwXSB0Y3Bf
aXB2Ni5jIGNsZWFudXAKCgpTaWduZWQtb2ZmLWJ5OiByb290IDxyb290QHNiYzU0Lihub25lKT4K
LS0tCiBuZXQvaXB2Ni90Y3BfaXB2Ni5jIHwgICAgNSAtLS0tLQogMSBmaWxlcyBjaGFuZ2VkLCAw
IGluc2VydGlvbnMoKyksIDUgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbmV0L2lwdjYvdGNw
X2lwdjYuYyBiL25ldC9pcHY2L3RjcF9pcHY2LmMKaW5kZXggY2I0Njc0OS4uMGE0MzdlMCAxMDA2
NDQKLS0tIGEvbmV0L2lwdjYvdGNwX2lwdjYuYworKysgYi9uZXQvaXB2Ni90Y3BfaXB2Ni5jCkBA
IC03Miw4ICs3Miw2IEBACiAKIHN0YXRpYyB2b2lkCXRjcF92Nl9zZW5kX3Jlc2V0KHN0cnVjdCBz
b2NrICpzaywgc3RydWN0IHNrX2J1ZmYgKnNrYik7CiBzdGF0aWMgdm9pZAl0Y3BfdjZfcmVxc2tf
c2VuZF9hY2soc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3RydWN0IHJlcXVlc3Rfc29jayAqcmVxKTsK
LXN0YXRpYyB2b2lkCXRjcF92Nl9zZW5kX2NoZWNrKHN0cnVjdCBzb2NrICpzaywgaW50IGxlbiwK
LQkJCQkgIHN0cnVjdCBza19idWZmICpza2IpOwogCiBzdGF0aWMgaW50CXRjcF92Nl9kb19yY3Yo
c3RydWN0IHNvY2sgKnNrLCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiKTsKIApAQCAtMTEwMSw5ICsxMDk5
LDYgQEAgc3RhdGljIHZvaWQgdGNwX3Y2X3NlbmRfYWNrKHN0cnVjdCB0Y3BfdGltZXdhaXRfc29j
ayAqdHcsCiAjaWZkZWYgQ09ORklHX1RDUF9NRDVTSUcKIAlzdHJ1Y3QgdGNwX21kNXNpZ19rZXkg
KmtleTsKIAlzdHJ1Y3QgdGNwX21kNXNpZ19rZXkgdHdfa2V5OwotI2VuZGlmCi0KLSNpZmRlZiBD
T05GSUdfVENQX01ENVNJRwogCWlmICghdHcgJiYgc2tiLT5zaykgewogCQlrZXkgPSB0Y3BfdjZf
bWQ1X2RvX2xvb2t1cChza2ItPnNrLCAmaXB2Nl9oZHIoc2tiKS0+ZGFkZHIpOwogCX0gZWxzZSBp
ZiAodHcgJiYgdHctPnR3X21kNV9rZXlsZW4pIHsKLS0gCjEuNS4zLjMKCg==
------=_Part_38067_27486383.1213607371685--
