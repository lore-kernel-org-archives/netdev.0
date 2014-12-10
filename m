From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next PATCH 6/6] ethernet/broadcom: Use napi_alloc_skb
 instead of netdev_alloc_skb_ip_align
Date: Wed, 10 Dec 2014 09:52:12 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CA09DA9@AcuExch.aculab.com>
References: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>
 <20141210034117.2114.50589.stgit@ahduyck-vm-fedora20>
 <063D6719AE5E284EB5DD2968C1650D6D1CA09D86@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	"brouer@redhat.com" <brouer@redhat.com>,
	Gary Zambrano <zambrano@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"ast@plumgrid.com" <ast@plumgrid.com>
To: David Laight <David.Laight@ACULAB.COM>,
	'Alexander Duyck' <alexander.h.duyck@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:44320 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753179AbaLJJxR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 04:53:17 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 04828-08 for <netdev@vger.kernel.org>;
 Wed, 10 Dec 2014 09:53:06 +0000 (GMT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CA09D86@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTGFpZ2h0DQo+IEZyb206IEFsZXhhbmRlciBEdXljaw0KPiA+IFRoaXMgcGF0
Y2ggcmVwbGFjZXMgdGhlIGNhbGxzIHRvIG5ldGRldl9hbGxvY19za2JfaXBfYWxpZ24gaW4gdGhl
DQo+ID4gY29weWJyZWFrIHBhdGhzLg0KPiANCj4gV2h5Pw0KPiANCj4gWW91IHN0aWxsIHdhbnQg
dGhlIElQIGhlYWRlciB0byBiZSBhbGlnbmVkIGFuZCB5b3UgYWxzbyB3YW50IHRoZQ0KPiBtZW1j
cHkoKSB0byBiZSBjb3B5aW5nIGFsaWduZWQgZGF0YS4NCj4gDQo+IEkgc3VzcGVjdCB0aGlzIGZh
aWxzIG9uIGJvdGggY291bnRzPw0KDQpPciBhbSBJIGNvbmZ1c2VkIGJ5IHRoZSBuYW1pbmc/DQoN
CglEYXZpZA0KDQo+IAlEYXZpZA0KPiANCj4gPiBDYzogR2FyeSBaYW1icmFubyA8emFtYnJhbm9A
YnJvYWRjb20uY29tPg0KPiA+IENjOiBGbG9yaWFuIEZhaW5lbGxpIDxmLmZhaW5lbGxpQGdtYWls
LmNvbT4NCj4gPiBDYzogQXJpZWwgRWxpb3IgPGFyaWVsLmVsaW9yQHFsb2dpYy5jb20+DQo+ID4g
U2lnbmVkLW9mZi1ieTogQWxleGFuZGVyIER1eWNrIDxhbGV4YW5kZXIuaC5kdXlja0ByZWRoYXQu
Y29tPg0KPiA+IC0tLQ0KPiA+ICBkcml2ZXJzL25ldC9ldGhlcm5ldC9icm9hZGNvbS9iNDQuYyAg
ICAgICAgICAgICB8ICAgIDIgKy0NCj4gPiAgZHJpdmVycy9uZXQvZXRoZXJuZXQvYnJvYWRjb20v
YmNtNjN4eF9lbmV0LmMgICAgfCAgICAyICstDQo+ID4gIGRyaXZlcnMvbmV0L2V0aGVybmV0L2Jy
b2FkY29tL2JueDJ4L2JueDJ4X2Ntbi5jIHwgICAgMiArLQ0KPiA+ICAzIGZpbGVzIGNoYW5nZWQs
IDMgaW5zZXJ0aW9ucygrKSwgMyBkZWxldGlvbnMoLSkNCj4gPg0KPiA+IGRpZmYgLS1naXQgYS9k
cml2ZXJzL25ldC9ldGhlcm5ldC9icm9hZGNvbS9iNDQuYyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0
L2Jyb2FkY29tL2I0NC5jDQo+ID4gaW5kZXggZmZlYWY0Ny4uZDg2ZDZiYSAxMDA2NDQNCj4gPiAt
LS0gYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9icm9hZGNvbS9iNDQuYw0KPiA+ICsrKyBiL2RyaXZl
cnMvbmV0L2V0aGVybmV0L2Jyb2FkY29tL2I0NC5jDQo+ID4gQEAgLTgzNiw3ICs4MzYsNyBAQCBz
dGF0aWMgaW50IGI0NF9yeChzdHJ1Y3QgYjQ0ICpicCwgaW50IGJ1ZGdldCkNCj4gPiAgCQkJc3Ry
dWN0IHNrX2J1ZmYgKmNvcHlfc2tiOw0KPiA+DQo+ID4gIAkJCWI0NF9yZWN5Y2xlX3J4KGJwLCBj
b25zLCBicC0+cnhfcHJvZCk7DQo+ID4gLQkJCWNvcHlfc2tiID0gbmV0ZGV2X2FsbG9jX3NrYl9p
cF9hbGlnbihicC0+ZGV2LCBsZW4pOw0KPiA+ICsJCQljb3B5X3NrYiA9IG5hcGlfYWxsb2Nfc2ti
KCZicC0+bmFwaSwgbGVuKTsNCj4gPiAgCQkJaWYgKGNvcHlfc2tiID09IE5VTEwpDQo+ID4gIAkJ
CQlnb3RvIGRyb3BfaXRfbm9fcmVjeWNsZTsNCi4uLg0K
