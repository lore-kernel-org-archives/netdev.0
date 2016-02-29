From: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Subject: RE: [PATCH 1/2] can: rcar_can: Add r8a7795 support
Date: Mon, 29 Feb 2016 14:06:21 +0000
Message-ID: <SG2PR06MB1038B0596DFE68AFE1B7E83BC3BA0@SG2PR06MB1038.apcprd06.prod.outlook.com>
References: <1456737661-20538-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1456737661-20538-2-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <56D411A5.9070706@pengutronix.de>
 <SG2PR06MB10380FC567E038EA92D5401EC3BA0@SG2PR06MB1038.apcprd06.prod.outlook.com>
 <56D416A9.6080608@pengutronix.de> <56D43DC8.8010409@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-renesas-soc@vger.kernel.org"
	<linux-renesas-soc@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chris Paterson <Chris.Paterson2@renesas.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"horms@verge.net.au" <horms@verge.net.au>,
	"magnus.damm@gmail.com" <magnus.damm@gmail.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor3.renesas.com ([210.160.252.173]:14791 "EHLO
	relmlie2.idc.renesas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751041AbcB2OG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 09:06:28 -0500
In-Reply-To: <56D43DC8.8010409@pengutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGkgTWFyYywNCg0KPiBPbiAwMi8yOS8yMDE2IDExOjAwIEFNLCBNYXJjIEtsZWluZS1CdWRkZSB3
cm90ZToNCj4gPiBJIHRoaW5rIGl0J3MgYmV0dGVyIHRvIGZpeCB0aGUgYWxnb3JpdGhtLiBJJ2xs
IGxvb2sgaW50byBpdC4NCj4gDQo+IFdoYXQgYWJvdXQ6DQo+IA0KPiA+IC4vY2FuLWNhbGMtYml0
LXRpbWluZyAtYyAzOTk5OTk5OCByY2FyX2Nhbg0KPiA+IEJpdCB0aW1pbmcgcGFyYW1ldGVycyBm
b3IgcmNhcl9jYW4gd2l0aCAzOS45OTk5OTggTUh6IHJlZiBjbG9jaw0KPiA+IG5vbWluYWwgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICByZWFsIEJpdHJ0ICAgbm9tICByZWFsIFNhbXBQ
DQo+ID4gQml0cmF0ZSBUUVtuc10gUHJTIFBoUzEgUGhTMiBTSlcgQlJQIEJpdHJhdGUgRXJyb3Ig
U2FtcFAgU2FtcFAgRXJyb3INCj4gQ2lCQ1INCj4gPiAxMDAwMDAwICAgIDEyNSAgIDIgICAgMyAg
ICAyICAgMSAgIDUgIDk5OTk5OSAgMC4wJSA3NS4wJSA3NS4wJSAgMC4wJQ0KPiAweDQwMDQwMTAw
DQo+ID4gIDgwMDAwMCAgICAxMjUgICAzICAgIDQgICAgMiAgIDEgICA1ICA3OTk5OTkgIDAuMCUg
ODAuMCUgODAuMCUgIDAuMCUNCj4gMHg2MDA0MDEwMA0KPiA+ICA1MDAwMDAgICAgMTI1ICAgNiAg
ICA3ICAgIDIgICAxICAgNSAgNDk5OTk5ICAwLjAlIDg3LjUlIDg3LjUlICAwLjAlDQo+IDB4YzAw
NDAxMDANCj4gPiAgMjUwMDAwICAgIDI1MCAgIDYgICAgNyAgICAyICAgMSAgMTAgIDI0OTk5OSAg
MC4wJSA4Ny41JSA4Ny41JSAgMC4wJQ0KPiAweGMwMDkwMTAwDQo+ID4gIDEyNTAwMCAgICA1MDAg
ICA2ICAgIDcgICAgMiAgIDEgIDIwICAxMjQ5OTkgIDAuMCUgODcuNSUgODcuNSUgIDAuMCUNCj4g
MHhjMDEzMDEwMA0KPiA+ICAxMDAwMDAgICAgNjI1ICAgNiAgICA3ICAgIDIgICAxICAyNSAgIDk5
OTk5ICAwLjAlIDg3LjUlIDg3LjUlICAwLjAlDQo+IDB4YzAxODAxMDANCj4gPiAgIDUwMDAwICAg
MTI1MCAgIDYgICAgNyAgICAyICAgMSAgNTAgICA0OTk5OSAgMC4wJSA4Ny41JSA4Ny41JSAgMC4w
JQ0KPiAweGMwMzEwMTAwDQo+ID4gICAyMDAwMCAgIDMxMjUgICA2ICAgIDcgICAgMiAgIDEgMTI1
ICAgMTk5OTkgIDAuMCUgODcuNSUgODcuNSUgIDAuMCUNCj4gMHhjMDdjMDEwMA0KPiA+ICAgMTAw
MDAgICA2MjUwICAgNiAgICA3ICAgIDIgICAxIDI1MCAgICA5OTk5ICAwLjAlIDg3LjUlIDg3LjUl
ICAwLjAlDQo+IDB4YzBmOTAxMDANCj4gDQoNCkkgdGhpbmssIGl0IHNob3VsZCBiZSBjb3JyZWN0
LiBDYW4gSSBoYXZlIHRoZSBwYXRjaCBwbGVhc2UoY2FuLXV0aWxzIG9yIGtlcm5lbCk/IEknbGwg
Z2l2ZSBpdCBhIGdvLg0KDQpNYW51YWwgZS5nLiBzaG93cywgZm9yIDFNYnBzIGFuZCA0ME1IeiBj
bG9jaywgdHdvIHNldHRpbmdzIGFyZSBwb3NzaWJsZQ0KMTBUcSAtPiBCUlAgNA0KMjBUcSAtPiBC
UlAgMg0KDQpDb25kaXRpb24gaXMgVFNFRzEgPiBUU0VHMiA+PSBTSlcgJiBiaXRyYXRlID0gY2xv
Y2sgZnJlcS8oYnJwICogbnVtYmVyIG9mIFRxKQ0KDQpZb3VyIGUuZy4gc2F0aXNmaWVzIHRoZSBj
b25kaXRpb24gYW5kIGhvcGVmdWxseSBpdCBzaG91bGQgYmUgT0suDQoNClRoYW5rcywNClJhbWVz
aA0K
