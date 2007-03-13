From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 3/6] [IPMR]: Fix bug introduced when converting to skb_network_reset_header
Date: Mon, 12 Mar 2007 22:27:22 -0300
Message-ID: <39e6f6c70703121827q1943df8eu4a887ab980267d15@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_13749_19808297.1173749242274"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:48760 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988AbXCMB1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 21:27:31 -0400
Received: by ug-out-1314.google.com with SMTP id 44so77754uga
        for <netdev@vger.kernel.org>; Mon, 12 Mar 2007 18:27:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_13749_19808297.1173749242274
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/ipv4/ipmr.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

------=_Part_13749_19808297.1173749242274
Content-Type: text/x-patch;
	name=0003-IPMR-Fix-bug-introduced-when-converting-to-skb_ne.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ez7nvc29
Content-Disposition: attachment; filename="0003-IPMR-Fix-bug-introduced-when-converting-to-skb_ne.patch"

RnJvbSA2OWUyMzU1MGE1MWVlNDdkYmYwYjIxMDU4NzRhMGM3OTcwMWE3MjZmIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogTW9uLCAxMiBNYXIgMjAwNyAyMDowOTozNiAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggMy82XSBbSVBNUl06IEZpeCBidWcgaW50cm9kdWNlZCB3aGVuIGNvbnZlcnRpbmcgdG8gc2ti
X25ldHdvcmtfcmVzZXRfaGVhZGVyCgpTaWduZWQtb2ZmLWJ5OiBBcm5hbGRvIENhcnZhbGhvIGRl
IE1lbG8gPGFjbWVAcmVkaGF0LmNvbT4KLS0tCiBuZXQvaXB2NC9pcG1yLmMgfCAgICA1ICsrKy0t
CiAxIGZpbGVzIGNoYW5nZWQsIDMgaW5zZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMoLSkKCmRpZmYg
LS1naXQgYS9uZXQvaXB2NC9pcG1yLmMgYi9uZXQvaXB2NC9pcG1yLmMKaW5kZXggNTRiNzU0My4u
YjI0ZGZmZSAxMDA2NDQKLS0tIGEvbmV0L2lwdjQvaXBtci5jCisrKyBiL25ldC9pcHY0L2lwbXIu
YwpAQCAtMTA5Niw2ICsxMDk2LDcgQEAgc3RhdGljIHN0cnVjdCBub3RpZmllcl9ibG9jayBpcF9t
cl9ub3RpZmllcj17CiBzdGF0aWMgdm9pZCBpcF9lbmNhcChzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBf
X2JlMzIgc2FkZHIsIF9fYmUzMiBkYWRkcikKIHsKIAlzdHJ1Y3QgaXBoZHIgKmlwaDsKKwlzdHJ1
Y3QgaXBoZHIgKm9sZF9pcGggPSBza2ItPm5oLmlwaDsKIAogCXNrYl9wdXNoKHNrYiwgc2l6ZW9m
KHN0cnVjdCBpcGhkcikpOwogCXNrYi0+aC5pcGlwaCA9IHNrYi0+bmguaXBoOwpAQCAtMTEwMyw4
ICsxMTA0LDggQEAgc3RhdGljIHZvaWQgaXBfZW5jYXAoc3RydWN0IHNrX2J1ZmYgKnNrYiwgX19i
ZTMyIHNhZGRyLCBfX2JlMzIgZGFkZHIpCiAJaXBoID0gc2tiLT5uaC5pcGg7CiAKIAlpcGgtPnZl
cnNpb24JPSAJNDsKLQlpcGgtPnRvcwk9CXNrYi0+bmguaXBoLT50b3M7Ci0JaXBoLT50dGwJPQlz
a2ItPm5oLmlwaC0+dHRsOworCWlwaC0+dG9zCT0Jb2xkX2lwaC0+dG9zOworCWlwaC0+dHRsCT0J
b2xkX2lwaC0+dHRsOwogCWlwaC0+ZnJhZ19vZmYJPQkwOwogCWlwaC0+ZGFkZHIJPQlkYWRkcjsK
IAlpcGgtPnNhZGRyCT0Jc2FkZHI7Ci0tIAoxLjUuMC4yCgo=
------=_Part_13749_19808297.1173749242274--
