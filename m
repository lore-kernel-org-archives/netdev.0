From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 1/6] [SK_BUFF] ipmr: Missed one conversion to skb_network_header()
Date: Mon, 12 Mar 2007 22:27:11 -0300
Message-ID: <39e6f6c70703121827g235a4299l5ee66361ed4af251@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_13741_22056025.1173749231754"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:48733 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753003AbXCMB1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 21:27:15 -0400
Received: by ug-out-1314.google.com with SMTP id 44so77684uga
        for <netdev@vger.kernel.org>; Mon, 12 Mar 2007 18:27:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_13741_22056025.1173749231754
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

We can't access skb->nh.raw directly anymore, it will become an offset.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/ipv4/ipmr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

------=_Part_13741_22056025.1173749231754
Content-Type: text/x-patch;
	name=0001-SK_BUFF-ipmr-Missed-one-conversion-to-skb_network.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ez7ns7hi
Content-Disposition: attachment; filename="0001-SK_BUFF-ipmr-Missed-one-conversion-to-skb_network.patch"

RnJvbSA2YTI1ZWFhOGJlNjEzYTI4ZjdkMmE3M2Y3NTQ2OTY2NjFmZGM1NWRiIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogTW9uLCAxMiBNYXIgMjAwNyAyMDowNTozOSAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggMS82XSBbU0tfQlVGRl0gaXBtcjogTWlzc2VkIG9uZSBjb252ZXJzaW9uIHRvIHNrYl9uZXR3
b3JrX2hlYWRlcigpCgpXZSBjYW4ndCBhY2Nlc3Mgc2tiLT5uaC5yYXcgZGlyZWN0bHkgYW55bW9y
ZSwgaXQgd2lsbCBiZWNvbWUgYW4gb2Zmc2V0LgoKU2lnbmVkLW9mZi1ieTogQXJuYWxkbyBDYXJ2
YWxobyBkZSBNZWxvIDxhY21lQHJlZGhhdC5jb20+Ci0tLQogbmV0L2lwdjQvaXBtci5jIHwgICAg
MiArLQogMSBmaWxlcyBjaGFuZ2VkLCAxIGluc2VydGlvbnMoKyksIDEgZGVsZXRpb25zKC0pCgpk
aWZmIC0tZ2l0IGEvbmV0L2lwdjQvaXBtci5jIGIvbmV0L2lwdjQvaXBtci5jCmluZGV4IDhjNGRl
OTIuLmFiYTNmZjAgMTAwNjQ0Ci0tLSBhL25ldC9pcHY0L2lwbXIuYworKysgYi9uZXQvaXB2NC9p
cG1yLmMKQEAgLTU2NCw3ICs1NjQsNyBAQCBzdGF0aWMgaW50IGlwbXJfY2FjaGVfcmVwb3J0KHN0
cnVjdCBza19idWZmICpwa3QsIHZpZmlfdCB2aWZpLCBpbnQgYXNzZXJ0KQogCQlza2JfcHVzaChz
a2IsIHNpemVvZihzdHJ1Y3QgaXBoZHIpKTsKIAkJc2tiX3Jlc2V0X25ldHdvcmtfaGVhZGVyKHNr
Yik7CiAJCXNrYi0+aC5yYXcgPSBza2ItPmRhdGE7Ci0JCW1zZyA9IChzdHJ1Y3QgaWdtcG1zZyAq
KXNrYi0+bmgucmF3OworCQltc2cgPSAoc3RydWN0IGlnbXBtc2cgKilza2JfbmV0d29ya19oZWFk
ZXIoc2tiKTsKIAkJbWVtY3B5KG1zZywgc2tiX25ldHdvcmtfaGVhZGVyKHBrdCksIHNpemVvZihz
dHJ1Y3QgaXBoZHIpKTsKIAkJbXNnLT5pbV9tc2d0eXBlID0gSUdNUE1TR19XSE9MRVBLVDsKIAkJ
bXNnLT5pbV9tYnogPSAwOwotLSAKMS41LjAuMgoK
------=_Part_13741_22056025.1173749231754--
