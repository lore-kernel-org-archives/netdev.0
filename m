From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH v1 4/6] net: fec: Increase buffer descriptor entry number
Date: Fri, 30 May 2014 15:46:49 +0000
Message-ID: <e312c3c2120f4370bb9e9f5ab8a8c119@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1401415552-2263-1-git-send-email-b38611@freescale.com>
	 <1401415552-2263-5-git-send-email-b38611@freescale.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1725053E@AcuExch.aculab.com>
	 <bf938381e86b4ef5b4e3cbec8733fd2e@BLUPR03MB373.namprd03.prod.outlook.com>
	 <1401455586.3645.96.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140530140137.GC783@arch.cereza>
	 <1401461642.3645.104.camel@edumazet-glaptop2.roam.corp.google.com>
	 <417d6b6ae192430f9fee0a339074d9c6@BLUPR03MB373.namprd03.prod.outlook.com>
 <1401464457.3645.109.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>,
	David Laight <David.Laight@ACULAB.COM>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0207.outbound.protection.outlook.com ([207.46.163.207]:4629
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965269AbaE3Pqv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2014 11:46:51 -0400
In-Reply-To: <1401464457.3645.109.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPiBEYXRhOiBGcmlkYXks
IE1heSAzMCwgMjAxNCAxMTo0MSBQTQ0KPlRvOiBEdWFuIEZ1Z2FuZy1CMzg2MTENCj5DYzogZXpl
cXVpZWwuZ2FyY2lhQGZyZWUtZWxlY3Ryb25zLmNvbTsgRGF2aWQgTGFpZ2h0OyBMaSBGcmFuay1C
MjA1OTY7DQo+ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldDsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsgc2hh
d24uZ3VvQGxpbmFyby5vcmc7DQo+Ymh1dGNoaW5nc0Bzb2xhcmZsYXJlLmNvbTsgc3RlcGhlbkBu
ZXR3b3JrcGx1bWJlci5vcmcNCj5TdWJqZWN0OiBSRTogW1BBVENIIHYxIDQvNl0gbmV0OiBmZWM6
IEluY3JlYXNlIGJ1ZmZlciBkZXNjcmlwdG9yIGVudHJ5DQo+bnVtYmVyDQo+DQo+T24gRnJpLCAy
MDE0LTA1LTMwIGF0IDE1OjA4ICswMDAwLCBmdWdhbmcuZHVhbkBmcmVlc2NhbGUuY29tIHdyb3Rl
Og0KPg0KPj4gSWYgZnJhZyBwYWdlIGRhdGEgaXMgbm90IG1hdGNoIHRoZSBhbGlnbm1lbnQgZm9y
IGV0aGVybmV0IERNQSBjb250cm9sbGVyLA0KPnRoZXJlIG5lZWQgdGhyZWUgZGVzY3JpcHRvciBm
b3Igb25lIE1TUzoNCj4+IE9uZSBkZXNjcmlwdG9yIGZvciBoZWFkZXJzLCBvbmUgZm9yIHRoZSBm
aXJzdCBub24tYWxpZ24gYnl0ZXMgY29waWVkDQo+ZnJvbSBmcmFnIHBhZ2UsIG9uZSBmb3IgdGhl
IHJlc3Qgb2YgZnJhZyBwYWdlLg0KPj4NCj4NCj5Zb3UgY291bGQgYXZvaWQgdGhlIDJuZCBkZXNj
cmlwdG9yLCBieSBjb3B5aW5nIHRoZSB1bmFsaWduZWQgcGFydCBvZiB0aGUNCj5wYXlsb2FkIGlu
dG8gZmlyc3QgZGVzY3JpcHRvciAoY29udGFpbmluZyBoZWFkZXJzIDogYWJvdXQgNjYgYnl0ZXMg
b3Igc28NCj55b3UgaGF2ZSByb29tLCBpZiBub3QsIGluY3JlYXNlIHRoZSAxMjggYnl0ZXMgcm9v
bSB0byAxOTIgYnl0ZXMpDQo+DQo+PiBTbyBvbmUgZnJhbWUgbWF5IGNvc3QgZGVzY3JpcHRvciBu
dW1iZXIgaXM6IDMgeCA0NQ0KPg0KPk1heS4uLiBidXQgaW4gZ2VuZXJhbCBpdCB3b3VsZCBiZSBj
bG9zZXIgb2YgMiAqIDQ1DQo+DQpHb29kIGlkZWEhDQoNCj4NCj4+DQo+PiBTbyB0aGUgZGVzY3Jp
cHRvcnMgc2xvdHMgc2V0IHRvIDUxMiBpcyBub3QgYmlnLCBqdXN0IGlzIHJlYXNvbmFibGUuIERv
DQo+eW91IHRoaW5rID8NCj4NCj5JIGJlbGlldmUgaXQgaXMgZmluZSA6IHRoYXQgaXMgYWJvdXQg
NSA2NEtCIFRTTyBwYWNrZXRzLg0KPg0KDQpUaGFua3MsDQpBbmR5DQo=
