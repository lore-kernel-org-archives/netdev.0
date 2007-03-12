From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 14/18][SK_BUFF] bonding: Set skb->nh.raw relative to skb->mac.raw
Date: Mon, 12 Mar 2007 01:27:46 -0300
Message-ID: <39e6f6c70703112127m1fbae211s6098c946ce32ec32@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_27596_13818313.1173673666719"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:39453 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965044AbXCLE1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 00:27:54 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1864741nfa
        for <netdev@vger.kernel.org>; Sun, 11 Mar 2007 21:27:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_27596_13818313.1173673666719
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 drivers/net/bonding/bond_3ad.c |    4 ++--
 drivers/net/bonding/bond_alb.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

------=_Part_27596_13818313.1173673666719
Content-Type: text/x-patch;
	name=0014-SK_BUFF-bonding-Set-skb-nh.raw-relative-to-skb.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ez6egnlo
Content-Disposition: attachment; filename="0014-SK_BUFF-bonding-Set-skb-nh.raw-relative-to-skb.patch"

RnJvbSBjNzFhZjcwNjhjNjZiY2JjMzc3YjFlNDU5M2ViNThiZWM5NjE2OTljIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogU2F0LCAxMCBNYXIgMjAwNyAyMDowOTo0NSAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggMTQvMThdIFtTS19CVUZGXSBib25kaW5nOiBTZXQgc2tiLT5uaC5yYXcgcmVsYXRpdmUgdG8g
c2tiLT5tYWMucmF3CgpTaWduZWQtb2ZmLWJ5OiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFj
bWVAcmVkaGF0LmNvbT4KLS0tCiBkcml2ZXJzL25ldC9ib25kaW5nL2JvbmRfM2FkLmMgfCAgICA0
ICsrLS0KIGRyaXZlcnMvbmV0L2JvbmRpbmcvYm9uZF9hbGIuYyB8ICAgIDIgKy0KIDIgZmlsZXMg
Y2hhbmdlZCwgMyBpbnNlcnRpb25zKCspLCAzIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2Ry
aXZlcnMvbmV0L2JvbmRpbmcvYm9uZF8zYWQuYyBiL2RyaXZlcnMvbmV0L2JvbmRpbmcvYm9uZF8z
YWQuYwppbmRleCBlM2M5ZTJlLi4wNWM4NzBkIDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC9ib25k
aW5nL2JvbmRfM2FkLmMKKysrIGIvZHJpdmVycy9uZXQvYm9uZGluZy9ib25kXzNhZC5jCkBAIC04
ODUsNyArODg1LDcgQEAgc3RhdGljIGludCBhZF9sYWNwZHVfc2VuZChzdHJ1Y3QgcG9ydCAqcG9y
dCkKIAogCXNrYi0+ZGV2ID0gc2xhdmUtPmRldjsKIAlza2JfcmVzZXRfbWFjX2hlYWRlcihza2Ip
OwotCXNrYi0+bmgucmF3ID0gc2tiLT5kYXRhICsgRVRIX0hMRU47CisJc2tiLT5uaC5yYXcgPSBz
a2ItPm1hYy5yYXcgKyBFVEhfSExFTjsKIAlza2ItPnByb3RvY29sID0gUEtUX1RZUEVfTEFDUERV
OwogCXNrYi0+cHJpb3JpdHkgPSBUQ19QUklPX0NPTlRST0w7CiAKQEAgLTkyOSw3ICs5MjksNyBA
QCBzdGF0aWMgaW50IGFkX21hcmtlcl9zZW5kKHN0cnVjdCBwb3J0ICpwb3J0LCBzdHJ1Y3QgbWFy
a2VyICptYXJrZXIpCiAKIAlza2ItPmRldiA9IHNsYXZlLT5kZXY7CiAJc2tiX3Jlc2V0X21hY19o
ZWFkZXIoc2tiKTsKLQlza2ItPm5oLnJhdyA9IHNrYi0+ZGF0YSArIEVUSF9ITEVOOworCXNrYi0+
bmgucmF3ID0gc2tiLT5tYWMucmF3ICsgRVRIX0hMRU47CiAJc2tiLT5wcm90b2NvbCA9IFBLVF9U
WVBFX0xBQ1BEVTsKIAogCW1hcmtlcl9oZWFkZXIgPSAoc3RydWN0IG1hcmtlcl9oZWFkZXIgKilz
a2JfcHV0KHNrYiwgbGVuZ3RoKTsKZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2JvbmRpbmcvYm9u
ZF9hbGIuYyBiL2RyaXZlcnMvbmV0L2JvbmRpbmcvYm9uZF9hbGIuYwppbmRleCAzNmI4ZTg2Li41
YzJhMTJjIDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC9ib25kaW5nL2JvbmRfYWxiLmMKKysrIGIv
ZHJpdmVycy9uZXQvYm9uZGluZy9ib25kX2FsYi5jCkBAIC04OTYsNyArODk2LDcgQEAgc3RhdGlj
IHZvaWQgYWxiX3NlbmRfbGVhcm5pbmdfcGFja2V0cyhzdHJ1Y3Qgc2xhdmUgKnNsYXZlLCB1OCBt
YWNfYWRkcltdKQogCQltZW1jcHkoZGF0YSwgJnBrdCwgc2l6ZSk7CiAKIAkJc2tiX3Jlc2V0X21h
Y19oZWFkZXIoc2tiKTsKLQkJc2tiLT5uaC5yYXcgPSBkYXRhICsgRVRIX0hMRU47CisJCXNrYi0+
bmgucmF3ID0gc2tiLT5tYWMucmF3ICsgRVRIX0hMRU47CiAJCXNrYi0+cHJvdG9jb2wgPSBwa3Qu
dHlwZTsKIAkJc2tiLT5wcmlvcml0eSA9IFRDX1BSSU9fQ09OVFJPTDsKIAkJc2tiLT5kZXYgPSBz
bGF2ZS0+ZGV2OwotLSAKMS41LjAuMgoK
------=_Part_27596_13818313.1173673666719--
