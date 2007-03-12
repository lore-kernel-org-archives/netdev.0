From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 07/18][SK_BUFF]: Use skb_reset_network_header where the return of __pskb_pull was being used
Date: Mon, 12 Mar 2007 01:27:10 -0300
Message-ID: <39e6f6c70703112127o7908e75av39789dcc99c9cd61@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_27564_4189641.1173673630023"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:50832 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965039AbXCLE1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 00:27:11 -0400
Received: by ug-out-1314.google.com with SMTP id 44so2091317uga
        for <netdev@vger.kernel.org>; Sun, 11 Mar 2007 21:27:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_27564_4189641.1173673630023
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

It returns skb->data, so we can just use skb_reset_network_header after it.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/ipv4/ip_gre.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

------=_Part_27564_4189641.1173673630023
Content-Type: text/x-patch;
	name=0007-SK_BUFF-Use-skb_reset_network_header-where-the-re.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ez6ebdk5
Content-Disposition: attachment; filename="0007-SK_BUFF-Use-skb_reset_network_header-where-the-re.patch"

RnJvbSA1OTkzMTI5ZjIxMTMzMTViNDZmNTA0NWQyYTdjMzMzYTI0ZjNhZTFiIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogU2F0LCAxMCBNYXIgMjAwNyAxODo0MjowMyAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggMDcvMThdIFtTS19CVUZGXTogVXNlIHNrYl9yZXNldF9uZXR3b3JrX2hlYWRlciB3aGVyZSB0
aGUgcmV0dXJuIG9mIF9fcHNrYl9wdWxsIHdhcyBiZWluZyB1c2VkCgpJdCByZXR1cm5zIHNrYi0+
ZGF0YSwgc28gd2UgY2FuIGp1c3QgdXNlIHNrYl9yZXNldF9uZXR3b3JrX2hlYWRlciBhZnRlciBp
dC4KClNpZ25lZC1vZmYtYnk6IEFybmFsZG8gQ2FydmFsaG8gZGUgTWVsbyA8YWNtZUByZWRoYXQu
Y29tPgotLS0KIG5ldC9pcHY0L2lwX2dyZS5jIHwgICAgMyArKy0KIDEgZmlsZXMgY2hhbmdlZCwg
MiBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL25ldC9pcHY0L2lw
X2dyZS5jIGIvbmV0L2lwdjQvaXBfZ3JlLmMKaW5kZXggZjg0Y2E2Ni4uN2M2ZmRhNiAxMDA2NDQK
LS0tIGEvbmV0L2lwdjQvaXBfZ3JlLmMKKysrIGIvbmV0L2lwdjQvaXBfZ3JlLmMKQEAgLTYxNyw3
ICs2MTcsOCBAQCBzdGF0aWMgaW50IGlwZ3JlX3JjdihzdHJ1Y3Qgc2tfYnVmZiAqc2tiKQogCQl9
CiAKIAkJc2tiX3Jlc2V0X21hY19oZWFkZXIoc2tiKTsKLQkJc2tiLT5uaC5yYXcgPSBfX3Bza2Jf
cHVsbChza2IsIG9mZnNldCk7CisJCV9fcHNrYl9wdWxsKHNrYiwgb2Zmc2V0KTsKKwkJc2tiX3Jl
c2V0X25ldHdvcmtfaGVhZGVyKHNrYik7CiAJCXNrYl9wb3N0cHVsbF9yY3N1bShza2IsIHNrYi0+
aC5yYXcsIG9mZnNldCk7CiAJCXNrYi0+cGt0X3R5cGUgPSBQQUNLRVRfSE9TVDsKICNpZmRlZiBD
T05GSUdfTkVUX0lQR1JFX0JST0FEQ0FTVAotLSAKMS41LjAuMgoK
------=_Part_27564_4189641.1173673630023--
