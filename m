From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6.25] [BRIDGE] Remove useless code in net/bridge/br_netfilter.c
Date: Tue, 1 Jan 2008 12:48:14 +0200
Message-ID: <eb3ff54b0801010248t65d296ccm481202d50fad7c4f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_5110_2293244.1199184494238"
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:10731 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbYAAKsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2008 05:48:15 -0500
Received: by fg-out-1718.google.com with SMTP id e21so2883640fga.17
        for <netdev@vger.kernel.org>; Tue, 01 Jan 2008 02:48:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_5110_2293244.1199184494238
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

These following two commands in br_nf_forward_arp() achieve nothing and
should be removed; the d variable is not used later in this method:

	...
	struct net_device **d = (struct net_device **)(skb->cb);
	...
	*d = (struct net_device *)in;
	...

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_5110_2293244.1199184494238
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fawbga6a0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL25ldC9icmlkZ2UvYnJfbmV0ZmlsdGVyLmMgYi9uZXQvYnJpZGdlL2JyX25l
dGZpbHRlci5jCmluZGV4IDMyYWMwMzUuLjI4OGUxMDIgMTAwNjQ0Ci0tLSBhL25ldC9icmlkZ2Uv
YnJfbmV0ZmlsdGVyLmMKKysrIGIvbmV0L2JyaWRnZS9icl9uZXRmaWx0ZXIuYwpAQCAtNjY0LDgg
KzY2NCw2IEBAIHN0YXRpYyB1bnNpZ25lZCBpbnQgYnJfbmZfZm9yd2FyZF9hcnAodW5zaWduZWQg
aW50IGhvb2ssIHN0cnVjdCBza19idWZmICpza2IsCiAJCQkJICAgICAgY29uc3Qgc3RydWN0IG5l
dF9kZXZpY2UgKm91dCwKIAkJCQkgICAgICBpbnQgKCpva2ZuKShzdHJ1Y3Qgc2tfYnVmZiAqKSkK
IHsKLQlzdHJ1Y3QgbmV0X2RldmljZSAqKmQgPSAoc3RydWN0IG5ldF9kZXZpY2UgKiopKHNrYi0+
Y2IpOwotCiAjaWZkZWYgQ09ORklHX1NZU0NUTAogCWlmICghYnJuZl9jYWxsX2FycHRhYmxlcykK
IAkJcmV0dXJuIE5GX0FDQ0VQVDsKQEAgLTY4Miw3ICs2ODAsNiBAQCBzdGF0aWMgdW5zaWduZWQg
aW50IGJyX25mX2ZvcndhcmRfYXJwKHVuc2lnbmVkIGludCBob29rLCBzdHJ1Y3Qgc2tfYnVmZiAq
c2tiLAogCQkJbmZfYnJpZGdlX3B1c2hfZW5jYXBfaGVhZGVyKHNrYik7CiAJCXJldHVybiBORl9B
Q0NFUFQ7CiAJfQotCSpkID0gKHN0cnVjdCBuZXRfZGV2aWNlICopaW47CiAJTkZfSE9PSyhORl9B
UlAsIE5GX0FSUF9GT1JXQVJELCBza2IsIChzdHJ1Y3QgbmV0X2RldmljZSAqKWluLAogCQkoc3Ry
dWN0IG5ldF9kZXZpY2UgKilvdXQsIGJyX25mX2ZvcndhcmRfZmluaXNoKTsKIAo=
------=_Part_5110_2293244.1199184494238--
