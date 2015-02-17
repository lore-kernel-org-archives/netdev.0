From: "Zhu, Yanjun" <Yanjun.Zhu@windriver.com>
Subject: RE: If bridge have no sub-interfaces, it's status may be still with
 'RUNNING'
Date: Tue, 17 Feb 2015 16:14:37 +0000
Message-ID: <E66F6C44A7A6EA49ABFC80EA526506DF65AEAEB3@ALA-MBB.corp.ad.wrs.com>
References: <54DDCA99.4040401@windriver.com>
	<20150213133056.3944c13e@uryu.home.lan>	<54E17853.8070106@windriver.com>
	<54E210FF.2050502@gmail.com>,<20150216115137.5aa3f0cd@uryu.home.lan>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_E66F6C44A7A6EA49ABFC80EA526506DF65AEAEB3ALAMBBcorpadwrs_"
Cc: netdev <netdev@vger.kernel.org>,
	"Wu, Kuaikuai" <Kuaikuai.Wu@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:48999 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895AbbBQQOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 11:14:40 -0500
In-Reply-To: <20150216115137.5aa3f0cd@uryu.home.lan>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_E66F6C44A7A6EA49ABFC80EA526506DF65AEAEB3ALAMBBcorpadwrs_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi, all

We should make it compatible. So I made a patch to turn on carrier on this =
bridge interface when the last sub interface is removed.

Hi, David

Please make tests with this latest patch. Thanks a lot.

Best Regards!
Zhu Yanjun
________________________________________
From: Stephen Hemminger [stephen@networkplumber.org]
Sent: Monday, February 16, 2015 8:51 AM
To: David Ahern
Cc: Zhu, Yanjun; netdev; Wu, Kuaikuai; Tao, Yue
Subject: Re: If bridge have no sub-interfaces, it's status may be still wit=
h 'RUNNING'

Originally bridge code would start with carrier off,
but there were users using bridge as a form of dummy device
and this broke them. Therefore it was decided (like 5 yrs ago),
that bridge should start with carrier on.=

--_002_E66F6C44A7A6EA49ABFC80EA526506DF65AEAEB3ALAMBBcorpadwrs_
Content-Type: text/plain;
	name="0001-bridge-turn-on-carrier-after-removing-the-last-sub-i.patch"
Content-Description: 0001-bridge-turn-on-carrier-after-removing-the-last-sub-i.patch
Content-Disposition: attachment;
	filename="0001-bridge-turn-on-carrier-after-removing-the-last-sub-i.patch";
	size=1025; creation-date="Tue, 17 Feb 2015 16:14:33 GMT";
	modification-date="Tue, 17 Feb 2015 16:14:33 GMT"
Content-Transfer-Encoding: base64

RnJvbSAwZDE2ZjMwMmYyM2M5ZjUxMDFmODQ5NDUwYWJjMDczMDQ1YTE5M2RlIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBaaHUgWWFuanVuIDxZYW5qdW4uWmh1QHdpbmRyaXZlci5jb20+
CkRhdGU6IFR1ZSwgMTcgRmViIDIwMTUgMjM6NTk6MDggKzA4MDAKU3ViamVjdDogW1BBVENIIDEv
MV0gYnJpZGdlOiB0dXJuIG9uIGNhcnJpZXIgYWZ0ZXIgcmVtb3ZpbmcgdGhlIGxhc3Qgc3ViCiBp
bnRlcmZhY2UKCldoZW4gdGhlIGxhc3Qgc3ViIGludGVyZmFjZSBpcyByZW1vdmVkIGZyb20gdGhl
IGJyaWRnZSwgdGhlIGJyaWRnZQp0dXJuIG9mZiB0aGUgY2Fycmllci4gTWF5YmUgaXQgaXMgbm90
IGNvbXBhdGlibGUgd2l0aCBmaXJzdGx5IGNyZWF0ZWQKYnJpZGdlIHdpdGhvdXQgYW55IHN1YiBp
bnRlcmZhY2UuIEF0IHRoYXQgdGltZSwgdGhlIGNhcnJpZXIgb2YgdGhpcwpicmlkZ2UgaXMgdHVy
bmVkIG9uLgoKU2lnbmVkLW9mZi1ieTogWmh1IFlhbmp1biA8WWFuanVuLlpodUB3aW5kcml2ZXIu
Y29tPgotLS0KIG5ldC9icmlkZ2UvYnJfaWYuYyB8IDYgKysrKysrCiAxIGZpbGUgY2hhbmdlZCwg
NiBpbnNlcnRpb25zKCspCgpkaWZmIC0tZ2l0IGEvbmV0L2JyaWRnZS9icl9pZi5jIGIvbmV0L2Jy
aWRnZS9icl9pZi5jCmluZGV4IGVkMzA3ZGIuLmYzOTFmOGMgMTAwNjQ0Ci0tLSBhL25ldC9icmlk
Z2UvYnJfaWYuYworKysgYi9uZXQvYnJpZGdlL2JyX2lmLmMKQEAgLTU2NSw2ICs1NjUsMTIgQEAg
aW50IGJyX2RlbF9pZihzdHJ1Y3QgbmV0X2JyaWRnZSAqYnIsIHN0cnVjdCBuZXRfZGV2aWNlICpk
ZXYpCiAKIAluZXRkZXZfdXBkYXRlX2ZlYXR1cmVzKGJyLT5kZXYpOwogCisJLyogTm8gc3ViIGlu
dGVyZmFjZSBpbiBicmlkZ2UsIHR1cm4gb24gY2FycmllciAqLworCWlmIChsaXN0X2VtcHR5KCZi
ci0+cG9ydF9saXN0KSkgeworCQlldGhfaHdfYWRkcl9yYW5kb20oYnItPmRldik7CisJCW5ldGlm
X2NhcnJpZXJfb24oYnItPmRldik7CisJfQorCiAJcmV0dXJuIDA7CiB9CiAKLS0gCjEuOS4xCgo=

--_002_E66F6C44A7A6EA49ABFC80EA526506DF65AEAEB3ALAMBBcorpadwrs_--
