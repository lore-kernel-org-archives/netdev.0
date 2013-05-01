From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 net-next] af_unix: fix a fatal race with bit fields
Date: Wed, 1 May 2013 16:53:48 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B721C@saturn3.aculab.com>
References: <1367370761.11020.22.camel@edumazet-glaptop> <1367372393.22115.6.camel@pasglop> <20130501.033650.703182794549888825.davem@davemloft.net> <1367421843.11020.43.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <benh@kernel.crashing.org>, <netdev@vger.kernel.org>,
	<paulus@samba.org>, <ambrose@google.com>,
	<linuxppc-dev@lists.ozlabs.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:58840 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1761541Ab3EAPzk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 May 2013 11:55:40 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 01005-09 for <netdev@vger.kernel.org>;
 Wed,  1 May 2013 16:55:36 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1367421843.11020.43.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBkaWZmIC0tZ2l0IGEvaW5jbHVkZS9uZXQvYWZfdW5peC5oIGIvaW5jbHVkZS9uZXQvYWZfdW5p
eC5oDQo+IGluZGV4IGE4ODM2ZTguLmRiZGZkMmIgMTAwNjQ0DQo+IC0tLSBhL2luY2x1ZGUvbmV0
L2FmX3VuaXguaA0KPiArKysgYi9pbmNsdWRlL25ldC9hZl91bml4LmgNCj4gQEAgLTU3LDkgKzU3
LDEwIEBAIHN0cnVjdCB1bml4X3NvY2sgew0KPiAgCXN0cnVjdCBsaXN0X2hlYWQJbGluazsNCj4g
IAlhdG9taWNfbG9uZ190CQlpbmZsaWdodDsNCj4gIAlzcGlubG9ja190CQlsb2NrOw0KPiAtCXVu
c2lnbmVkIGludAkJZ2NfY2FuZGlkYXRlIDogMTsNCj4gLQl1bnNpZ25lZCBpbnQJCWdjX21heWJl
X2N5Y2xlIDogMTsNCj4gIAl1bnNpZ25lZCBjaGFyCQlyZWN1cnNpb25fbGV2ZWw7DQo+ICsJdW5z
aWduZWQgbG9uZwkJZ2NfZmxhZ3M7DQo+ICsjZGVmaW5lIFVOSVhfR0NfQ0FORElEQVRFCTANCj4g
KyNkZWZpbmUgVU5JWF9HQ19NQVlCRV9DWUNMRQkxDQo+ICAJc3RydWN0IHNvY2tldF93cQlwZWVy
X3dxOw0KPiAgfTsNCg0KV2h5IG5vdCBqdXN0IGNoYW5nZSBnY19jYW5kaWRhdGUgYW5kIGdjX21h
eWJlX2N5Y2xlIHRvDQp1bnNpZ25lZCBjaGFyPw0KSXQgbWlnaHQgcmVkdWNlIHRoZSBudW1iZXIg
b2YgcGFkIGJ5dGVzIHNvbWV3aGF0Lg0KDQoJRGF2aWQNCg0K
