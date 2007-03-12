From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 09/18][SK_BUFF]: Some more skb_put cases converted to skb_reset_network_header
Date: Mon, 12 Mar 2007 01:27:19 -0300
Message-ID: <39e6f6c70703112127y4e96be1elce1c3b776db419cb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_27572_23020720.1173673639467"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:50832 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965036AbXCLE1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 00:27:21 -0400
Received: by ug-out-1314.google.com with SMTP id 44so2091317uga
        for <netdev@vger.kernel.org>; Sun, 11 Mar 2007 21:27:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_27572_23020720.1173673639467
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/ipv4/ip_output.c   |    3 ++-
 net/ipv4/ip_sockglue.c |    5 +++--
 2 files changed, 5 insertions(+), 3 deletions(-)

------=_Part_27572_23020720.1173673639467
Content-Type: text/x-patch;
	name=0009-SK_BUFF-Some-more-skb_put-cases-converted-to-skb_.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ez6ecjyg
Content-Disposition: attachment; filename="0009-SK_BUFF-Some-more-skb_put-cases-converted-to-skb_.patch"

RnJvbSA4ZWI4YTExNGM0YjFlY2U1YjcxZDFkNTZhNDAwNTMxNjI3YzYzMTI5IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogU2F0LCAxMCBNYXIgMjAwNyAxOToxNToyNSAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggMDkvMThdIFtTS19CVUZGXTogU29tZSBtb3JlIHNrYl9wdXQgY2FzZXMgY29udmVydGVkIHRv
IHNrYl9yZXNldF9uZXR3b3JrX2hlYWRlcgoKU2lnbmVkLW9mZi1ieTogQXJuYWxkbyBDYXJ2YWxo
byBkZSBNZWxvIDxhY21lQHJlZGhhdC5jb20+Ci0tLQogbmV0L2lwdjQvaXBfb3V0cHV0LmMgICB8
ICAgIDMgKystCiBuZXQvaXB2NC9pcF9zb2NrZ2x1ZS5jIHwgICAgNSArKystLQogMiBmaWxlcyBj
aGFuZ2VkLCA1IGluc2VydGlvbnMoKyksIDMgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbmV0
L2lwdjQvaXBfb3V0cHV0LmMgYi9uZXQvaXB2NC9pcF9vdXRwdXQuYwppbmRleCBkMzI5NzE4Li5k
ZGU1MWZiIDEwMDY0NAotLS0gYS9uZXQvaXB2NC9pcF9vdXRwdXQuYworKysgYi9uZXQvaXB2NC9p
cF9vdXRwdXQuYwpAQCAtMTEyNiw3ICsxMTI2LDggQEAgc3NpemVfdAlpcF9hcHBlbmRfcGFnZShz
dHJ1Y3Qgc29jayAqc2ssIHN0cnVjdCBwYWdlICpwYWdlLAogCQkJICoJRmluZCB3aGVyZSB0byBz
dGFydCBwdXR0aW5nIGJ5dGVzLgogCQkJICovCiAJCQlkYXRhID0gc2tiX3B1dChza2IsIGZyYWdo
ZWFkZXJsZW4gKyBmcmFnZ2FwKTsKLQkJCXNrYi0+bmguaXBoID0gaXBoID0gKHN0cnVjdCBpcGhk
ciAqKWRhdGE7CisJCQlza2JfcmVzZXRfbmV0d29ya19oZWFkZXIoc2tiKTsKKwkJCWlwaCA9IHNr
Yi0+bmguaXBoOwogCQkJZGF0YSArPSBmcmFnaGVhZGVybGVuOwogCQkJc2tiLT5oLnJhdyA9IGRh
dGE7CiAKZGlmZiAtLWdpdCBhL25ldC9pcHY0L2lwX3NvY2tnbHVlLmMgYi9uZXQvaXB2NC9pcF9z
b2NrZ2x1ZS5jCmluZGV4IGM1ZTQxNjQuLmY4YWI2NTQgMTAwNjQ0Ci0tLSBhL25ldC9pcHY0L2lw
X3NvY2tnbHVlLmMKKysrIGIvbmV0L2lwdjQvaXBfc29ja2dsdWUuYwpAQCAtMjk2LDggKzI5Niw5
IEBAIHZvaWQgaXBfbG9jYWxfZXJyb3Ioc3RydWN0IHNvY2sgKnNrLCBpbnQgZXJyLCBfX2JlMzIg
ZGFkZHIsIF9fYmUxNiBwb3J0LCB1MzIgaW5mCiAJaWYgKCFza2IpCiAJCXJldHVybjsKIAotCWlw
aCA9IChzdHJ1Y3QgaXBoZHIqKXNrYl9wdXQoc2tiLCBzaXplb2Yoc3RydWN0IGlwaGRyKSk7Ci0J
c2tiLT5uaC5pcGggPSBpcGg7CisJc2tiX3B1dChza2IsIHNpemVvZihzdHJ1Y3QgaXBoZHIpKTsK
Kwlza2JfcmVzZXRfbmV0d29ya19oZWFkZXIoc2tiKTsKKwlpcGggPSBza2ItPm5oLmlwaDsKIAlp
cGgtPmRhZGRyID0gZGFkZHI7CiAKIAlzZXJyID0gU0tCX0VYVF9FUlIoc2tiKTsKLS0gCjEuNS4w
LjIKCg==
------=_Part_27572_23020720.1173673639467--
