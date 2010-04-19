From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-2.6] cleanup: remove two unnecessary exports in skbuff.c.
Date: Mon, 19 Apr 2010 12:50:19 +0300
Message-ID: <l2geb3ff54b1004190250qfe606c28i80dab5f156128f4c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016e65ae6828d51d4048493e337
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44105 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752650Ab0DSJuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 05:50:21 -0400
Received: by wyb39 with SMTP id 39so2370804wyb.19
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 02:50:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0016e65ae6828d51d4048493e337
Content-Type: text/plain; charset=ISO-8859-1

Hi,
There is no need to export skb_under_panic() and skb_over_panic() in
skbuff.c, since these methods are used only in
skbuff.c ; this patch removes these two exports.


Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

--0016e65ae6828d51d4048493e337
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g873qc8l0

ZGlmZiAtLWdpdCBhL25ldC9jb3JlL3NrYnVmZi5jIGIvbmV0L2NvcmUvc2tidWZmLmMKaW5kZXgg
OTNjNGUwNi4uNzk5Yjg5ZCAxMDA2NDQKLS0tIGEvbmV0L2NvcmUvc2tidWZmLmMKKysrIGIvbmV0
L2NvcmUvc2tidWZmLmMKQEAgLTEyNiw3ICsxMjYsNiBAQCB2b2lkIHNrYl9vdmVyX3BhbmljKHN0
cnVjdCBza19idWZmICpza2IsIGludCBzeiwgdm9pZCAqaGVyZSkKIAkgICAgICAgc2tiLT5kZXYg
PyBza2ItPmRldi0+bmFtZSA6ICI8TlVMTD4iKTsKIAlCVUcoKTsKIH0KLUVYUE9SVF9TWU1CT0wo
c2tiX292ZXJfcGFuaWMpOwogCiAvKioKICAqCXNrYl91bmRlcl9wYW5pYwktIAlwcml2YXRlIGZ1
bmN0aW9uCkBAIC0xNDYsNyArMTQ1LDYgQEAgdm9pZCBza2JfdW5kZXJfcGFuaWMoc3RydWN0IHNr
X2J1ZmYgKnNrYiwgaW50IHN6LCB2b2lkICpoZXJlKQogCSAgICAgICBza2ItPmRldiA/IHNrYi0+
ZGV2LT5uYW1lIDogIjxOVUxMPiIpOwogCUJVRygpOwogfQotRVhQT1JUX1NZTUJPTChza2JfdW5k
ZXJfcGFuaWMpOwogCiAvKiAJQWxsb2NhdGUgYSBuZXcgc2tidWZmLiBXZSBkbyB0aGlzIG91cnNl
bHZlcyBzbyB3ZSBjYW4gZmlsbCBpbiBhIGZldwogICoJJ3ByaXZhdGUnIGZpZWxkcyBhbmQgYWxz
byBkbyBtZW1vcnkgc3RhdGlzdGljcyB0byBmaW5kIGFsbCB0aGUK
--0016e65ae6828d51d4048493e337--
