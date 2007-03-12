From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 08/18][SK_BUFF]: Some more simple skb_reset_network_header conversions
Date: Mon, 12 Mar 2007 01:27:15 -0300
Message-ID: <39e6f6c70703112127q719515f3maaa386b8582b39b8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_27568_21385429.1173673635060"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:38258 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965042AbXCLE1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 00:27:17 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1864480nfa
        for <netdev@vger.kernel.org>; Sun, 11 Mar 2007 21:27:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_27568_21385429.1173673635060
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This time of the type:

 skb->nh.iph = (struct iphdr *)skb->data;

That is completely equivalent to:

 skb->nh.raw = skb->data;

Wonder why people love casts... :-)

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/ieee80211/ieee80211_rx.c |    2 +-
 net/ipv4/ipmr.c              |    4 ++--
 net/sctp/input.c             |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

------=_Part_27568_21385429.1173673635060
Content-Type: text/x-patch;
	name=0008-SK_BUFF-Some-more-simple-skb_reset_network_header.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ez6ebst3
Content-Disposition: attachment; filename="0008-SK_BUFF-Some-more-simple-skb_reset_network_header.patch"

RnJvbSA5ODNmYzg1NmE5NThkMjE1MWYyYjI5ZmZhYTU1MzI3YWFlYjRlYTNlIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogU2F0LCAxMCBNYXIgMjAwNyAxOTowNDo1NSAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggMDgvMThdIFtTS19CVUZGXTogU29tZSBtb3JlIHNpbXBsZSBza2JfcmVzZXRfbmV0d29ya19o
ZWFkZXIgY29udmVyc2lvbnMKClRoaXMgdGltZSBvZiB0aGUgdHlwZToKCiBza2ItPm5oLmlwaCA9
IChzdHJ1Y3QgaXBoZHIgKilza2ItPmRhdGE7CgpUaGF0IGlzIGNvbXBsZXRlbHkgZXF1aXZhbGVu
dCB0bzoKCiBza2ItPm5oLnJhdyA9IHNrYi0+ZGF0YTsKCldvbmRlciB3aHkgcGVvcGxlIGxvdmUg
Y2FzdHMuLi4gOi0pCgpTaWduZWQtb2ZmLWJ5OiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFj
bWVAcmVkaGF0LmNvbT4KLS0tCiBuZXQvaWVlZTgwMjExL2llZWU4MDIxMV9yeC5jIHwgICAgMiAr
LQogbmV0L2lwdjQvaXBtci5jICAgICAgICAgICAgICB8ICAgIDQgKystLQogbmV0L3NjdHAvaW5w
dXQuYyAgICAgICAgICAgICB8ICAgIDIgKy0KIDMgZmlsZXMgY2hhbmdlZCwgNCBpbnNlcnRpb25z
KCspLCA0IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL25ldC9pZWVlODAyMTEvaWVlZTgwMjEx
X3J4LmMgYi9uZXQvaWVlZTgwMjExL2llZWU4MDIxMV9yeC5jCmluZGV4IGJlNWZmYWYuLjdmNWEz
NTIgMTAwNjQ0Ci0tLSBhL25ldC9pZWVlODAyMTEvaWVlZTgwMjExX3J4LmMKKysrIGIvbmV0L2ll
ZWU4MDIxMS9pZWVlODAyMTFfcnguYwpAQCAtNzkzLDcgKzc5Myw3IEBAIGludCBpZWVlODAyMTFf
cngoc3RydWN0IGllZWU4MDIxMV9kZXZpY2UgKmllZWUsIHN0cnVjdCBza19idWZmICpza2IsCiAJ
CXNrYjItPnByb3RvY29sID0gX19jb25zdGFudF9odG9ucyhFVEhfUF84MDJfMyk7CiAJCXNrYl9y
ZXNldF9tYWNfaGVhZGVyKHNrYjIpOwogCQlza2JfcmVzZXRfbmV0d29ya19oZWFkZXIoc2tiMik7
Ci0JCS8qIHNrYjItPm5oLnJhdyA9IHNrYjItPmRhdGEgKyBFVEhfSExFTjsgKi8KKwkJLyogc2ti
Mi0+bmgucmF3ICs9IEVUSF9ITEVOOyAqLwogCQlkZXZfcXVldWVfeG1pdChza2IyKTsKIAl9CiAj
ZW5kaWYKZGlmZiAtLWdpdCBhL25ldC9pcHY0L2lwbXIuYyBiL25ldC9pcHY0L2lwbXIuYwppbmRl
eCAwNWM4MmNhLi40NTQzNWYwIDEwMDY0NAotLS0gYS9uZXQvaXB2NC9pcG1yLmMKKysrIGIvbmV0
L2lwdjQvaXBtci5jCkBAIC0xNDU0LDcgKzE0NTQsNyBAQCBpbnQgcGltX3Jjdl92MShzdHJ1Y3Qg
c2tfYnVmZiAqIHNrYikKIAogCXNrYi0+bWFjLnJhdyA9IHNrYi0+bmgucmF3OwogCXNrYl9wdWxs
KHNrYiwgKHU4KillbmNhcCAtIHNrYi0+ZGF0YSk7Ci0Jc2tiLT5uaC5pcGggPSAoc3RydWN0IGlw
aGRyICopc2tiLT5kYXRhOworCXNrYl9yZXNldF9uZXR3b3JrX2hlYWRlcihza2IpOwogCXNrYi0+
ZGV2ID0gcmVnX2RldjsKIAlza2ItPnByb3RvY29sID0gaHRvbnMoRVRIX1BfSVApOwogCXNrYi0+
aXBfc3VtbWVkID0gMDsKQEAgLTE1MDksNyArMTUwOSw3IEBAIHN0YXRpYyBpbnQgcGltX3Jjdihz
dHJ1Y3Qgc2tfYnVmZiAqIHNrYikKIAogCXNrYi0+bWFjLnJhdyA9IHNrYi0+bmgucmF3OwogCXNr
Yl9wdWxsKHNrYiwgKHU4KillbmNhcCAtIHNrYi0+ZGF0YSk7Ci0Jc2tiLT5uaC5pcGggPSAoc3Ry
dWN0IGlwaGRyICopc2tiLT5kYXRhOworCXNrYl9yZXNldF9uZXR3b3JrX2hlYWRlcihza2IpOwog
CXNrYi0+ZGV2ID0gcmVnX2RldjsKIAlza2ItPnByb3RvY29sID0gaHRvbnMoRVRIX1BfSVApOwog
CXNrYi0+aXBfc3VtbWVkID0gMDsKZGlmZiAtLWdpdCBhL25ldC9zY3RwL2lucHV0LmMgYi9uZXQv
c2N0cC9pbnB1dC5jCmluZGV4IDcxZGI2NjguLjJiMDg2M2EgMTAwNjQ0Ci0tLSBhL25ldC9zY3Rw
L2lucHV0LmMKKysrIGIvbmV0L3NjdHAvaW5wdXQuYwpAQCAtNTI4LDcgKzUyOCw3IEBAIHZvaWQg
c2N0cF92NF9lcnIoc3RydWN0IHNrX2J1ZmYgKnNrYiwgX191MzIgaW5mbykKIAkvKiBGaXggdXAg
c2tiIHRvIGxvb2sgYXQgdGhlIGVtYmVkZGVkIG5ldCBoZWFkZXIuICovCiAJc2F2ZWlwID0gc2ti
LT5uaC5yYXc7CiAJc2F2ZXNjdHAgID0gc2tiLT5oLnJhdzsKLQlza2ItPm5oLmlwaCA9IGlwaDsK
Kwlza2JfcmVzZXRfbmV0d29ya19oZWFkZXIoc2tiKTsKIAlza2ItPmgucmF3ID0gKGNoYXIgKilz
aDsKIAlzayA9IHNjdHBfZXJyX2xvb2t1cChBRl9JTkVULCBza2IsIHNoLCAmYXNvYywgJnRyYW5z
cG9ydCk7CiAJLyogUHV0IGJhY2ssIHRoZSBvcmlnaW5hbCBwb2ludGVycy4gKi8KLS0gCjEuNS4w
LjIKCg==
------=_Part_27568_21385429.1173673635060--
