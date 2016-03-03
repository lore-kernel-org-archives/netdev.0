From: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Subject: RE: [PATCH] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Thu, 3 Mar 2016 13:48:14 +0000
Message-ID: <SG2PR06MB1038ABE33F06BCCA9EB072B7C3BD0@SG2PR06MB1038.apcprd06.prod.outlook.com>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <56D5FE8E.1090400@pengutronix.de>
 <SG2PR06MB1038AC389CDB35916408A5D6C3BC0@SG2PR06MB1038.apcprd06.prod.outlook.com>
 <56D6B067.306@pengutronix.de>
 <SG2PR06MB1038DD32D284801452BA633EC3BC0@SG2PR06MB1038.apcprd06.prod.outlook.com>
 <56D6BEAC.10408@pengutronix.de>
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
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"corbet@lwn.net" <corbet@lwn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor3.renesas.com ([210.160.252.173]:22336 "EHLO
	relmlie2.idc.renesas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932254AbcCCNsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 08:48:21 -0500
In-Reply-To: <56D6BEAC.10408@pengutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGkgTWFyYywNCg0KU29ycnkgZm9yIHRoZSBsYXRlIHJlc3BvbnNlLg0KDQo+IE9uIDAzLzAyLzIw
MTYgMTE6MDggQU0sIFJhbWVzaCBTaGFubXVnYXN1bmRhcmFtIHdyb3RlOg0KPiA+Pj4+IEkgc2Vl
IG5vIGxvY2tpbmcgZm9yIHRoZSB0eC1wYXRoLg0KPiA+Pj4NCj4gPj4+IEkgYW0gbm90IHN1cmUg
d2h5IGxvY2tpbmcgaXMgbmVlZGVkIGluIHR4LXBhdGg/DQo+ID4+DQo+ID4+IElmIHRoZSB0eC1w
YXRoIGlzIHNoYXJlZCBiZXR3ZWVuIGJvdGggY2hhbm5lbHMgeW91IG5lZWQgbG9ja2luZyBhcw0K
PiA+PiB0aGUgbmV0d29ya2luZyBzdWJzeXN0ZW0gbWF5IHNlbmQgb25lIGZyYW1lIHRvIGVhY2gg
Y29udHJvbGxlciBhdCB0aGUNCj4gPj4gc2FtZSB0aW1lLg0KPiA+DQo+ID4gWWVzLiBUeCBjb21w
bGV0aW9uIGludGVycnVwdCBpcyBzaGFyZWQgYnkgYm90aCBjaGFubmVscyBidXQgdGhlIFR4DQo+
ID4gRklGTywgZWNobyBza2JzLCBoZWFkLCB0YWlsIGFyZSBtYWludGFpbmVkIG9uIGEgcGVyIGNo
YW5uZWwgYmFzaXMuDQo+ID4gWWVzLCBuZXQgc3Vic3lzdGVtIGNhbiBzZW5kIG9uZSBmcmFtZSB0
byBlYWNoIGNoYW5uZWwgYXQgdGhlIHNhbWUgdGltZQ0KPiA+IGFuZCB0aGUgdHggY29tcGxldGlv
biBpbnRlcnJ1cHQgaGFuZGxlciB3aWxsIHRyYXZlcnNlIGVhY2ggY2hhbm5lbCAmDQo+ID4gdXBk
YXRlIHBlciBjaGFubmVsIGNvbnRleHQgYWNjb3JkaW5nbHkuDQo+IA0KPiBPay4gV2hpY2ggaW5z
dHJ1Y3Rpb24gc3RhcnRzIHRoZSB0cmFuc21pdD8gUGxlYXNlIGFkZCBhIGNvbW1lbnQgdG8gdGhl
DQo+IGNvZGUuDQoNClBsZWFzZSBzZWUNCg0KLS0tPHNuaXA+LS0tDQoNCisJLyogU3RhcnQgVHg6
IFdyaXRlIDB4ZmYgdG8gQ0ZQQyB0byBpbmNyZW1lbnQgdGhlIENQVS1zaWRlDQorCSAqIHBvaW50
ZXIgZm9yIHRoZSBDb21tb24gRklGTw0KKwkgKi8NCisJcmNhcl9jYW5mZF93cml0ZShwcml2LCBS
Q0FORkRfQ0ZQQ1RSKGNoLCBSQ0FORkRfQ0ZGSUZPX0lEWCksIDB4ZmYpOw0KDQotLS08c25pcD4t
LS0NCg0KPiBZb3Ugc3RvcCB0aGUgdHhfcXVldWUgYWZ0ZXIgdGhpcywgc28geW91ciBjb2RlIGlz
IHJhY3ksIGFzIHRoZQ0KPiBpbnRlcnJ1cHQgbWlnaHQgaGFwcGVuIGluIGJldHdlZW4uDQoNCkl0
IGlzIGEgdmVyeSBnb29kIHBvaW50LiBUaGFuayB5b3UuIA0KSSBtYW5hZ2VkIHRvIHJlcHJvZHVj
ZSB0aGlzIGlzc3VlIG9uY2Ugd2l0aCA1MEticHMgcmF0ZSBhbmQgaWdub3JpbmcgLUVOT0JVRlMg
aW4gdXNlciBzcGFjZS4gSXQgYWxzbyBleHBvc2VkIGFub3RoZXIgc3VidGxlIGlzc3VlIGluIHRo
ZSBlY2hvIHNrYiBtYW5hZ2VtZW50IHdoZXJlIHRoZSB0eF9kb25lIGxvb3AgcHVzaGVzIHRoZSBz
a2IgYmVmb3JlIHRoZSBhY3R1YWwgQUNLIGZvciB0aGF0IGluZGV4IGhhcHBlbnMuIEZpeGVkIGJv
dGggaXNzdWVzLg0KQXMgeW91IG1lbnRpb25lZCwgSSBoYXZlIGludHJvZHVjZWQgYSBsb2NrIHRv
IHByb3RlY3QgdGhpcyBjcml0aWNhbCBzZWN0aW9uLiBJJ2xsIHNlbmQgdGhlIHVwZGF0ZXMgaW4g
dGhlIG5leHQgdjIgcGF0Y2guDQoNClRoYW5rcywNClJhbWVzaA0K
