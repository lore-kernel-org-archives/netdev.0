From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v1 4/6] net: fec: Increase buffer descriptor entry number
Date: Fri, 30 May 2014 15:34:51 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17250953@AcuExch.aculab.com>
References: <1401415552-2263-1-git-send-email-b38611@freescale.com>
	 <1401415552-2263-5-git-send-email-b38611@freescale.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1725053E@AcuExch.aculab.com>
	 <bf938381e86b4ef5b4e3cbec8733fd2e@BLUPR03MB373.namprd03.prod.outlook.com>
	 <1401455586.3645.96.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140530140137.GC783@arch.cereza>
 <1401461642.3645.104.camel@edumazet-glaptop2.roam.corp.google.com>
 <417d6b6ae192430f9fee0a339074d9c6@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: "'fugang.duan@freescale.com'" <fugang.duan@freescale.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33617 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755556AbaE3Pf7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2014 11:35:59 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 23933-09 for <netdev@vger.kernel.org>;
 Fri, 30 May 2014 16:35:49 +0100 (BST)
In-Reply-To: <417d6b6ae192430f9fee0a339074d9c6@BLUPR03MB373.namprd03.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogZnVnYW5nLmR1YW5AZnJlZXNjYWxlLmNvbQ0KPiA+NjRLQiBUU08gcGFja2V0LCB3aXRo
IE1TUz0xNDYwIC0+IDQ0IHNlZ21lbnRzICAoNDQqMTQ2MCA9IDY0MjQwKSB3aXRoDQo+ID5NU1M9
MTQ0OCAoVENQIHRpbWVzdGFtcHMpIC0+IDQ1IHNlZ21lbnRzICAoNDUqMTQ0OCA9IDY1MTYwKQ0K
PiA+DQo+ID5UaGlzIHNvZnR3YXJlIFRTTyBlbXVsYXRpb24gdXNlcyBhdCBsZWFzdCAyIGRlc2Ny
aXB0b3JzIHBlciBNU1MNCj4gPg0KPiA+b25lIGRlc2NyaXB0b3IgdG8gaG9sZCB0aGUgaGVhZGVy
cyAoZXRoZXJuZXQgKyBpcCArIHRjcCkgb25lIGRlc2NyaXB0b3INCj4gPihvciB0d28pIHRvIGhv
bGQgdGhlIHBheWxvYWQgZm9yIHRoaXMgTVNTDQo+ID4NCj4gVGhhbmtzIGZvciBFcmljJ3MgZGV0
YWlsIGV4cGxhaW4uDQo+IA0KPiBJZiBmcmFnIHBhZ2UgZGF0YSBpcyBub3QgbWF0Y2ggdGhlIGFs
aWdubWVudCBmb3IgZXRoZXJuZXQgRE1BIGNvbnRyb2xsZXIsDQo+IHRoZXJlIG5lZWQgdGhyZWUg
ZGVzY3JpcHRvciBmb3Igb25lIE1TUzoNCj4gT25lIGRlc2NyaXB0b3IgZm9yIGhlYWRlcnMsIG9u
ZSBmb3IgdGhlIGZpcnN0IG5vbi1hbGlnbiBieXRlcyBjb3BpZWQgZnJvbQ0KPiBmcmFnIHBhZ2Us
IG9uZSBmb3IgdGhlIHJlc3Qgb2YgZnJhZyBwYWdlLg0KPiANCj4gU28gb25lIGZyYW1lIG1heSBj
b3N0IGRlc2NyaXB0b3IgbnVtYmVyIGlzOiAzIHggNDUNCg0KTm8gLSB0aGF0IGlzIDQ1IGZyYW1l
cywgdHlwaWNhbGx5IG5lZWRpbmcgMyByaW5nIGVudHJpZXMgZWFjaC4NCg0KPiBBbmQgSSB3aWxs
IGFkZCBpbnRlcnJ1cHQgY29hbGVzY2luZyBzdXBwb3J0IGZvciB0eCBhbmQgcngsIHdoaWNoIGFs
c28gY29zdCBzb21lIG1vcmUgZGVzY3JpcHRvcnMuDQo+IA0KPiBTbyB0aGUgZGVzY3JpcHRvcnMg
c2xvdHMgc2V0IHRvIDUxMiBpcyBub3QgYmlnLCBqdXN0IGlzIHJlYXNvbmFibGUuIERvIHlvdSB0
aGluayA/DQoNClNvZnR3YXJlIFRTTyBnZW5lcmF0ZXMgbG90cyBvZiBzZXBhcmF0ZSBldGhlcm5l
dCBmcmFtZXMsIHRoZXJlIGlzIG5vDQphYnNvbHV0ZSByZXF1aXJlbWVudCB0byBiZSBhYmxlIHRv
IHB1dCBhbGwgb2YgdGhlbSBpbnRvIHRoZSB0eCByaW5nIGF0IG9uY2UuDQoNClRoZSByZXF1aXJl
ZCBzaXplIGZvciB0aGUgdHggcmluZyBpcyBtdWNoIG1vcmUgbGlrZWx5IHRvIGJlIHJlbGF0ZWQN
CnRvIGFueSBpbnRlcnJ1cHQgbWl0aWdhdGlvbiB0aGF0IGRlbGF5cyB0aGUgcmVmaWxsaW5nIG9m
IHJpbmcgZW50cmllcy4NCjUxMiBzb3VuZHMgbGlrZSBhIGxvdCBvZiB0eCByaW5nIGVudHJpZXMu
DQoNClRoZSByZWNlaXZlIHJpbmcgZG9lc24ndCBuZWVkIHRvIGFsbG93IGZvciBmcmFnbWVudHMg
LSB5b3VyIGRyaXZlcg0KaXMgaW4gY29udHJvbCBvZiBhbGxvY2F0aW5nIHRoZSBidWZmZXJzLg0K
SSBkaWRuJ3QgdW5kZXJzdGFuZCB3aHkgeW91J3ZlIGJhc2VkIHRoZSBudW1iZXIgb2Ygcnggcmlu
ZyBlbnRyaWVzDQpvbiBQQUdFX1NJWkUgLSBJSVJDIHRoYXQgbWlnaHQgYmUgNjRrLCBvciBldmVu
IGxhcmdlci4NCkknZCBoYXZlIGV4cGVjdGVkIDEyOCBvciAyNTYgcnggcmluZyBlbnRyaWVzIHRv
IGJlIHR5cGljYWwsIGJ1dA0KaG93IG1hbnkgYXJlIG5lZWRlZCBpcyBhIHNlcGFyYXRlIGlzc3Vl
Lg0KSWYgdGhlIHN5c3RlbSBjYW4ga2VlcCB1cCB3aXRoIHRoZSBtYXhpbXVtIGV0aGVybmV0IGRh
dGEgcmF0ZQ0KSSdkIGV4cGVjdCB0aGF0IGEgc21hbGxlciBudW1iZXIgd291bGQgYmUgZmluZS4N
CklmIGl0IGNhbid0IGtlZXAgdXAgeW91J2xsIGxvc2UgcGFja2V0cyBhbnl3YXkuDQpBZ2dyZXNz
aXZlIHBvd2VyIHNhdmluZyAod2l0aCB3YWtlIG9uIExBTikgbWlnaHQgbmVlZCBtb3JlLg0KDQoJ
RGF2aWQNCg0K
