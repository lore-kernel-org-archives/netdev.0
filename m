From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [REGRESSION] e1000e stopped working [MANUALLY BISECTED]
Date: Thu, 15 Jul 2010 13:02:28 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FF4B860D9@rrsmsx501.amr.corp.intel.com>
References: <1277659633.2989.2.camel@localhost.localdomain>
	 <1277659785.4028.1.camel@localhost.localdomain>
	 <1277660638.3321.1.camel@localhost.localdomain>
	 <1277660831.3321.3.camel@localhost.localdomain>
	 <8DD2590731AB5D4C9DBF71A877482A90015918F40A@orsmsx509.amr.corp.intel.com>
	 <1277745247.12841.1.camel@localhost.localdomain>
	 <8DD2590731AB5D4C9DBF71A877482A90015918FAB6@orsmsx509.amr.corp.intel.com>
	 <1277807529.19417.2.camel@localhost.localdomain>
	 <EA929A9653AAE14F841771FB1DE5A1365FF4705C9D@rrsmsx501.amr.corp.intel.com>
	 <1277938757.4138.3.camel@localhost.localdomain>
	 <1278204106.21020.0.camel@localhost.localdomain>
	 <1278283714.3444.1.camel@localhost.localdomain>
	 <AANLkTin4sdPeExcNJkq4pfwIq0lcJuXtzTAACRW3JTFh@mail.gmail.com>
	 <1278323885.5277.0.camel@localhost.localdomain>
	 <1278950178.17933.2.camel@localhost.localdomain>
	 <EA929A9653AAE14F841771FB1DE5A1365FF4A9B949@rrsmsx501.amr.corp.intel.com>
	 <1278981483.23017.4.camel@localhost.localdomain>
	 <EA929A9653AAE14F841771FB1DE5A1365FF4B05AF9@rrsmsx501.amr.corp.intel.com>
	 <1279150380.7810.2.camel@localhost.localdomain>
 <1279220266.4411.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34766 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934313Ab0GOTCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jul 2010 15:02:31 -0400
