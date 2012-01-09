From: Manfred Rudigier <manfred.rudigier@omicron.at>
Subject: RE: [PATCH] gianfar: Fix invalid TX frames returned on error queue
 when time stamping.
Date: Mon, 9 Jan 2012 11:43:10 +0100
Message-ID: <95DC1AA8EC908B48939B72CF375AA5E3013A991400@alice.at.omicron.at>
References: <1325775021-23049-1-git-send-email-manfred.rudigier@omicron.at>
	 <20120105.132637.2130515220408371607.davem@davemloft.net>
	 <95DC1AA8EC908B48939B72CF375AA5E3013A99124D@alice.at.omicron.at>
	 <1326095038.2627.4.camel@edumazet-laptop>
	 <95DC1AA8EC908B48939B72CF375AA5E3013A99137D@alice.at.omicron.at>
 <1326103126.2407.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"afleming@freescale.com" <afleming@freescale.com>,
	"avorontsov@mvista.com" <avorontsov@mvista.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:60930 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751403Ab2AIKna (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jan 2012 05:43:30 -0500
In-Reply-To: <1326103126.2407.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IFttYWlsdG86ZXJpYy5kdW1hemV0QGdtYWlsLmNvbV0NClNlbnQ6
IE1vbmRheSwgSmFudWFyeSAwOSwgMjAxMiAxMDo1OQ0KDQo+TGUgbHVuZGkgMDkgamFudmllciAy
MDEyIMOgIDEwOjM2ICswMTAwLCBNYW5mcmVkIFJ1ZGlnaWVyIGEgw6ljcml0IDoNCj4NCj4+IEkg
aGF2ZSB0cmllZCB5b3VyIHN1Z2dlc3RlZCBzdGVhbCBzZXF1ZW5jZSwgYnV0IGl0IGNyYXNoZWQu
DQo+PiBJIHNlZSB0aGF0IHRoZXJlIGlzIGFsc28gYSBkZXN0cnVjdG9yIC0gd2hlbiBJIHVzZSB0
aGUgc2tiX29ycGhhbiBmdW5jdGlvbg0KPih3aGljaCBjYWxscyB0aGUgZGVzdHJ1Y3RvcikgbGlr
ZSB0aGlzIGl0IHdvcmtzOg0KPj4NCj4+IAlza2JfbmV3LT5zayA9IHNrYi0+c2s7DQo+PiAJc2ti
X29ycGhhbihza2IpOw0KPj4gCWtmcmVlX3NrYihza2IpOw0KPj4NCj4+IElzIHRoaXMgdGhlIGNv
cnJlY3Qgc29sdXRpb24/DQo+DQo+SSBkb250IHRoaW5rIHNvLg0KPg0KPmRlc3RydWN0b3IgYW5k
IHNrIGFyZSBjb3VwbGVkLCB5b3UgY2FudCBzdGVhbCBvbmUgYW5kIGxldCB0aGUgb3RoZXINCj51
bnRvdWNoZWQuDQoNCklmIEkgdW5kZXJzdGFuZCB5b3UgY29ycmVjdGx5LCB3ZSBtdXN0IGFsc28g
c3RlYWwgdGhlIGRlc3RydWN0b3IgbGlrZSB0aGlzOg0KDQoJc2tiX25ldy0+c2sgPSBza2ItPnNr
Ow0KCXNrYl9uZXctPmRlc3RydWN0b3IgPSBza2ItPmRlc3RydWN0b3I7DQoJc2tiLT5zayA9IE5V
TEw7DQoJc2tiLT5kZXN0cnVjdG9yID0gTlVMTDsNCglrZnJlZV9za2Ioc2tiKTsNCg0KVGhlbiB0
aGUgZGVzdHJ1Y3RvciB3aWxsIGJlIGNhbGxlZCBhdCB0aGUgZW5kIG9mIHRoZSBza2JfdHN0YW1w
X3R4IGZ1bmN0aW9uLCB3aGljaCBzaG91bGQgYmUgZmluZSwgcmlnaHQ/DQo=
