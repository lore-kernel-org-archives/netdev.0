From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 09/11] [TCP]: Do the layer header setting in tcp_collapse relative to skb->data
Date: Sat, 10 Mar 2007 13:46:32 -0300
Message-ID: <39e6f6c70703100846v1e6f999eh17984202d9c28ad2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_12187_4350651.1173545192692"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.236]:28180 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767878AbXCJQqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2007 11:46:33 -0500
Received: by wr-out-0506.google.com with SMTP id 70so1683478wra
        for <netdev@vger.kernel.org>; Sat, 10 Mar 2007 08:46:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_12187_4350651.1173545192692
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

That is equal to skb->head before skb_reserve, to help in the layer header
changes.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/ipv4/tcp_input.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

------=_Part_12187_4350651.1173545192692
Content-Type: text/x-patch;
	name=0009-TCP-Do-the-layer-header-setting-in-tcp_collapse-r.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ez4agec7
Content-Disposition: attachment; filename="0009-TCP-Do-the-layer-header-setting-in-tcp_collapse-r.patch"

RnJvbSBjNTMwYmY0OGNjODgxMzI3YTZhMjU2N2NiODViODc4MDVlOTJjNTk2IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogU2F0LCAxMCBNYXIgMjAwNyAxMjo0NzoyMiAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggMDkvMTFdIFtUQ1BdOiBEbyB0aGUgbGF5ZXIgaGVhZGVyIHNldHRpbmcgaW4gdGNwX2NvbGxh
cHNlIHJlbGF0aXZlIHRvIHNrYi0+ZGF0YQoKVGhhdCBpcyBlcXVhbCB0byBza2ItPmhlYWQgYmVm
b3JlIHNrYl9yZXNlcnZlLCB0byBoZWxwIGluIHRoZSBsYXllciBoZWFkZXIKY2hhbmdlcy4KClNp
Z25lZC1vZmYtYnk6IEFybmFsZG8gQ2FydmFsaG8gZGUgTWVsbyA8YWNtZUByZWRoYXQuY29tPgot
LS0KIG5ldC9pcHY0L3RjcF9pbnB1dC5jIHwgICAgOCArKysrKy0tLQogMSBmaWxlcyBjaGFuZ2Vk
LCA1IGluc2VydGlvbnMoKyksIDMgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbmV0L2lwdjQv
dGNwX2lucHV0LmMgYi9uZXQvaXB2NC90Y3BfaW5wdXQuYwppbmRleCBmYjAyNTYwLi5lNWQxYzJj
IDEwMDY0NAotLS0gYS9uZXQvaXB2NC90Y3BfaW5wdXQuYworKysgYi9uZXQvaXB2NC90Y3BfaW5w
dXQuYwpAQCAtMzYzMiwxMSArMzYzMiwxMyBAQCB0Y3BfY29sbGFwc2Uoc3RydWN0IHNvY2sgKnNr
LCBzdHJ1Y3Qgc2tfYnVmZl9oZWFkICpsaXN0LAogCQluc2tiID0gYWxsb2Nfc2tiKGNvcHkraGVh
ZGVyLCBHRlBfQVRPTUlDKTsKIAkJaWYgKCFuc2tiKQogCQkJcmV0dXJuOworCisJCW5za2ItPm1h
Yy5yYXcgPSBuc2tiLT5kYXRhICsgKHNrYi0+bWFjLnJhdyAtIHNrYi0+aGVhZCk7CisJCW5za2It
Pm5oLnJhdyA9IG5za2ItPmRhdGEgKyAoc2tiLT5uaC5yYXcgLSBza2ItPmhlYWQpOworCQluc2ti
LT5oLnJhdyA9IG5za2ItPmRhdGEgKyAoc2tiLT5oLnJhdyAtIHNrYi0+aGVhZCk7CisKIAkJc2ti
X3Jlc2VydmUobnNrYiwgaGVhZGVyKTsKIAkJbWVtY3B5KG5za2ItPmhlYWQsIHNrYi0+aGVhZCwg
aGVhZGVyKTsKLQkJbnNrYi0+bmgucmF3ID0gbnNrYi0+aGVhZCArIChza2ItPm5oLnJhdy1za2It
PmhlYWQpOwotCQluc2tiLT5oLnJhdyA9IG5za2ItPmhlYWQgKyAoc2tiLT5oLnJhdy1za2ItPmhl
YWQpOwotCQluc2tiLT5tYWMucmF3ID0gbnNrYi0+aGVhZCArIChza2ItPm1hYy5yYXctc2tiLT5o
ZWFkKTsKIAkJbWVtY3B5KG5za2ItPmNiLCBza2ItPmNiLCBzaXplb2Yoc2tiLT5jYikpOwogCQlU
Q1BfU0tCX0NCKG5za2IpLT5zZXEgPSBUQ1BfU0tCX0NCKG5za2IpLT5lbmRfc2VxID0gc3RhcnQ7
CiAJCV9fc2tiX2luc2VydChuc2tiLCBza2ItPnByZXYsIHNrYiwgbGlzdCk7Ci0tIAoxLjUuMC4y
Cgo=
------=_Part_12187_4350651.1173545192692--
