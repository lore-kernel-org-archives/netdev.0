From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 10/18][SK_BUFF] ipconfig: Another conversion to skb_reset_network_header related to skb_put
Date: Mon, 12 Mar 2007 01:27:24 -0300
Message-ID: <39e6f6c70703112127n33ad9583uae34886de28cd356@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_27580_2067835.1173673644524"
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:13764 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965044AbXCLE1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 00:27:25 -0400
Received: by an-out-0708.google.com with SMTP id b33so1315886ana
        for <netdev@vger.kernel.org>; Sun, 11 Mar 2007 21:27:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_27580_2067835.1173673644524
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

boot_pkt->iph is the first member, that is at skb->data, so just use
skb_reset_network_header().

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/ipv4/ipconfig.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

------=_Part_27580_2067835.1173673644524
Content-Type: text/x-patch;
	name=0010-SK_BUFF-ipconfig-Another-conversion-to-skb_reset_.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ez6eeypg
Content-Disposition: attachment; filename="0010-SK_BUFF-ipconfig-Another-conversion-to-skb_reset_.patch"

RnJvbSA3MWVjYjQ5NDFiODk3YzcyNGJiN2I5NzYyY2Y0OWQxOTc5NDAzMzYyIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogU2F0LCAxMCBNYXIgMjAwNyAxOToyNzoyNyAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggMTAvMThdIFtTS19CVUZGXSBpcGNvbmZpZzogQW5vdGhlciBjb252ZXJzaW9uIHRvIHNrYl9y
ZXNldF9uZXR3b3JrX2hlYWRlciByZWxhdGVkIHRvIHNrYl9wdXQKCmJvb3RfcGt0LT5pcGggaXMg
dGhlIGZpcnN0IG1lbWJlciwgdGhhdCBpcyBhdCBza2ItPmRhdGEsIHNvIGp1c3QgdXNlCnNrYl9y
ZXNldF9uZXR3b3JrX2hlYWRlcigpLgoKU2lnbmVkLW9mZi1ieTogQXJuYWxkbyBDYXJ2YWxobyBk
ZSBNZWxvIDxhY21lQHJlZGhhdC5jb20+Ci0tLQogbmV0L2lwdjQvaXBjb25maWcuYyB8ICAgIDMg
KystCiAxIGZpbGVzIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbnMoLSkKCmRp
ZmYgLS1naXQgYS9uZXQvaXB2NC9pcGNvbmZpZy5jIGIvbmV0L2lwdjQvaXBjb25maWcuYwppbmRl
eCBjNDM2OTlmLi42ZTg5OTg0IDEwMDY0NAotLS0gYS9uZXQvaXB2NC9pcGNvbmZpZy5jCisrKyBi
L25ldC9pcHY0L2lwY29uZmlnLmMKQEAgLTcwMiw3ICs3MDIsOCBAQCBzdGF0aWMgdm9pZCBfX2lu
aXQgaWNfYm9vdHBfc2VuZF9pZihzdHJ1Y3QgaWNfZGV2aWNlICpkLCB1bnNpZ25lZCBsb25nIGpp
ZmZpZXNfZAogCW1lbXNldChiLCAwLCBzaXplb2Yoc3RydWN0IGJvb3RwX3BrdCkpOwogCiAJLyog
Q29uc3RydWN0IElQIGhlYWRlciAqLwotCXNrYi0+bmguaXBoID0gaCA9ICZiLT5pcGg7CisJc2ti
X3Jlc2V0X25ldHdvcmtfaGVhZGVyKHNrYik7CisJaCA9IHNrYi0+bmguaXBoOwogCWgtPnZlcnNp
b24gPSA0OwogCWgtPmlobCA9IDU7CiAJaC0+dG90X2xlbiA9IGh0b25zKHNpemVvZihzdHJ1Y3Qg
Ym9vdHBfcGt0KSk7Ci0tIAoxLjUuMC4yCgo=
------=_Part_27580_2067835.1173673644524--
