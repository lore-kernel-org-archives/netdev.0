From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH] [SK_BUFF]: Disable the offset code
Date: Fri, 16 Mar 2007 22:42:46 -0300
Message-ID: <39e6f6c70703161842u5587058ep1d0eef8d794390b5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_86220_1690659.1174095766201"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.239]:32027 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753557AbXCQBmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 21:42:47 -0400
Received: by wr-out-0506.google.com with SMTP id 41so733561wry
        for <netdev@vger.kernel.org>; Fri, 16 Mar 2007 18:42:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_86220_1690659.1174095766201
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

David,

        Please pull from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.22

        Till I fully investigate and fix this we should just use the
pointer based approach, where this problem bug doesn't happens, good
thing its selectable :)

- Arnaldo

-----
There is a bug when using IPSEC, so till it is fixed, just use the
old code in all arches.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/linux/skbuff.h |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

------=_Part_86220_1690659.1174095766201
Content-Type: text/x-patch; name=0001-SK_BUFF-Disable-the-offset-code.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ezde56rq
Content-Disposition: attachment; filename="0001-SK_BUFF-Disable-the-offset-code.patch"

RnJvbSBkYzYzZDlmNzRlNTY3OGM4MGI2OGUzMjVlNGIyMWRlNWFmNWU2MTEwIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogRnJpLCAxNiBNYXIgMjAwNyAyMjozNzoyMCAtMDMwMApTdWJqZWN0OiBbUEFU
Q0hdIFtTS19CVUZGXTogRGlzYWJsZSB0aGUgb2Zmc2V0IGNvZGUKClRoZXJlIGlzIGEgYnVnIHdo
ZW4gdXNpbmcgSVBTRUMsIHNvIHRpbGwgaXQgaXMgZml4ZWQsIGp1c3QgdXNlIHRoZQpvbGQgY29k
ZSBpbiBhbGwgYXJjaGVzLgoKU2lnbmVkLW9mZi1ieTogQXJuYWxkbyBDYXJ2YWxobyBkZSBNZWxv
IDxhY21lQHJlZGhhdC5jb20+Ci0tLQogaW5jbHVkZS9saW51eC9za2J1ZmYuaCB8ICAgIDQgKysr
LQogMSBmaWxlcyBjaGFuZ2VkLCAzIGluc2VydGlvbnMoKyksIDEgZGVsZXRpb25zKC0pCgpkaWZm
IC0tZ2l0IGEvaW5jbHVkZS9saW51eC9za2J1ZmYuaCBiL2luY2x1ZGUvbGludXgvc2tidWZmLmgK
aW5kZXggM2U0YTJiZC4uNjczY2EwYyAxMDA2NDQKLS0tIGEvaW5jbHVkZS9saW51eC9za2J1ZmYu
aAorKysgYi9pbmNsdWRlL2xpbnV4L3NrYnVmZi5oCkBAIC0xODAsNyArMTgwLDkgQEAgZW51bSB7
CiAJU0tCX0dTT19UQ1BWNiA9IDEgPDwgNCwKIH07CiAKLSNpZiBCSVRTX1BFUl9MT05HID4gMzIK
Ky8qICNpZiBCSVRTX1BFUl9MT05HID4gMzIgKi8KKyNpZiAwCisvKiBEaXNhYmxlZCBmb3Igbm93
IHRpbGwgdGhlIGlwc2VjIHByb2JsZW0gaXMgZml4ZWQgLWFjbWUgKi8KICNkZWZpbmUgTkVUX1NL
QlVGRl9EQVRBX1VTRVNfT0ZGU0VUIDEKICNlbmRpZgogCi0tIAoxLjUuMC4zCgo=
------=_Part_86220_1690659.1174095766201--
