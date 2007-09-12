From: "Ed Swierk" <eswierk@arastra.com>
Subject: Re: [PATCH] Configurable tap interface MTU
Date: Wed, 12 Sep 2007 09:54:35 -0700
Message-ID: <e6c711510709120954i29a8f86bg9ea7bb337a039b5a@mail.gmail.com>
References: <e6c711510709110742v4d2da644ha63b0a6d47c1230b@mail.gmail.com>
	 <E1IVIv8-0003Uc-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_9046_10205655.1189616075340"
To: "Herbert Xu" <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	maxk@qualcomm.com, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.185]:36233 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932510AbXILQyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 12:54:36 -0400
Received: by rv-out-0910.google.com with SMTP id k20so233688rvb
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 09:54:35 -0700 (PDT)
In-Reply-To: <E1IVIv8-0003Uc-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_9046_10205655.1189616075340
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 9/11/07, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Please make it 65535 without an Ethernet header and 65521
> with an Ethernet header.

Here is a revised patch that allows MTUs up to 65535 for tap
interfaces and up to 65521 for tun interfaces.

(If I set the MTU to 65521 on a tun interface, ping complains "message
too long" when I send a 65521-byte packet; 65520 works okay, though.)

--Ed

------=_Part_9046_10205655.1189616075340
Content-Type: application/octet-stream; name="tap-change-mtu.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="tap-change-mtu.patch"
X-Attachment-Id: f_f6i2ljzm

SW5kZXg6IGxpbnV4LTIuNi4yMi42L2RyaXZlcnMvbmV0L3R1bi5jCj09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0KLS0tIGxp
bnV4LTIuNi4yMi42Lm9yaWcvZHJpdmVycy9uZXQvdHVuLmMKKysrIGxpbnV4LTIuNi4yMi42L2Ry
aXZlcnMvbmV0L3R1bi5jCkBAIC0xNzEsNiArMTcxLDE4IEBAIHR1bl9uZXRfbWNsaXN0KHN0cnVj
dCBuZXRfZGV2aWNlICpkZXYpCiAJfQogfQogCisjZGVmaW5lIE1JTl9NVFUgNjgKKyNkZWZpbmUg
TUFYX01UVSA2NTUzNQorCitzdGF0aWMgaW50Cit0dW5fbmV0X2NoYW5nZV9tdHUoc3RydWN0IG5l
dF9kZXZpY2UgKmRldiwgaW50IG5ld19tdHUpCit7CisJaWYgKG5ld19tdHUgPCBNSU5fTVRVIHx8
IG5ld19tdHUgKyBkZXYtPmhhcmRfaGVhZGVyX2xlbiA+IE1BWF9NVFUpCisJCXJldHVybiAtRUlO
VkFMOworCWRldi0+bXR1ID0gbmV3X210dTsKKwlyZXR1cm4gMDsKK30KKwogc3RhdGljIHN0cnVj
dCBuZXRfZGV2aWNlX3N0YXRzICp0dW5fbmV0X3N0YXRzKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYp
CiB7CiAJc3RydWN0IHR1bl9zdHJ1Y3QgKnR1biA9IG5ldGRldl9wcml2KGRldik7CkBAIC0xODgs
NiArMjAwLDcgQEAgc3RhdGljIHZvaWQgdHVuX25ldF9pbml0KHN0cnVjdCBuZXRfZGV2aQogCQlk
ZXYtPmhhcmRfaGVhZGVyX2xlbiA9IDA7CiAJCWRldi0+YWRkcl9sZW4gPSAwOwogCQlkZXYtPm10
dSA9IDE1MDA7CisJCWRldi0+Y2hhbmdlX210dSA9IHR1bl9uZXRfY2hhbmdlX210dTsKIAogCQkv
KiBaZXJvIGhlYWRlciBsZW5ndGggKi8KIAkJZGV2LT50eXBlID0gQVJQSFJEX05PTkU7CkBAIC0y
MDAsNiArMjEzLDcgQEAgc3RhdGljIHZvaWQgdHVuX25ldF9pbml0KHN0cnVjdCBuZXRfZGV2aQog
CQlkZXYtPnNldF9tdWx0aWNhc3RfbGlzdCA9IHR1bl9uZXRfbWNsaXN0OwogCiAJCWV0aGVyX3Nl
dHVwKGRldik7CisJCWRldi0+Y2hhbmdlX210dSA9IHR1bl9uZXRfY2hhbmdlX210dTsKIAogCQkv
KiByYW5kb20gYWRkcmVzcyBhbHJlYWR5IGNyZWF0ZWQgZm9yIHVzIGJ5IHR1bl9zZXRfaWZmLCB1
c2UgaXQgKi8KIAkJbWVtY3B5KGRldi0+ZGV2X2FkZHIsIHR1bi0+ZGV2X2FkZHIsIG1pbihzaXpl
b2YodHVuLT5kZXZfYWRkciksIHNpemVvZihkZXYtPmRldl9hZGRyKSkgKTsK
------=_Part_9046_10205655.1189616075340--
