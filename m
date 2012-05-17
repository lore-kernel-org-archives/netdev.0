From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next-2.6] pppoe: remove unused return value from two methods.
Date: Thu, 17 May 2012 18:04:50 +0300
Message-ID: <CAHLOa7RiNcZBLE7z7JTY-7WJGOL_DTYq33hmwyTdM0HWqn_WgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b15a12feb18f504c03cc14b
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:51675 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933033Ab2EQPEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 11:04:51 -0400
Received: by pbbrp8 with SMTP id rp8so2639541pbb.19
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 08:04:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7b15a12feb18f504c03cc14b
Content-Type: text/plain; charset=ISO-8859-1

Hi,

 The patch removes unused return value from __delete_item() and
 delete_item() methods in drivers/net/ppp/pppoe.c.

Signed-off-by: Rami Rosen <ramirose@gmail.com>

--047d7b15a12feb18f504c03cc14b
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h2by9p5v0

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3BwcC9wcHBvZS5jIGIvZHJpdmVycy9uZXQvcHBwL3Bw
cG9lLmMKaW5kZXggMmZhMWE5Yi4uZGQxNWI4ZiAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvcHBw
L3BwcG9lLmMKKysrIGIvZHJpdmVycy9uZXQvcHBwL3BwcG9lLmMKQEAgLTIwMSw3ICsyMDEsNyBA
QCBzdGF0aWMgaW50IF9fc2V0X2l0ZW0oc3RydWN0IHBwcG9lX25ldCAqcG4sIHN0cnVjdCBwcHBv
eF9zb2NrICpwbykKIAlyZXR1cm4gMDsKIH0KIAotc3RhdGljIHN0cnVjdCBwcHBveF9zb2NrICpf
X2RlbGV0ZV9pdGVtKHN0cnVjdCBwcHBvZV9uZXQgKnBuLCBfX2JlMTYgc2lkLAorc3RhdGljIHZv
aWQgX19kZWxldGVfaXRlbShzdHJ1Y3QgcHBwb2VfbmV0ICpwbiwgX19iZTE2IHNpZCwKIAkJCQkJ
Y2hhciAqYWRkciwgaW50IGlmaW5kZXgpCiB7CiAJaW50IGhhc2ggPSBoYXNoX2l0ZW0oc2lkLCBh
ZGRyKTsKQEAgLTIyMCw4ICsyMjAsNiBAQCBzdGF0aWMgc3RydWN0IHBwcG94X3NvY2sgKl9fZGVs
ZXRlX2l0ZW0oc3RydWN0IHBwcG9lX25ldCAqcG4sIF9fYmUxNiBzaWQsCiAJCXNyYyA9ICZyZXQt
Pm5leHQ7CiAJCXJldCA9IHJldC0+bmV4dDsKIAl9Ci0KLQlyZXR1cm4gcmV0OwogfQogCiAvKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioqKioqKgpAQCAtMjY0LDE2ICsyNjIsMTIgQEAgc3RhdGljIGlubGluZSBzdHJ1Y3QgcHBw
b3hfc29jayAqZ2V0X2l0ZW1fYnlfYWRkcihzdHJ1Y3QgbmV0ICpuZXQsCiAJcmV0dXJuIHBwcG94
X3NvY2s7CiB9CiAKLXN0YXRpYyBpbmxpbmUgc3RydWN0IHBwcG94X3NvY2sgKmRlbGV0ZV9pdGVt
KHN0cnVjdCBwcHBvZV9uZXQgKnBuLCBfX2JlMTYgc2lkLAorc3RhdGljIGlubGluZSB2b2lkIGRl
bGV0ZV9pdGVtKHN0cnVjdCBwcHBvZV9uZXQgKnBuLCBfX2JlMTYgc2lkLAogCQkJCQljaGFyICph
ZGRyLCBpbnQgaWZpbmRleCkKIHsKLQlzdHJ1Y3QgcHBwb3hfc29jayAqcmV0OwotCiAJd3JpdGVf
bG9ja19iaCgmcG4tPmhhc2hfbG9jayk7Ci0JcmV0ID0gX19kZWxldGVfaXRlbShwbiwgc2lkLCBh
ZGRyLCBpZmluZGV4KTsKKwlfX2RlbGV0ZV9pdGVtKHBuLCBzaWQsIGFkZHIsIGlmaW5kZXgpOwog
CXdyaXRlX3VubG9ja19iaCgmcG4tPmhhc2hfbG9jayk7Ci0KLQlyZXR1cm4gcmV0OwogfQogCiAv
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioqKioqKioqKioqKioqCg==
--047d7b15a12feb18f504c03cc14b--
