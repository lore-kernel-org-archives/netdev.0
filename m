From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 0/1] mv643xx_eth: Disable TSO by default
Date: Mon, 3 Nov 2014 14:51:50 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9E44F5@AcuExch.aculab.com>
References: <1414855820-15094-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1414862766.31792.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:48786 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752300AbaKCOyd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 09:54:33 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11781-07 for <netdev@vger.kernel.org>;
 Mon,  3 Nov 2014 14:54:25 +0000 (GMT)
In-Reply-To: <1414862766.31792.7.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IE9uIFNhdCwgMjAxNC0xMS0wMSBhdCAxMjozMCAtMDMwMCwg
RXplcXVpZWwgR2FyY2lhIHdyb3RlOg0KPiA+IFNldmVyYWwgdXNlcnMgKFsxXSwgWzJdKSBoYXZl
IGJlZW4gcmVwb3J0aW5nIGRhdGEgY29ycnVwdGlvbiB3aXRoIFRTTyBvbg0KPiA+IEtpcmt3b29k
IHBsYXRmb3JtcyAoaS5lLiB1c2luZyB0aGUgbXY2NDN4eF9ldGggZHJpdmVyKS4NCj4gPg0KPiA+
IFVudGlsIHdlIG1hbmFnZSB0byBmaW5kIHdoYXQncyBjYXVzaW5nIHRoaXMsIHRoaXMgc2ltcGxl
IHBhdGNoIHdpbGwgbWFrZQ0KPiA+IHRoZSBUU08gcGF0aCBkaXNhYmxlZCBieSBkZWZhdWx0LiBU
aGlzIHBhdGNoIHNob3VsZCBiZSBxdWV1ZWQgZm9yIHN0YWJsZSwNCj4gPiBmaXhpbmcgdGhlIFRT
TyBmZWF0dXJlIGludHJvZHVjZWQgaW4gdjMuMTYuDQo+ID4NCj4gPiBUaGUgY29ycnVwdGlvbiBp
dHNlbGYgaXMgdmVyeSBlYXN5IHRvIHJlcHJvZHVjZTogY2hlY2tpbmcgbWQ1c3VtIG9uIGEgbW91
bnRlZA0KPiA+IE5GUyBkaXJlY3RvcnkgZ2l2ZXMgYSBkaWZmZXJlbnQgcmVzdWx0IGVhY2ggdGlt
ZS4gU2FtZSB0ZXN0cyB1c2luZyB0aGUgbXZuZXRhDQo+ID4gZHJpdmVyIChBcm1hZGEgMzcwLzM4
eC9YUCBTb0MpIHBhc3Mgd2l0aCBubyBpc3N1ZXMuDQo+ID4NCj4gPiBGcmFua2x5LCBJJ20gYSBi
aXQgcHV6emxlZCBhYm91dCB0aGlzLCBhbmQgc28gYW55IGlkZWFzIG9yIGRlYnVnZ2luZyBoaW50
cw0KPiA+IGFyZSB3ZWxsIHJlY2VpdmVkLg0KPiANCj4gbGFjayBvZiBiYXJyaWVycyBtYXliZSA/
DQo+IA0KPiBJdCBzZWVtcyB5b3UgbWlnaHQgbmVlZCB0byBwb3B1bGF0ZSBhbGwgVFggZGVzY3Jp
cHRvcnMgYnV0IGRlbGF5IHRoZQ0KPiBmaXJzdCwgbGlrZSBkb2luZyB0aGUgcG9wdWxhdGUgaW4g
ZGVzY2VuZGluZyBvcmRlci4NCj4gDQo+IElmIHlvdSB0YWtlIGEgbG9vayBhdCB0eHFfc3VibWl0
X3NrYigpLCB5b3UnbGwgc2VlIHRoZSBmaW5hbA0KPiBkZXNjLT5jbWRfc3RzID0gY21kX3N0cyAo
bGluZSA5NTkpIGlzIGRvbmUgX2FmdGVyXyBmcmFncyB3ZXJlIGNvb2tlZCBieQ0KPiB0eHFfc3Vi
bWl0X2ZyYWdfc2tiKCkNCj4gDQo+IFlvdSBzaG91bGQga2ljayB0aGUgbmljayBvbmx5IHdoZW4g
YWxsIFRYIGRlc2NyaXB0b3JzIGFyZSByZWFkeSBhbmQNCj4gY29tbWl0dGVkIHRvIG1lbW9yeS4N
Cg0KRG9uJ3QgZm9yZ2V0IHRoYXQgdGhlIG5pY2sgbWlnaHQgcHJvY2VzcyB0aGUgZmlyc3QgZGVz
Y3JpcHRvciB3aXRob3V0DQpiZWluZyBnaXZlbiBhICdraWNrJyAtIGl0IHdpbGwgcmVhZCBpdCB3
aGVuIGl0IGZpbmlzaGVzIHByb2Nlc3NpbmcgdGhlDQpwcmV2aW91cyBmcmFtZS4NClRoaXMgYWxz
byBtZWFucyB0aGF0IHlvdSBoYXZlIHRvIGJlIGNhcmVmdWwgYWJvdXQgdGhlIG9yZGVyIG9mIHRo
ZSB3cml0ZXMNCnRvIHRoZSBmaXJzdCBkZXNjcmlwdG9yLg0KDQoJRGF2aWQNCg0K
