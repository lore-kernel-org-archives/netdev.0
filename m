From: "Frank.Li@freescale.com" <Frank.Li@freescale.com>
Subject: RE: [PATCH] net: fec: fix potential use after free
Date: Thu, 19 Dec 2013 20:30:14 +0000
Message-ID: <7a8a43fd218241a29be996e8bc62e95f@BLUPR03MB486.namprd03.prod.outlook.com>
References: <1387479182.19078.369.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131219193231.GB14612@netboy>
	 <CAHrpEqQre+Y=+m-RX9nADA2Z7NirxYH0yKCwMSZpnn2GKx0jkw@mail.gmail.com>
 <1387484318.19078.377.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Richard Cochran <richardcochran@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>, Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [207.46.163.240] ([207.46.163.240]:2979 "EHLO
	na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756313Ab3LSUcH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 15:32:07 -0500
In-Reply-To: <1387484318.19078.377.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBFcmljIER1bWF6ZXQgW21haWx0
bzplcmljLmR1bWF6ZXRAZ21haWwuY29tXQ0KPiBTZW50OiBUaHVyc2RheSwgRGVjZW1iZXIgMTks
IDIwMTMgMjoxOSBQTQ0KPiBUbzogRnJhbmsgTGkNCj4gQ2M6IFJpY2hhcmQgQ29jaHJhbjsgRGF2
aWQgTWlsbGVyOyBuZXRkZXY7IExpIEZyYW5rLUIyMDU5Ng0KPiBTdWJqZWN0OiBSZTogW1BBVENI
XSBuZXQ6IGZlYzogZml4IHBvdGVudGlhbCB1c2UgYWZ0ZXIgZnJlZQ0KPiANCj4gT24gVGh1LCAy
MDEzLTEyLTE5IGF0IDE0OjA1IC0wNjAwLCBGcmFuayBMaSB3cm90ZToNCj4gDQo+ID4gSSB0aGlu
ayBJdCBpcyBub3QgcmVsYXRlZCB3aXRoIGh3X2xvY2suICBBZnRlciB0cmlnZ2VyIHRyYW5zZmVy
LCB0aGVyZQ0KPiA+IGFyZSBwb3NzaWJpbGl0eSB0aGF0IHR4IGNvbXBsZXRlZCBpbW1lZGlhdGVs
eSBhbmQgaXJxIGhhbmRsZSB3aWxsIGZyZWUNCj4gPiBza2IuDQo+IA0KPiBXZWxsLCBiZWZvcmUg
dGhlIGRlNWZiMGEwNTM0OCBjb21taXQsIHR4IGNvbXBsZXRpb24gYW5kIHN0YXJ0X3htaXQoKSBj
b3VsZCBub3QNCj4gcnVuIGluIC8vDQo+IA0KPiBTbyBod19sb2NrIHdhcyBlZmZlY3RpdmVseSBw
cmV2ZW50aW5nIHRoZSBpc3N1ZS4NCj4gCQ0KDQpZZXMsIElSUSBoYW5kbGUgd2lsbCB3YWl0IGZv
ciBzcGluX2xvY2suIA0K
