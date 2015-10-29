From: Liberman Igal <Igal.Liberman@freescale.com>
Subject: RE: [V5, 2/6] fsl/fman: Add FMan support
Date: Thu, 29 Oct 2015 16:08:34 +0000
Message-ID: <DM2PR03MB509FB7052B8B0401369F9D5E6200@DM2PR03MB509.namprd03.prod.outlook.com>
References: <1442836354-5445-1-git-send-email-igal.liberman@freescale.com>
	 <20150925230153.GA4626@home.buserror.net>
	 <BL2PR03MB5006080090B6783629A33A5E6220@BL2PR03MB500.namprd03.prod.outlook.com>
	 <1446067854.701.365.camel@freescale.com>
	 <DM2PR03MB509C1B1A5272C9D0A9F8295E6200@DM2PR03MB509.namprd03.prod.outlook.com>
 <1446132279.701.368.camel@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Madalin-Cristian Bucur <madalin.bucur@freescale.com>
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0122.outbound.protection.outlook.com ([65.55.169.122]:42336
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752564AbbJ2QIh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 12:08:37 -0400
In-Reply-To: <1446132279.701.368.camel@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQpSZWdhcmRzLA0KSWdhbCBMaWJlcm1hbg0KDQo+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0t
DQo+IEZyb206IFdvb2QgU2NvdHQtQjA3NDIxDQo+IFNlbnQ6IFRodXJzZGF5LCBPY3RvYmVyIDI5
LCAyMDE1IDU6MjUgUE0NCj4gVG86IExpYmVybWFuIElnYWwtQjMxOTUwIDxJZ2FsLkxpYmVybWFu
QGZyZWVzY2FsZS5jb20+DQo+IENjOiBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyBsaW51eHBwYy1k
ZXZAbGlzdHMub3psYWJzLm9yZzsgbGludXgtDQo+IGtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc7IEJ1
Y3VyIE1hZGFsaW4tQ3Jpc3RpYW4tQjMyNzE2DQo+IDxtYWRhbGluLmJ1Y3VyQGZyZWVzY2FsZS5j
b20+DQo+IFN1YmplY3Q6IFJlOiBbVjUsIDIvNl0gZnNsL2ZtYW46IEFkZCBGTWFuIHN1cHBvcnQN
Cj4gDQo+IE9uIFRodSwgMjAxNS0xMC0yOSBhdCAxMDoyMiAtMDUwMCwgTGliZXJtYW4gSWdhbC1C
MzE5NTAgd3JvdGU6DQo+ID4gUmVnYXJkcywNCj4gPiBJZ2FsIExpYmVybWFuDQo+ID4NCj4gPiA+
IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+ID4gPiBGcm9tOiBXb29kIFNjb3R0LUIwNzQy
MQ0KPiA+ID4gU2VudDogV2VkbmVzZGF5LCBPY3RvYmVyIDI4LCAyMDE1IDExOjMxIFBNDQo+ID4g
PiBUbzogTGliZXJtYW4gSWdhbC1CMzE5NTAgPElnYWwuTGliZXJtYW5AZnJlZXNjYWxlLmNvbT4N
Cj4gPiA+IENjOiBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyBsaW51eHBwYy1kZXZAbGlzdHMub3ps
YWJzLm9yZzsgbGludXgtDQo+ID4gPiBrZXJuZWxAdmdlci5rZXJuZWwub3JnOyBCdWN1ciBNYWRh
bGluLUNyaXN0aWFuLUIzMjcxNg0KPiA+ID4gPG1hZGFsaW4uYnVjdXJAZnJlZXNjYWxlLmNvbT4N
Cj4gPiA+IFN1YmplY3Q6IFJlOiBbVjUsIDIvNl0gZnNsL2ZtYW46IEFkZCBGTWFuIHN1cHBvcnQN
Cj4gPiA+DQo+ID4gPiBPbiBUdWUsIDIwMTUtMTAtMjcgYXQgMTE6MzIgLTA1MDAsIExpYmVybWFu
IElnYWwtQjMxOTUwIHdyb3RlOg0KPiA+ID4NCj4gPiA+ID4gPiA+ICsNCj4gPiA+ID4gPiA+ICtz
dHJ1Y3QgZGV2aWNlICpmbWFuX2dldF9kZXZpY2Uoc3RydWN0IGZtYW4gKmZtYW4pIHsgIHJldHVy
bg0KPiA+ID4gPiA+ID4gK2ZtYW4tPmRldjsgfQ0KPiA+ID4gPiA+DQo+ID4gPiA+ID4gSXMgdGhp
cyByZWFsbHkgbmVjZXNzYXJ5Pw0KPiA+ID4gPiA+DQo+ID4gPiA+DQo+ID4gPiA+IEZtYW4gcG9y
dCBuZWVkcyBmbWFuLT5kZXYsIGZtYW4gc3RydWN0dXJlIGlzIG9wYXF1ZSwgc28geWVzLCBpdCdz
DQo+ID4gPiA+IG5lZWRlZC4NCj4gPiA+DQo+ID4gPiBXaHkgaXMgb3BhY2l0eSBiZWluZyBtYWlu
dGFpbmVkIGZyb20gb25lIHBhcnQgb2YgdGhlIGZtYW4gZHJpdmVyIHRvDQo+ID4gPiBhbm90aGVy
Pw0KPiA+ID4gSXNuJ3QgdGhpcyB0aGUgc29ydCBvZiBleGNlc3NpdmUgbGF5ZXJpbmcgdGhhdCB3
YXMgY29tcGxhaW5lZCBhYm91dD8NCj4gPiA+DQo+ID4gPg0KPiA+DQo+ID4gSXQncyBub3QgcmVh
bGx5IGxheWVyaW5nLg0KPiA+IEZtYW4gUG9ydCB1c2VzIEZtYW4gcmVzb3VyY2VzLCBpdCdzIG5v
dCBjb21wbGV0ZWx5IHN0YW5kYWxvbmUuDQo+IA0KPiBUaGF0J3MgbXkgcG9pbnQgLS0gaWYgaXQn
cyBub3Qgc3RhbmRhbG9uZSwgd2h5IGlzICJzdHJ1Y3QgZm1hbiIgb3BhcXVlIHRvIHRoZQ0KPiBw
b3J0IGNvZGU/DQo+IA0KDQpPSywgSSdsbCBleHBvc2Ugc3RydWN0IGZtYW4uIA0KDQo+IC1TY290
dA0KDQo=
