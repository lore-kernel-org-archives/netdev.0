From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 05/11] [LLC]: Use skb_reset_mac_header in llc_alloc_frame
Date: Sat, 10 Mar 2007 13:46:17 -0300
Message-ID: <39e6f6c70703100846j64ad407ew684a6b5bac0ee43b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_12163_3483380.1173545177742"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:56103 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767874AbXCJQqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2007 11:46:19 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1698470uga
        for <netdev@vger.kernel.org>; Sat, 10 Mar 2007 08:46:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_12163_3483380.1173545177742
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

skb->head is equal to skb->data after alloc_skb, so reset the mac header while
this is true, i.e. before skb_reserve.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/llc/llc_sap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

------=_Part_12163_3483380.1173545177742
Content-Type: text/x-patch;
	name=0005-LLC-Use-skb_reset_mac_header-in-llc_alloc_frame.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ez4acmz2
Content-Disposition: attachment; filename="0005-LLC-Use-skb_reset_mac_header-in-llc_alloc_frame.patch"

RnJvbSAwMjI2ZTEzM2UyMWQzMThhMDc5NGMwYTVjMDJlMTMxZjYzYWUzYjc2IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogU2F0LCAxMCBNYXIgMjAwNyAxMjoxNDo1NiAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggMDUvMTFdIFtMTENdOiBVc2Ugc2tiX3Jlc2V0X21hY19oZWFkZXIgaW4gbGxjX2FsbG9jX2Zy
YW1lCgpza2ItPmhlYWQgaXMgZXF1YWwgdG8gc2tiLT5kYXRhIGFmdGVyIGFsbG9jX3NrYiwgc28g
cmVzZXQgdGhlIG1hYyBoZWFkZXIgd2hpbGUKdGhpcyBpcyB0cnVlLCBpLmUuIGJlZm9yZSBza2Jf
cmVzZXJ2ZS4KClNpZ25lZC1vZmYtYnk6IEFybmFsZG8gQ2FydmFsaG8gZGUgTWVsbyA8YWNtZUBy
ZWRoYXQuY29tPgotLS0KIG5ldC9sbGMvbGxjX3NhcC5jIHwgICAgMiArLQogMSBmaWxlcyBjaGFu
Z2VkLCAxIGluc2VydGlvbnMoKyksIDEgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbmV0L2xs
Yy9sbGNfc2FwLmMgYi9uZXQvbGxjL2xsY19zYXAuYwppbmRleCAyNjE1ZGM4Li41ZmEzMTExIDEw
MDY0NAotLS0gYS9uZXQvbGxjL2xsY19zYXAuYworKysgYi9uZXQvbGxjL2xsY19zYXAuYwpAQCAt
MzYsMTEgKzM2LDExIEBAIHN0cnVjdCBza19idWZmICpsbGNfYWxsb2NfZnJhbWUoc3RydWN0IHNv
Y2sgKnNrLCBzdHJ1Y3QgbmV0X2RldmljZSAqZGV2KQogCXN0cnVjdCBza19idWZmICpza2IgPSBh
bGxvY19za2IoMTI4LCBHRlBfQVRPTUlDKTsKIAogCWlmIChza2IpIHsKKwkJc2tiX3Jlc2V0X21h
Y19oZWFkZXIoc2tiKTsKIAkJc2tiX3Jlc2VydmUoc2tiLCA1MCk7CiAJCXNrYi0+bmgucmF3ICAg
PSBza2ItPmgucmF3ID0gc2tiLT5kYXRhOwogCQlza2ItPnByb3RvY29sID0gaHRvbnMoRVRIX1Bf
ODAyXzIpOwogCQlza2ItPmRldiAgICAgID0gZGV2OwotCQlza2ItPm1hYy5yYXcgID0gc2tiLT5o
ZWFkOwogCQlpZiAoc2sgIT0gTlVMTCkKIAkJCXNrYl9zZXRfb3duZXJfdyhza2IsIHNrKTsKIAl9
Ci0tIAoxLjUuMC4yCgo=
------=_Part_12163_3483380.1173545177742--
