From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] ipv6: introduce tcp_v6_iif()
Date: Fri, 17 Oct 2014 16:26:51 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9D8C89@AcuExch.aculab.com>
References: <1413562640.24953.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:58817 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753318AbaJQQ2d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Oct 2014 12:28:33 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21471-07 for <netdev@vger.kernel.org>;
 Fri, 17 Oct 2014 17:28:24 +0100 (BST)
In-Reply-To: <1413562640.24953.26.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IENvbW1pdCA5NzFmMTBlY2ExODYgKCJ0Y3A6IGJldHRlciBU
Q1BfU0tCX0NCIGxheW91dCB0byByZWR1Y2UgY2FjaGUgbGluZQ0KPiBtaXNzZXMiKSBhZGRlZCBh
IHJlZ3Jlc3Npb24gZm9yIFNPX0JJTkRUT0RFVklDRSBvbiBJUHY2Lg0KPiANCj4gVGhpcyBpcyBi
ZWNhdXNlIHdlIHN0aWxsIHVzZSBpbmV0Nl9paWYoKSB3aGljaCBleHBlY3RzIHRoYXQgSVA2IGNv
bnRyb2wNCj4gYmxvY2sgaXMgc3RpbGwgYXQgdGhlIGJlZ2lubmluZyBvZiBza2ItPmNiW10NCj4g
DQo+IFRoaXMgcGF0Y2ggYWRkcyB0Y3BfdjZfaWlmKCkgaGVscGVyIGFuZCB1c2VzIGl0IHdoZXJl
IG5lY2Vzc2FyeS4NCj4gDQo+IEJlY2F1c2UgX19pbmV0Nl9sb29rdXBfc2tiKCkgaXMgdXNlZCBi
eSBUQ1AgYW5kIERDQ1AsIHdlIGFkZCBhbiBpaWYNCj4gcGFyYW1ldGVyIHRvIGl0Lg0KLi4uDQo+
IGRpZmYgLS1naXQgYS9uZXQvaXB2Ni90Y3BfaXB2Ni5jIGIvbmV0L2lwdjYvdGNwX2lwdjYuYw0K
PiBpbmRleCBjZjJlNDVhYjJmYTQuLjgzMTQ5NTUyOWI4MiAxMDA2NDQNCj4gLS0tIGEvbmV0L2lw
djYvdGNwX2lwdjYuYw0KPiArKysgYi9uZXQvaXB2Ni90Y3BfaXB2Ni5jDQo+IEBAIC00MjQsNiAr
NDI0LDcgQEAgc3RhdGljIHZvaWQgdGNwX3Y2X2VycihzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBzdHJ1
Y3QgaW5ldDZfc2tiX3Bhcm0gKm9wdCwNCj4gIAkJaWYgKHNvY2tfb3duZWRfYnlfdXNlcihzaykp
DQo+ICAJCQlnb3RvIG91dDsNCj4gDQo+ICsJCS8qIE5vdGUgOiBXZSB1c2UgaW5ldDZfaWlmKCkg
aGVyZSwgbm90IHRjcF92Nl9paWYoKSAqLw0KPiAgCQlyZXEgPSBpbmV0Nl9jc2tfc2VhcmNoX3Jl
cShzaywgJnByZXYsIHRoLT5kZXN0LCAmaGRyLT5kYWRkciwNCj4gIAkJCQkJICAgJmhkci0+c2Fk
ZHIsIGluZXQ2X2lpZihza2IpKTsNCj4gIAkJaWYgKCFyZXEpDQoNClRoYXQgY29tbWVudCBpc24n
dCBwYXJ0aWN1bGFybHkgaW5mb3JtYXRpdmUuLi4uDQoNCglEYXZpZA0KDQo=
