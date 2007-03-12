From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 02/18][BONDING]: Introduce arp_pkt()
Date: Mon, 12 Mar 2007 01:26:38 -0300
Message-ID: <39e6f6c70703112126o61e8b69am238fd08e2368da10@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_27544_28405377.1173673598984"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:38258 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965029AbXCLE0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 00:26:41 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1864480nfa
        for <netdev@vger.kernel.org>; Sun, 11 Mar 2007 21:26:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_27544_28405377.1173673598984
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

For consistency with all the other skb->nh.raw accessors.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 drivers/net/bonding/bond_alb.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

------=_Part_27544_28405377.1173673598984
Content-Type: text/x-patch; name=0002-BONDING-Introduce-arp_pkt.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ez6e96ci
Content-Disposition: attachment; filename="0002-BONDING-Introduce-arp_pkt.patch"

RnJvbSAwMTdkOGEzMjYyZDcwZjA0ZGUyMmM2NTNlODBlZjExMzdiYWNiODhiIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogU2F0LCAxMCBNYXIgMjAwNyAxNjowNzoxOSAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggMDIvMThdIFtCT05ESU5HXTogSW50cm9kdWNlIGFycF9wa3QoKQoKRm9yIGNvbnNpc3RlbmN5
IHdpdGggYWxsIHRoZSBvdGhlciBza2ItPm5oLnJhdyBhY2Nlc3NvcnMuCgpTaWduZWQtb2ZmLWJ5
OiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0LmNvbT4KLS0tCiBkcml2ZXJz
L25ldC9ib25kaW5nL2JvbmRfYWxiLmMgfCAgICA5ICsrKysrKystLQogMSBmaWxlcyBjaGFuZ2Vk
LCA3IGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy9u
ZXQvYm9uZGluZy9ib25kX2FsYi5jIGIvZHJpdmVycy9uZXQvYm9uZGluZy9ib25kX2FsYi5jCmlu
ZGV4IDkxNjE2MmMuLjM2YjhlODYgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L2JvbmRpbmcvYm9u
ZF9hbGIuYworKysgYi9kcml2ZXJzL25ldC9ib25kaW5nL2JvbmRfYWxiLmMKQEAgLTEwNCw2ICsx
MDQsMTEgQEAgc3RydWN0IGFycF9wa3QgewogfTsKICNwcmFnbWEgcGFjaygpCiAKK3N0YXRpYyBp
bmxpbmUgc3RydWN0IGFycF9wa3QgKmFycF9wa3QoY29uc3Qgc3RydWN0IHNrX2J1ZmYgKnNrYikK
K3sKKwlyZXR1cm4gKHN0cnVjdCBhcnBfcGt0ICopc2tiLT5uaC5yYXc7Cit9CisKIC8qIEZvcndh
cmQgZGVjbGFyYXRpb24gKi8KIHN0YXRpYyB2b2lkIGFsYl9zZW5kX2xlYXJuaW5nX3BhY2tldHMo
c3RydWN0IHNsYXZlICpzbGF2ZSwgdTggbWFjX2FkZHJbXSk7CiAKQEAgLTYxMyw3ICs2MTgsNyBA
QCBzdGF0aWMgdm9pZCBybGJfcmVxX3VwZGF0ZV9zdWJuZXRfY2xpZW50cyhzdHJ1Y3QgYm9uZGlu
ZyAqYm9uZCwgdTMyIHNyY19pcCkKIHN0YXRpYyBzdHJ1Y3Qgc2xhdmUgKnJsYl9jaG9vc2VfY2hh
bm5lbChzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBzdHJ1Y3QgYm9uZGluZyAqYm9uZCkKIHsKIAlzdHJ1
Y3QgYWxiX2JvbmRfaW5mbyAqYm9uZF9pbmZvID0gJihCT05EX0FMQl9JTkZPKGJvbmQpKTsKLQlz
dHJ1Y3QgYXJwX3BrdCAqYXJwID0gKHN0cnVjdCBhcnBfcGt0ICopc2tiLT5uaC5yYXc7CisJc3Ry
dWN0IGFycF9wa3QgKmFycCA9IGFycF9wa3Qoc2tiKTsKIAlzdHJ1Y3Qgc2xhdmUgKmFzc2lnbmVk
X3NsYXZlOwogCXN0cnVjdCBybGJfY2xpZW50X2luZm8gKmNsaWVudF9pbmZvOwogCXUzMiBoYXNo
X2luZGV4ID0gMDsKQEAgLTcwMSw3ICs3MDYsNyBAQCBzdGF0aWMgc3RydWN0IHNsYXZlICpybGJf
Y2hvb3NlX2NoYW5uZWwoc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3RydWN0IGJvbmRpbmcgKmJvbgog
ICovCiBzdGF0aWMgc3RydWN0IHNsYXZlICpybGJfYXJwX3htaXQoc3RydWN0IHNrX2J1ZmYgKnNr
Yiwgc3RydWN0IGJvbmRpbmcgKmJvbmQpCiB7Ci0Jc3RydWN0IGFycF9wa3QgKmFycCA9IChzdHJ1
Y3QgYXJwX3BrdCAqKXNrYi0+bmgucmF3OworCXN0cnVjdCBhcnBfcGt0ICphcnAgPSBhcnBfcGt0
KHNrYik7CiAJc3RydWN0IHNsYXZlICp0eF9zbGF2ZSA9IE5VTEw7CiAKIAlpZiAoYXJwLT5vcF9j
b2RlID09IF9fY29uc3RhbnRfaHRvbnMoQVJQT1BfUkVQTFkpKSB7Ci0tIAoxLjUuMC4yCgo=
------=_Part_27544_28405377.1173673598984--
