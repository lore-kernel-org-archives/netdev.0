From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v4 2/8] 6lowpan: add uncompress header size
 function
Date: Wed, 26 Feb 2014 17:05:41 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6CBE9F@AcuExch.aculab.com>
References: <1393430712-11298-1-git-send-email-alex.aring@gmail.com>
 <1393430712-11298-3-git-send-email-alex.aring@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6CBBCA@AcuExch.aculab.com>
 <20140226162008.GA11499@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "alex.bluesman.smirnov@gmail.com" <alex.bluesman.smirnov@gmail.com>,
	"dbaryshkov@gmail.com" <dbaryshkov@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-zigbee-devel@lists.sourceforge.net"
	<linux-zigbee-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"martin.townsend@xsilon.com" <martin.townsend@xsilon.com>
To: 'Alexander Aring' <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49204 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752671AbaBZRGr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Feb 2014 12:06:47 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 15962-06 for <netdev@vger.kernel.org>;
 Wed, 26 Feb 2014 17:06:44 +0000 (GMT)
In-Reply-To: <20140226162008.GA11499@omega>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQWxleGFuZGVyIEFyaW5nIA0KPiBPbiBXZWQsIEZlYiAyNiwgMjAxNCBhdCAwNDoxMDow
NVBNICswMDAwLCBEYXZpZCBMYWlnaHQgd3JvdGU6DQo+ID4gRnJvbTogQWxleGFuZGVyIEFyaW5n
DQouLi4NCj4gPiA+ICtzdGF0aWMgaW5saW5lIHU4IGxvd3Bhbl9hZGRyX21vZGVfc2l6ZShjb25z
dCB1OCBhZGRyX21vZGUpDQo+ID4gPiArew0KPiA+ID4gKwlzd2l0Y2ggKGFkZHJfbW9kZSkgew0K
PiA+ID4gKwljYXNlIExPV1BBTl9JUEhDX0FERFJfMDA6DQo+ID4gPiArCQlyZXR1cm4gMTY7DQo+
ID4gPiArCWNhc2UgTE9XUEFOX0lQSENfQUREUl8wMToNCj4gPiA+ICsJCXJldHVybiA4Ow0KPiA+
ID4gKwljYXNlIExPV1BBTl9JUEhDX0FERFJfMDI6DQo+ID4gPiArCQlyZXR1cm4gMjsNCj4gPiA+
ICsJZGVmYXVsdDoNCj4gPiA+ICsJCXJldHVybiAwOw0KPiA+ID4gKwl9DQo+ID4gPiArfQ0KPiA+
DQo+ID4gVGhlIGNvbXBpbGVyIHdpbGwgZ2VuZXJhdGUgbXVjaCBiZXR0ZXIgY29kZSBpZiB5b3Ug
aW5kZXggYW4gYXJyYXkgaW5zdGVhZA0KPiA+IG9mIHVzaW5nIGEgc3dpdGNoIHN0YXRlbWVudC4N
Cj4gPg0KPiA+DQo+IA0KPiBZb3UgbWVhbiBzb21ldGhpbmcgbGlrZToNCj4gDQo+IHN0YXRpYyBp
bmxpbmUgdTggbG93cGFuX2FkZHJfbW9kZV9zaXplKGNvbnN0IHU4IGFkZHJfbW9kZSkNCj4gew0K
PiAgICAgICAgIGNvbnN0IHU4IHJlc1tdID0geyAxNiwgOCwgMiwgMCB9Ow0KPiAgICAgICAgIHJl
dHVybiByZXNbYWRkcl9tb2RlXTsNCj4gfQ0KPiANCj4gb3Igc2hvdWxkIEkgZHJvcCB0aGUgYXJy
YXkgZnJvbSB0aGUgc3RhY2sgYW5kIGRlY2xhcmUgaXQgc3RhdGljPw0KDQpZb3UgZGVmaW5pdGVs
eSB3YW50IHRoZSBhcnJheSB0byBiZSBzdGF0aWMgKGFzIHdlbGwgYXMgY29uc3QpLg0KWW91IGNv
dWxkIGFsc28gdXNlIG5hbWVkIGluaXRpYWxpc2Vycy4NCklmIEkndmUgZ290IHRoZSBzeW50YXgg
cmlnaHQgdGhhdCB3b3VsZCBiZToNCg0KCQlzdGF0aWMgY29uc3QgdTggc2l6ZXNbXSA9IHsNCgkJ
CVtMT1dQQU5fSVBIQ19BRERSXzAwXSA9IDE2LA0KCQkJW0xPV1BBTl9JUEhDX0FERFJfMDFdID0g
OCwNCgkJCVtMT1dQQU5fSVBIQ19BRERSXzAyXSA9IDIsDQoJCX07DQoJCXJldHVybiBzaXplc1th
ZGRyX21vZGVdOw0KDQpXaGV0aGVyIHlvdSBuZWVkIGEgYm91bmQgY2hlY2sgKG9yIHRoZSA0dGgg
YXJyYXkgaW5kZXgpIGRlcGVuZHMgb24gd2hlcmUNCnRoZSBpbnB1dCB2YWx1ZSBjb21lcyBmcm9t
Lg0KDQoJRGF2aWQNCg0K