In-Reply-To: <1279220266.4411.2.camel@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TWF4aW0gTGV2aXRza3kgd3JvdGU6DQo+IE9uIFRodSwgMjAxMC0wNy0xNSBhdCAwMjozMyArMDMw
MCwgTWF4aW0gTGV2aXRza3kgd3JvdGU6DQo+PiBPbiBXZWQsIDIwMTAtMDctMTQgYXQgMTY6NTYg
LTA2MDAsIFRhbnRpbG92LCBFbWlsIFMgd3JvdGU6DQo+Pj4gTWF4aW0gTGV2aXRza3kgd3JvdGU6
DQo+Pj4+IE9uIE1vbiwgMjAxMC0wNy0xMiBhdCAxNToyMyAtMDYwMCwgVGFudGlsb3YsIEVtaWwg
UyB3cm90ZToNCj4+Pj4+IE1heGltIExldml0c2t5IHdyb3RlOg0KPj4+Pj4+IE9uIE1vbiwgMjAx
MC0wNy0wNSBhdCAxMjo1OCArMDMwMCwgTWF4aW0gTGV2aXRza3kgd3JvdGU6DQo+Pj4+Pj4+IE9u
IE1vbiwgMjAxMC0wNy0wNSBhdCAwMToxMyAtMDcwMCwgSmVmZiBLaXJzaGVyIHdyb3RlOg0KPj4+
Pj4+Pj4gT24gU3VuLCBKdWwgNCwgMjAxMCBhdCAxNTo0OCwgTWF4aW0gTGV2aXRza3kNCj4+Pj4+
Pj4+IDxtYXhpbWxldml0c2t5QGdtYWlsLmNvbT4gd3JvdGU6DQo+Pj4+Pj4+Pj4gRGlkIGZldyBn
dWVzc2VzLCBhbmQgbm93IEkgc2VlIHRoYXQgcmV2ZXJ0aW5nIHRoZSBiZWxvdw0KPj4+Pj4+Pj4+
IGNvbW1pdCBmaXhlcyB0aGUgcHJvYmxlbS4gDQo+Pj4+Pj4+Pj4gDQo+Pj4+Pj4+Pj4gImUxMDAw
ZTogRml4L2NsZWFudXAgUEhZIHJlc2V0IGNvZGUgZm9yIElDSHgvUENIeCINCj4+Pj4+Pj4+PiBl
OThjYWM0NDdjYzFjYzQxOGRmZjFkNjEwYTVjNzljNGYyYmRlYzdmLg0KPj4+Pj4+Pj4+IA0KPj4+
Pj4+Pj4+IA0KPj4+Pj4+Pj4+IEJlc3QgcmVnYXJkcywNCj4+Pj4+Pj4+PiAgICAgICAgTWF4aW0g
TGV2aXRza3kNCj4+Pj4+Pj4+PiANCj4+Pj4+Pj4+PiAtLQ0KPj4+Pj4+Pj4gDQo+Pj4+Pj4+PiBD
YW4geW91IGdpdmUgdXMgdGlsbCBUdWVzZGF5IHRvIHJlc3BvbmQ/ICBJIGtub3cgdGhhdCB0aGVy
ZSBhcmUNCj4+Pj4+Pj4+IHNvbWUgYWRkaXRpb25hbCBlMTAwMGUgcGF0Y2hlcyBpbiBteSBxdWV1
ZSwgd2hpY2ggbWF5IHJlc29sdmUNCj4+Pj4+Pj4+IHRoZSBpc3N1ZSwgYnV0IHRoaXMgd2Vla2Vu
ZCB0aGUgcG93ZXIgaXMgZG93biB0byBkbyBzb21lDQo+Pj4+Pj4+PiBpbmZyYXN0cnVjdHVyZSB1
cGdyYWRlcyB3aGljaCBwcmV2ZW50cyB1cyBmcm9tIGRvaW5nIGFueQ0KPj4+Pj4+Pj4gaW52ZXN0
aWdhdGlvbi5kZWJ1Z2dpbmcgdW50aWwgVHVlc2RheS4NCj4+Pj4+Pj4+IA0KPj4+Pj4+PiANCj4+
Pj4+Pj4gU3VyZS4NCj4+Pj4+Pj4gDQo+Pj4+Pj4+IEJlc3QgcmVnYXJkcywNCj4+Pj4+Pj4gCU1h
eGltIExldml0c2t5DQo+Pj4+Pj4+IA0KPj4+Pj4+IA0KPj4+Pj4+IFVwZGF0ZXM/DQo+Pj4+PiAN
Cj4+Pj4+IFdlIGFyZSB3b3JraW5nIG9uIHJlcHJvZHVjaW5nIHRoZSBpc3N1ZS4gU28gZmFyIHdl
IGhhdmUgbm90IHNlZW4NCj4+Pj4+IHRoZSBwcm9ibGVtIHdoZW4gdGVzdGluZyB3aXRoIG5ldC1u
ZXh0Lg0KPj4+Pj4gDQo+Pj4+PiBJIGFza2VkIGluIHByZXZpb3VzIGVtYWlsIGFib3V0IHNvbWUg
YWRkaXRpb25hbCBpbmZvIGZyb20gZXRodG9vbA0KPj4+Pj4gKC1kLCAtZSwgLVMpIGFuZCBrZXJu
ZWwgY29uZmlnLiBUaGF0IHdvdWxkIGhlbHAgdXMgdG8gbmFycm93IGl0DQo+Pj4+PiBkb3duLiAN
Cj4+Pj4+IA0KPj4+Pj4gVGhhbmtzLA0KPj4+Pj4gRW1pbA0KPj4+PiBJIGRpZCBzZW5kIC1lIGFu
ZCAtZCBvdXRwdXQuDQo+Pj4gDQo+Pj4gU29ycnksIGxvb2tzIGxpa2UgSSBsb3N0IHRoZSBlbWFp
bCB3aXRoIHRoZSBhdHRhY2hlbWVudHMuDQo+Pj4gDQo+Pj4gQ291bGQgeW91IHByb3ZpZGUgdGhl
IG91dHB1dCBvZiBkbWVzZyBhZnRlciB0aGUgZmFpbHVyZSBvY2N1cnM/DQo+Pj4gDQo+Pj4+IFNp
bmNlIHlvdSBwcm9iYWJseSB3YW50IC1TIG91dHB1dCBkdXJpbmcgZmFpbHVyZSwgSSBuZWVkIHRv
DQo+Pj4+IHJlY29tcGlsZSBrZXJuZWwgZm9yIHRoYXQuIEkgd2lsbCBkbyB0aGF0IHNvb24uDQo+
Pj4+IA0KPj4+PiANCj4+Pj4gT25lIHF1ZXN0aW9uLCBpbiB0d28gd2Vla3MgSSBob3BlIDIuNi4z
NSB3b24ndCBiZSByZWxlYXNlZD8NCj4+Pj4gSWYgc28sIEkgd2lsbCBoYXZlIGVub3VnaCBmcmVl
IHRpbWUgdGhlbiB0byBuYXJyb3cgZG93biB0aGlzIGlzc3VlLg0KPj4+PiANCj4+Pj4gT3RoZXIg
c29sdXRpb24sIGlzIHRvIHJldmVydCB0aGlzIGNvbW1pdC4NCj4+Pj4gKEkgaGF2ZSBuZXZlciBz
ZWVuIHRoaXMgcHJvYmxlbSB3aXRoIGl0IHJldmVydGVkKS4NCj4+PiANCj4+PiBXZSBoYXZlIGJl
ZW4gcnVubmluZyByZWJvb3QgdGVzdHMgb24gMiBzZXBhcmF0ZSBzeXN0ZW1zIHdpdGggcmVjZW50
DQo+Pj4gbmV0LW5leHQga2VybmVscyB1c2luZyB5b3VyIGNvbmZpZyBhbmQgc28gZmFyIG5vIGx1
Y2sgaW4NCj4+PiByZXByb2R1Y2luZyB0aGlzIGlzc3VlLiANCj4+PiANCj4+PiBXaGF0IGlzIHRo
ZSBtYWtlIG1vZGVsIG9mIHlvdXIgc3lzdGVtIChvciBNQik/DQo+PiANCj4+IHRoZSBtb3RoZXJi
b2FyZCBpcyBJbnRlbCBERzk2NVJZLg0KPj4gDQo+PiBIb3dldmVyLCBJIGFtIHVzaW5nIHZhbmls
bGEga2VybmVsLg0KPj4gbmV0LW5leHQgbWlnaHQgY29udGFpbiBmdXJ0aGVyIGZpeGVzLg0KPj4g
DQo+PiBJIHNlZSBpZiBuZXQtbmV4dCB3b3JrcyBoZXJlLg0KPiANCj4gWWVwLCBuZXQtbmV4dCB3
b3JrcyBoZXJlLg0KPiANCj4gDQo+IEkgaGF2ZSB0aGUgcHJvYmxlbSBvbiB2YW5pbGxhIGtlcm5l
bC4NCj4gTGFzdCByZXZpc2lvbiBvZiBpdCwgSSB0ZXN0ZWQgaXMgMi42LjM1LXJjNCBleGFjdGx5
DQo+ICg4MTVjNDE2M2I2YzhlYmY4MTUyZjQyYjBhNWZkMDE1Y2ZkY2VkYzc4KQ0KPiANCj4gDQo+
IE1heWJlIHZhbmlsbGEgZ2l0IG1hc3RlciB3b3JrcywgSSB0ZXN0IGl0IHRvbyBzb29uLg0KDQpU
aGFua3MgZm9yIHRoZSBpbmZvcm1hdGlvbiEgR29vZCB0byBrbm93IHRoYXQgdGhpcyBpc3N1ZSBk
b2VzIG5vdCBleGlzdCBpbiB0aGUgbGF0ZXN0IGJyYW5jaC4NCg0KSGF2ZSB5b3UgYnkgYW55IGNo
YW5jZSB0ZXN0ZWQgYSBzdGFibGUgYnJhbmNoICgyLjYuMzQueCk/DQoNCj4gDQo+IA0KPiBCZXN0
IHJlZ2FyZHMsDQo+IAlNYXhpbSBMZXZpdHNreQ0KDQpUaGFua3MsDQpFbWlsDQo=
