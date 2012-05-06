From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: RE: [PATCH net-next 1/3] Add capability to retrieve plug-in
 module EEPROM
Date: Sun, 6 May 2012 08:02:15 +0000
Message-ID: <A6AA2EF896BED345B0F23520D832A4B106AD8E@SJEXCHMB05.corp.ad.broadcom.com>
References: <4F9031BF.10106@solarflare.com>
 <20120423.172848.1733968863825393980.davem@davemloft.net>
 <1335289485.17274.46.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bruce.w.allan@intel.com" <bruce.w.allan@intel.com>,
	"decot@google.com" <decot@google.com>,
	"alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
To: "Ben Hutchings" <bhutchings@solarflare.com>,
	"smhodgson@solarflare.com" <smhodgson@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2073 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752214Ab2EFICq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 May 2012 04:02:46 -0400
In-Reply-To: <1335289485.17274.46.camel@bwh-desktop.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBPbiBNb24sIDIwMTItMDQtMjMgYXQgMTc6MjggLTA0MDAsIERhdmlkIE1pbGxlciB3cm90ZToN
Cj4gPiBZb3UgY2FuJ3QganVzdCBzdWJtaXQgdGhyZWUgc2VwZXJhdGUgcGF0Y2hlcyBlYWNoIHdp
dGggdGhlIHNhbWUgZXhhY3QNCj4gPiBTdWJqZWN0IGxpbmUuDQo+ID4NCj4gPiBPdGhlcndpc2Ug
c29tZW9uZSBzY2FubmluZyB0aGUgY29tbWl0IGhlYWRlcnMgY2FuJ3QgZmlndXJlIG91dCB3aGF0
DQo+ID4gaXMgZGlmZmVyZW50IGluIGVhY2ggb2YgdGhlc2UgY2hhbmdlcy4NCj4gPg0KPiA+IFRo
ZXJlIGFsc28gaXMgbm8gc2lnbm9mZiBmcm9tIEJlbiBmb3IgcGF0Y2hlcyAjMiBvciAjMywgZGlk
IGhlIHJldmlldw0KPiA+IHRoZW0/ICBJZiBzbywgd2h5IGRpZG4ndCBoZSBBQ0sgb3Igc2lnbiBv
ZmYgb24gaXQ/ICBJZiBub3QsIHdoeSBub3Q/DQo+IA0KPiBTb3JyeSwgSSd2ZSBiZWVuIGJ1c3kg
d2l0aCBhbm90aGVyIHByb2plY3QuICBJJ2xsIHJlcGx5IHRvIFN0dWFydCdzDQo+IHBhdGNoZXMg
ZmFzdGVyIG5leHQgcm91bmQuDQo+IA0KPiBCZW4uDQoNCkhpIFN0dWFydCwNCkl0J3MgYmVlbiAz
IHdlZWtzIHNpbmNlIHlvdSBzZW50IHRoZSBpbml0aWFsIHBhdGNoIHNlcmllcyB3aGljaCB3ZXJl
IG5vdA0KYWNjZXB0ZWQuIFBsZWFzZSByZXBseSBpZiB5b3UncmUgZ29pbmcgdG8gcmVzdWJtaXQg
Zml4ZWQgcGF0Y2hlcyBzb29uLA0Kb3RoZXJ3aXNlIEknbGwgdGFrZSBvdmVyLCBhbmQgY29tcGxl
dGUgdGhpcyB0YXNrIGZyb20gd2hlcmUgeW91IGxlZnQgaXQuDQoNClRoYW5rcyBtdWNoLA0KWWFu
aXYNCg0KPiANCj4gLS0NCj4gQmVuIEh1dGNoaW5ncywgU3RhZmYgRW5naW5lZXIsIFNvbGFyZmxh
cmUNCj4gTm90IHNwZWFraW5nIGZvciBteSBlbXBsb3llcjsgdGhhdCdzIHRoZSBtYXJrZXRpbmcg
ZGVwYXJ0bWVudCdzIGpvYi4NCj4gVGhleSBhc2tlZCB1cyB0byBub3RlIHRoYXQgU29sYXJmbGFy
ZSBwcm9kdWN0IG5hbWVzIGFyZSB0cmFkZW1hcmtlZC4NCj4gDQo+IC0tDQo+IFRvIHVuc3Vic2Ny
aWJlIGZyb20gdGhpcyBsaXN0OiBzZW5kIHRoZSBsaW5lICJ1bnN1YnNjcmliZSBuZXRkZXYiIGlu
DQo+IHRoZSBib2R5IG9mIGEgbWVzc2FnZSB0byBtYWpvcmRvbW9Admdlci5rZXJuZWwub3JnDQo+
IE1vcmUgbWFqb3Jkb21vIGluZm8gYXQgIGh0dHA6Ly92Z2VyLmtlcm5lbC5vcmcvbWFqb3Jkb21v
LWluZm8uaHRtbA0KDQo=
