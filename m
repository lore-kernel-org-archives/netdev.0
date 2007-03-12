From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 03/18][IPV6]: Use skb->nh.ipv6h instead of casting skb->nh.raw
Date: Mon, 12 Mar 2007 01:26:45 -0300
Message-ID: <39e6f6c70703112126w5d827c35q6fef5f5cc4da0c58@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_27548_27832061.1173673605101"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:50832 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965034AbXCLE0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 00:26:46 -0400
Received: by ug-out-1314.google.com with SMTP id 44so2091317uga
        for <netdev@vger.kernel.org>; Sun, 11 Mar 2007 21:26:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_27548_27832061.1173673605101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

nh.ipv6h is there exactly for this reason! Use it while it exists ;-)

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/ipv6/exthdrs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

------=_Part_27548_27832061.1173673605101
Content-Type: text/x-patch;
	name=0003-IPV6-Use-skb-nh.ipv6h-instead-of-casting-skb-nh.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ez6e9u2n
Content-Disposition: attachment; filename="0003-IPV6-Use-skb-nh.ipv6h-instead-of-casting-skb-nh.patch"

RnJvbSA0NWUxMTQ2Y2E5NzYzZjQ1MDI3NzI2MGQ5YzQxZjJiMmU4M2I2ZDRlIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogU2F0LCAxMCBNYXIgMjAwNyAxNjoyMTo0NSAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggMDMvMThdIFtJUFY2XTogVXNlIHNrYi0+bmguaXB2NmggaW5zdGVhZCBvZiBjYXN0aW5nIHNr
Yi0+bmgucmF3CgpuaC5pcHY2aCBpcyB0aGVyZSBleGFjdGx5IGZvciB0aGlzIHJlYXNvbiEgVXNl
IGl0IHdoaWxlIGl0IGV4aXN0cyA7LSkKClNpZ25lZC1vZmYtYnk6IEFybmFsZG8gQ2FydmFsaG8g
ZGUgTWVsbyA8YWNtZUByZWRoYXQuY29tPgotLS0KIG5ldC9pcHY2L2V4dGhkcnMuYyB8ICAgIDIg
Ky0KIDEgZmlsZXMgY2hhbmdlZCwgMSBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9ucygtKQoKZGlm
ZiAtLWdpdCBhL25ldC9pcHY2L2V4dGhkcnMuYyBiL25ldC9pcHY2L2V4dGhkcnMuYwppbmRleCBl
ODhiZWZkLi4zMmI1NTYwIDEwMDY0NAotLS0gYS9uZXQvaXB2Ni9leHRoZHJzLmMKKysrIGIvbmV0
L2lwdjYvZXh0aGRycy5jCkBAIC0yMDAsNyArMjAwLDcgQEAgc3RhdGljIGludCBpcHY2X2Rlc3Rf
aGFvKHN0cnVjdCBza19idWZmICoqc2ticCwgaW50IG9wdG9mZikKIAlzdHJ1Y3Qgc2tfYnVmZiAq
c2tiID0gKnNrYnA7CiAJc3RydWN0IGlwdjZfZGVzdG9wdF9oYW8gKmhhbzsKIAlzdHJ1Y3QgaW5l
dDZfc2tiX3Bhcm0gKm9wdCA9IElQNkNCKHNrYik7Ci0Jc3RydWN0IGlwdjZoZHIgKmlwdjZoID0g
KHN0cnVjdCBpcHY2aGRyICopc2tiLT5uaC5yYXc7CisJc3RydWN0IGlwdjZoZHIgKmlwdjZoID0g
c2tiLT5uaC5pcHY2aDsKIAlzdHJ1Y3QgaW42X2FkZHIgdG1wX2FkZHI7CiAJaW50IHJldDsKIAot
LSAKMS41LjAuMgoK
------=_Part_27548_27832061.1173673605101--
