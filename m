From: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Subject: RE: [PATCH v2] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Fri, 11 Mar 2016 07:14:43 +0000
Message-ID: <KL1PR06MB10315B45ADA2037A5AA85A56C3B50@KL1PR06MB1031.apcprd06.prod.outlook.com>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1457019515-21158-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <56DC1561.9060306@hartkopp.net>
 <SG2PR06MB10386D712BC8C345DF726523C3B10@SG2PR06MB1038.apcprd06.prod.outlook.com>
 <56DD36F5.2000308@pengutronix.de>
 <SG2PR06MB1038DD47FAFF354C99AF2E4FC3B10@SG2PR06MB1038.apcprd06.prod.outlook.com>
 <56DE8345.50901@hartkopp.net>
 <SG2PR06MB1038B71C7921984611F72CF5C3B20@SG2PR06MB1038.apcprd06.prod.outlook.com>
 <56DEC49D.4@hartkopp.net>
 <SG2PR06MB10388F87746A1191E51B199FC3B20@SG2PR06MB1038.apcprd06.prod.outlook.com>
 <56DF0900.6090906@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-renesas-soc@vger.kernel.org"
	<linux-renesas-soc@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"geert+renesas@glider.be" <geert+renesas@glider.be>,
	Chris Paterson <Chris.Paterson2@renesas.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"corbet@lwn.net" <corbet@lwn.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <56DF0900.6090906@hartkopp.net>
Content-Language: en-US
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SGkgT2xpdmVyLCBNYXJjLA0KDQo+IE9uIDAzLzA4LzIwMTYgMDE6NDggUE0sIFJhbWVzaCBTaGFu
bXVnYXN1bmRhcmFtIHdyb3RlOg0KPiANCj4gPj4gSW4gZmFjdCB5b3UgcHJvdmlkZWQgYSBDQU4g
ZHJpdmVyIHdoaWNoIGlzICJDQU4tRkQtb25seSIuDQo+ID4NCj4gPiBZZXMuIFRoYXQncyB0aGUg
c3RhdHVzIG9mIGN1cnJlbnQgc3VibWlzc2lvbi4NCg0KKC4uLikNCg0KPiA+DQo+ID4gSSBkaWQg
dHJ5IHRoaXMgb3B0aW9uIGVhcmxpZXIgYnV0IHRoZXJlIGFyZSB0d28gcHJvYmxlbXMgd2l0aCB0
aGlzDQo+IG1ldGhvZC4NCj4gPg0KPiA+IDEpIEJlbG93IGNvbmZpZ3VyYXRpb24gaXMgbm90IHBv
c3NpYmxlDQo+ID4NCj4gPiBpcCBsaW5rIHNldCBjYW4wIHVwIHR5cGUgY2FuIGJpdHJhdGUgMTAw
MDAwMCBkYml0cmF0ZSAxMDAwMDAwIGZkIG9uDQo+ID4NCj4gPiAiZmQgb24iIC0+IFRoaXMgaXMg
bm90IGFsbG93ZWQgYmVjYXVzZSBDQU5fQ1RSTE1PREVfRkQgYml0IGlzIG5vdCBzZXQgaW4NCj4g
Y3RybG1vZGVfc3VwcG9ydGVkLg0KPiA+DQo+ID4gMikgSWYgSSBpZ25vcmUgImZkIG9uIiwgbXkg
aW50ZXJmYWNlIE1UVSBzdGF5cyBhcyBDQU5fTVRVIG9ubHkuIElmIEkNCj4gaGF2ZSB0byBjaGFu
Z2UgdGhlIE1UVSBhbG9uZSB0byBDQU5GRF9NVFUgdXNpbmcgYW5vdGhlciBuZXRsaW5rIG1lc3Nh
Z2UsDQo+IGl0IGFnYWluIGNoZWNrcyBjdHJsbW9kZV9zdXBwb3J0ZWQgd2hlcmUgaXQgd291bGQg
ZmFpbC4gSSBoYXZlIHRoZSBvcHRpb24NCj4gb2YgcHJvdmlkaW5nIG15IG93biBjaGFuZ2VfbXR1
IGZ1bmN0aW9uICYgaWdub3JlIHRoaXMgY2hlY2sgYnV0IHR3bw0KPiBjb25maWd1cmF0aW9uIG1l
c3NhZ2VzIGFyZSByZXF1aXJlZCBmb3IgbXkgZHJpdmVyIGFsb25lIDotKC4NCj4gPg0KPiA+IEJv
dGggdGhlc2UgYW5vbWFsaWVzIGFyZSBhZGRyZXNzZWQgd2l0aCB0aGUgY3VycmVudCBjaGVjayBJ
IGhhdmUuDQo+IA0KPiBPaCAtIHlvdSBhcmUgcmlnaHQgd2l0aCBjb21wbGFpbmluZyBhYm91dCB0
aGlzIGluY29uc2lzdGVuY3kuDQo+IA0KPiBDYW4geW91IGNoZWNrIG15IFJGQyBwYXRjaCBmb3Ig
TGludXggc3RhYmxlIEkganVzdCBzZW50IG9uIHRoZSBtYWlsaW5nDQo+IGxpc3Q/DQo+IGh0dHA6
Ly9tYXJjLmluZm8vP2w9bGludXgtY2FuJm09MTQ1NzQ1NzI0OTE3OTc2Jnc9Mg0KDQpBcyB3ZSBh
cmUgZml4aW5nIHRoaXMgaXNzdWUgaW4gQ0FOIGRldi5jLCBJJ2xsIHJlbW92ZSB0aGlzIGNoZWNr
IGluIG5kb19vcGVuIGFuZCBzZXQgQ0FOX0NUUkxNT0RFX0ZEIGZsYWcgaW4gY3RybG1vZGUgJiBy
ZW1vdmUgdGhlIGZsYWcgaW4gY3RybG1vZGVfc3VwcG9ydGVkIGluIHRoZSBuZXh0IHYzIHZlcnNp
b24gb2YgdGhlIHBhdGNoLg0KDQpBcmUgdGhlcmUgYW55IGZ1cnRoZXIgY29tbWVudHMgb24gdjIg
cGF0Y2ggcGxlYXNlPw0KDQpUaGFua3MsDQpSYW1lc2gNCg==
