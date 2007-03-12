From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 13/18][SK_BUFF] xfrm4: use skb_reset_network_header
Date: Mon, 12 Mar 2007 01:27:42 -0300
Message-ID: <39e6f6c70703112127j154805aew334f1d94e7ac73e3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_27592_24906685.1173673662050"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:50832 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965059AbXCLE1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 00:27:43 -0400
Received: by ug-out-1314.google.com with SMTP id 44so2091317uga
        for <netdev@vger.kernel.org>; Sun, 11 Mar 2007 21:27:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_27592_24906685.1173673662050
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Setting it to skb->h.raw, which is valid, in the (to become) old pointer based
world order and in the new world of offset based layer headers.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/ipv4/xfrm4_mode_transport.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

------=_Part_27592_24906685.1173673662050
Content-Type: text/x-patch;
	name=0013-SK_BUFF-xfrm4-use-skb_reset_network_header.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ez6egbx5
Content-Disposition: attachment; filename="0013-SK_BUFF-xfrm4-use-skb_reset_network_header.patch"

RnJvbSAxYmUwNmY3OWEwMWJmNTc3MzdjYWYxYjcyODBlM2IwNzMzNWIwZjdlIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogU2F0LCAxMCBNYXIgMjAwNyAxOTo1OToxNiAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggMTMvMThdIFtTS19CVUZGXSB4ZnJtNDogdXNlIHNrYl9yZXNldF9uZXR3b3JrX2hlYWRlcgoK
U2V0dGluZyBpdCB0byBza2ItPmgucmF3LCB3aGljaCBpcyB2YWxpZCwgaW4gdGhlICh0byBiZWNv
bWUpIG9sZCBwb2ludGVyIGJhc2VkCndvcmxkIG9yZGVyIGFuZCBpbiB0aGUgbmV3IHdvcmxkIG9m
IG9mZnNldCBiYXNlZCBsYXllciBoZWFkZXJzLgoKU2lnbmVkLW9mZi1ieTogQXJuYWxkbyBDYXJ2
YWxobyBkZSBNZWxvIDxhY21lQHJlZGhhdC5jb20+Ci0tLQogbmV0L2lwdjQveGZybTRfbW9kZV90
cmFuc3BvcnQuYyB8ICAgIDYgKysrKy0tCiAxIGZpbGVzIGNoYW5nZWQsIDQgaW5zZXJ0aW9ucygr
KSwgMiBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9uZXQvaXB2NC94ZnJtNF9tb2RlX3RyYW5z
cG9ydC5jIGIvbmV0L2lwdjQveGZybTRfbW9kZV90cmFuc3BvcnQuYwppbmRleCAyOTBjMGYyLi5h
ODIwZGRlIDEwMDY0NAotLS0gYS9uZXQvaXB2NC94ZnJtNF9tb2RlX3RyYW5zcG9ydC5jCisrKyBi
L25ldC9pcHY0L3hmcm00X21vZGVfdHJhbnNwb3J0LmMKQEAgLTUwLDggKzUwLDEwIEBAIHN0YXRp
YyBpbnQgeGZybTRfdHJhbnNwb3J0X2lucHV0KHN0cnVjdCB4ZnJtX3N0YXRlICp4LCBzdHJ1Y3Qg
c2tfYnVmZiAqc2tiKQogewogCWludCBpaGwgPSBza2ItPmRhdGEgLSBza2ItPmgucmF3OwogCi0J
aWYgKHNrYi0+aC5yYXcgIT0gc2tiLT5uaC5yYXcpCi0JCXNrYi0+bmgucmF3ID0gbWVtbW92ZShz
a2ItPmgucmF3LCBza2ItPm5oLnJhdywgaWhsKTsKKwlpZiAoc2tiLT5oLnJhdyAhPSBza2ItPm5o
LnJhdykgeworCQltZW1tb3ZlKHNrYi0+aC5yYXcsIHNrYi0+bmgucmF3LCBpaGwpOworCQlza2It
Pm5oLnJhdyA9IHNrYi0+aC5yYXc7CisJfQogCXNrYi0+bmguaXBoLT50b3RfbGVuID0gaHRvbnMo
c2tiLT5sZW4gKyBpaGwpOwogCXNrYi0+aC5yYXcgPSBza2ItPmRhdGE7CiAJcmV0dXJuIDA7Ci0t
IAoxLjUuMC4yCgo=
------=_Part_27592_24906685.1173673662050--
