From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch 4/4] s390/net: fix format string mismatches
Date: Tue, 27 May 2014 09:34:20 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1724E324@AcuExch.aculab.com>
References: <20140527091341.417448231@de.ibm.com>
 <20140527091400.422890684@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
	Ursula Braun <ursula.braun@de.ibm.com>,
	Toralf Foerster <toralf.foerster@gmx.de>
To: "'frank.blaschka@de.ibm.com'" <frank.blaschka@de.ibm.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:50313 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751777AbaE0JfQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 05:35:16 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 31191-03 for <netdev@vger.kernel.org>;
 Tue, 27 May 2014 10:35:06 +0100 (BST)
In-Reply-To: <20140527091400.422890684@de.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogZnJhbmsuYmxhc2Noa2FAZGUuaWJtLmNvbQ0KPiBGcm9tOiBVcnN1bGEgQnJhdW4gPHVy
c3VsYS5icmF1bkBkZS5pYm0uY29tPg0KPiANCj4gY3BwY2hlY2sgYmxhbWVkIHNvbWUgaXNzdWVz
IGluIGRyaXZlcnMvczM5MC9uZXQvLi4uDQo+IFRoZXkgYXJlIGZpeGVkIGhlcmUuDQouLi4NCj4g
ZGlmZiAtLWdpdCBhL2RyaXZlcnMvczM5MC9uZXQvY3RjbV9zeXNmcy5jIGIvZHJpdmVycy9zMzkw
L25ldC9jdGNtX3N5c2ZzLmMNCj4gaW5kZXggOTg1YjVkYy4uODgzZjcxMyAxMDA2NDQNCj4gLS0t
IGEvZHJpdmVycy9zMzkwL25ldC9jdGNtX3N5c2ZzLmMNCj4gKysrIGIvZHJpdmVycy9zMzkwL25l
dC9jdGNtX3N5c2ZzLmMNCj4gQEAgLTM0LDggKzM0LDkgQEAgc3RhdGljIHNzaXplX3QgY3RjbV9i
dWZmZXJfd3JpdGUoc3RydWN0IGRldmljZSAqZGV2LA0KPiAgCQlzdHJ1Y3QgZGV2aWNlX2F0dHJp
YnV0ZSAqYXR0ciwgY29uc3QgY2hhciAqYnVmLCBzaXplX3QgY291bnQpDQo+ICB7DQo+ICAJc3Ry
dWN0IG5ldF9kZXZpY2UgKm5kZXY7DQo+IC0JaW50IGJzMTsNCj4gKwl1bnNpZ25lZCBpbnQgYnMx
Ow0KPiAgCXN0cnVjdCBjdGNtX3ByaXYgKnByaXYgPSBkZXZfZ2V0X2RydmRhdGEoZGV2KTsNCj4g
KwlpbnQgcmM7DQo+IA0KPiAgCW5kZXYgPSBwcml2LT5jaGFubmVsW0NUQ01fUkVBRF0tPm5ldGRl
djsNCj4gIAlpZiAoIShwcml2ICYmIHByaXYtPmNoYW5uZWxbQ1RDTV9SRUFEXSAmJiBuZGV2KSkg
ew0KPiBAQCAtNDMsNyArNDQsOSBAQCBzdGF0aWMgc3NpemVfdCBjdGNtX2J1ZmZlcl93cml0ZShz
dHJ1Y3QgZGV2aWNlICpkZXYsDQo+ICAJCXJldHVybiAtRU5PREVWOw0KPiAgCX0NCj4gDQo+IC0J
c3NjYW5mKGJ1ZiwgIiV1IiwgJmJzMSk7DQo+ICsJcmMgPSAgc3NjYW5mKGJ1ZiwgIiV1IiwgJmJz
MSk7DQoNClRoZXJlIGlzIGEgc3BhcmUgJyAnIGhlcmUuDQpJJ2QgaGF2ZSB0aG91Z2h0IHRoYXQg
dGhlcmUgaXMgYSBzdHJ0b3VsKCkgZnVuY3Rpb24gdGhhdCBnaXZlcw0KbXVjaCBjbGVhcmVyIGVy
cm9yIGRldGVjdGlvbiB0aGFuIHNzY2FuZigpLg0KDQo+ICsJaWYgKHJjICE9IDEpDQo+ICsJCQkJ
CWdvdG8gZWludmFsOw0KDQphbmQgc29tZXRoaW5nIG9kZCB3aXRoIHRoZSBpbmRlbnRhdGlvbiBo
ZXJlLg0KYW5kIHNvbWUgdGFiL3NwYWNlIGZ1YmFyIGxhdGVyIG9uLi4uDQoNCglEYXZpZA0KDQo=
