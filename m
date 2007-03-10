From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 06/11] [LLC]: Use skb_reset_mac_header in llc_mac_hdr_init
Date: Sat, 10 Mar 2007 13:46:22 -0300
Message-ID: <39e6f6c70703100846i4f62401ar63080f87da05696@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_12171_17974761.1173545182879"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:56103 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767877AbXCJQqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2007 11:46:24 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1698470uga
        for <netdev@vger.kernel.org>; Sat, 10 Mar 2007 08:46:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_12171_17974761.1173545182879
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

skb_push updates and returns skb->data, so we can just call
skb_reset_mac_header after the call to skb_push.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/llc/llc_output.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

------=_Part_12171_17974761.1173545182879
Content-Type: text/x-patch;
	name=0006-LLC-Use-skb_reset_mac_header-in-llc_mac_hdr_init.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ez4adckk
Content-Disposition: attachment; filename="0006-LLC-Use-skb_reset_mac_header-in-llc_mac_hdr_init.patch"

RnJvbSAzZmRiMmZlZjk2Yzg1MjUzMzY5NzRmOWMyY2E0NzllMjdmODFhNDU5IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogU2F0LCAxMCBNYXIgMjAwNyAxMjoxNzoyOSAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggMDYvMTFdIFtMTENdOiBVc2Ugc2tiX3Jlc2V0X21hY19oZWFkZXIgaW4gbGxjX21hY19oZHJf
aW5pdAoKc2tiX3B1c2ggdXBkYXRlcyBhbmQgcmV0dXJucyBza2ItPmRhdGEsIHNvIHdlIGNhbiBq
dXN0IGNhbGwKc2tiX3Jlc2V0X21hY19oZWFkZXIgYWZ0ZXIgdGhlIGNhbGwgdG8gc2tiX3B1c2gu
CgpTaWduZWQtb2ZmLWJ5OiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0LmNv
bT4KLS0tCiBuZXQvbGxjL2xsY19vdXRwdXQuYyB8ICAgIDYgKysrKy0tCiAxIGZpbGVzIGNoYW5n
ZWQsIDQgaW5zZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9uZXQvbGxj
L2xsY19vdXRwdXQuYyBiL25ldC9sbGMvbGxjX291dHB1dC5jCmluZGV4IDcyOWUyNTEuLjc1NGY0
ZmUgMTAwNjQ0Ci0tLSBhL25ldC9sbGMvbGxjX291dHB1dC5jCisrKyBiL25ldC9sbGMvbGxjX291
dHB1dC5jCkBAIC00MSw3ICs0MSw4IEBAIGludCBsbGNfbWFjX2hkcl9pbml0KHN0cnVjdCBza19i
dWZmICpza2IsCiAJCXN0cnVjdCBuZXRfZGV2aWNlICpkZXYgPSBza2ItPmRldjsKIAkJc3RydWN0
IHRyaF9oZHIgKnRyaDsKIAotCQlza2ItPm1hYy5yYXcgPSBza2JfcHVzaChza2IsIHNpemVvZigq
dHJoKSk7CisJCXNrYl9wdXNoKHNrYiwgc2l6ZW9mKCp0cmgpKTsKKwkJc2tiX3Jlc2V0X21hY19o
ZWFkZXIoc2tiKTsKIAkJdHJoID0gdHJfaGRyKHNrYik7CiAJCXRyaC0+YWMgPSBBQzsKIAkJdHJo
LT5mYyA9IExMQ19GUkFNRTsKQEAgLTYyLDcgKzYzLDggQEAgaW50IGxsY19tYWNfaGRyX2luaXQo
c3RydWN0IHNrX2J1ZmYgKnNrYiwKIAkJdW5zaWduZWQgc2hvcnQgbGVuID0gc2tiLT5sZW47CiAJ
CXN0cnVjdCBldGhoZHIgKmV0aDsKIAotCQlza2ItPm1hYy5yYXcgPSBza2JfcHVzaChza2IsIHNp
emVvZigqZXRoKSk7CisJCXNrYl9wdXNoKHNrYiwgc2l6ZW9mKCpldGgpKTsKKwkJc2tiX3Jlc2V0
X21hY19oZWFkZXIoc2tiKTsKIAkJZXRoID0gZXRoX2hkcihza2IpOwogCQlldGgtPmhfcHJvdG8g
PSBodG9ucyhsZW4pOwogCQltZW1jcHkoZXRoLT5oX2Rlc3QsIGRhLCBFVEhfQUxFTik7Ci0tIAox
LjUuMC4yCgo=
------=_Part_12171_17974761.1173545182879--
