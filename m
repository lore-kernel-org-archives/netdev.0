From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v3 1/7] net: tcp_header_len_th and tcp_option_len_th
Date: Mon, 15 Feb 2010 07:25:41 -0500
Message-ID: <4B793D45.1030802@gmail.com>
References: <4B793CAA.2030902@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060205030107060301080005"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:65041 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754879Ab0BOMZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 07:25:49 -0500
In-Reply-To: <4B793CAA.2030902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060205030107060301080005
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Redefine two TCP header functions to accept TCP header pointer.
When subtracting, return signed int to allow error checking.

These functions will be used in subsequent patches that implement
additional features.

Signed-off-by: William.Allen.Simpson@gmail.com
---
  include/linux/tcp.h |   12 ++++++++++++
  1 files changed, 12 insertions(+), 0 deletions(-)

--------------060205030107060301080005
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="len_th+2a3+2.6.33-rc8.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="len_th+2a3+2.6.33-rc8.patch"

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvdGNwLmggYi9pbmNsdWRlL2xpbnV4L3RjcC5o
CmluZGV4IDdmZWU4YTQuLmQwMTMzY2YgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgvdGNw
LmgKKysrIGIvaW5jbHVkZS9saW51eC90Y3AuaApAQCAtMjIzLDYgKzIyMywxOCBAQCBzdGF0
aWMgaW5saW5lIHVuc2lnbmVkIGludCB0Y3Bfb3B0bGVuKGNvbnN0IHN0cnVjdCBza19idWZm
ICpza2IpCiAJcmV0dXJuICh0Y3BfaGRyKHNrYiktPmRvZmYgLSA1KSAqIDQ7CiB9CiAKKy8q
IExlbmd0aCBvZiBmaXhlZCBoZWFkZXIgcGx1cyBzdGFuZGFyZCBvcHRpb25zLiAqLworc3Rh
dGljIGlubGluZSB1bnNpZ25lZCBpbnQgdGNwX2hlYWRlcl9sZW5fdGgoY29uc3Qgc3RydWN0
IHRjcGhkciAqdGgpCit7CisJcmV0dXJuIHRoLT5kb2ZmICogNDsKK30KKworLyogTGVuZ3Ro
IG9mIHN0YW5kYXJkIG9wdGlvbnMgb25seS4gIFRoaXMgY291bGQgYmUgbmVnYXRpdmUuICov
CitzdGF0aWMgaW5saW5lIGludCB0Y3Bfb3B0aW9uX2xlbl90aChjb25zdCBzdHJ1Y3QgdGNw
aGRyICp0aCkKK3sKKwlyZXR1cm4gKGludCkodGgtPmRvZmYgKiA0KSAtIHNpemVvZigqdGgp
OworfQorCiAvKiBUaGlzIGRlZmluZXMgYSBzZWxlY3RpdmUgYWNrbm93bGVkZ2VtZW50IGJs
b2NrLiAqLwogc3RydWN0IHRjcF9zYWNrX2Jsb2NrX3dpcmUgewogCV9fYmUzMglzdGFydF9z
ZXE7Ci0tIAoxLjYuMy4zCgo=
--------------060205030107060301080005--
