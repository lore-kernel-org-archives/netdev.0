From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [REGRESSION] e1000e stopped working [MANUALLY BISECTED]
Date: Wed, 14 Jul 2010 16:56:35 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FF4B05AF9@rrsmsx501.amr.corp.intel.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11628 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753827Ab0GNW4i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jul 2010 18:56:38 -0400
In-Reply-To: <1278981483.23017.4.camel@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TWF4aW0gTGV2aXRza3kgd3JvdGU6DQo+IE9uIE1vbiwgMjAxMC0wNy0xMiBhdCAxNToyMyAtMDYw
MCwgVGFudGlsb3YsIEVtaWwgUyB3cm90ZToNCj4+IE1heGltIExldml0c2t5IHdyb3RlOg0KPj4+
IE9uIE1vbiwgMjAxMC0wNy0wNSBhdCAxMjo1OCArMDMwMCwgTWF4aW0gTGV2aXRza3kgd3JvdGU6
DQo+Pj4+IE9uIE1vbiwgMjAxMC0wNy0wNSBhdCAwMToxMyAtMDcwMCwgSmVmZiBLaXJzaGVyIHdy
b3RlOg0KPj4+Pj4gT24gU3VuLCBKdWwgNCwgMjAxMCBhdCAxNTo0OCwgTWF4aW0gTGV2aXRza3kN
Cj4+Pj4+IDxtYXhpbWxldml0c2t5QGdtYWlsLmNvbT4gd3JvdGU6DQo+Pj4+Pj4gRGlkIGZldyBn
dWVzc2VzLCBhbmQgbm93IEkgc2VlIHRoYXQgcmV2ZXJ0aW5nIHRoZSBiZWxvdyBjb21taXQNCj4+
Pj4+PiBmaXhlcyB0aGUgcHJvYmxlbS4gDQo+Pj4+Pj4gDQo+Pj4+Pj4gImUxMDAwZTogRml4L2Ns
ZWFudXAgUEhZIHJlc2V0IGNvZGUgZm9yIElDSHgvUENIeCINCj4+Pj4+PiBlOThjYWM0NDdjYzFj
YzQxOGRmZjFkNjEwYTVjNzljNGYyYmRlYzdmLg0KPj4+Pj4+IA0KPj4+Pj4+IA0KPj4+Pj4+IEJl
c3QgcmVnYXJkcywNCj4+Pj4+PiAgICAgICAgTWF4aW0gTGV2aXRza3kNCj4+Pj4+PiANCj4+Pj4+
PiAtLQ0KPj4+Pj4gDQo+Pj4+PiBDYW4geW91IGdpdmUgdXMgdGlsbCBUdWVzZGF5IHRvIHJlc3Bv
bmQ/ICBJIGtub3cgdGhhdCB0aGVyZSBhcmUNCj4+Pj4+IHNvbWUgYWRkaXRpb25hbCBlMTAwMGUg
cGF0Y2hlcyBpbiBteSBxdWV1ZSwgd2hpY2ggbWF5IHJlc29sdmUgdGhlDQo+Pj4+PiBpc3N1ZSwg
YnV0IHRoaXMgd2Vla2VuZCB0aGUgcG93ZXIgaXMgZG93biB0byBkbyBzb21lDQo+Pj4+PiBpbmZy
YXN0cnVjdHVyZSB1cGdyYWRlcyB3aGljaCBwcmV2ZW50cyB1cyBmcm9tIGRvaW5nIGFueQ0KPj4+
Pj4gaW52ZXN0aWdhdGlvbi5kZWJ1Z2dpbmcgdW50aWwgVHVlc2RheS4gDQo+Pj4+PiANCj4+Pj4g
DQo+Pj4+IFN1cmUuDQo+Pj4+IA0KPj4+PiBCZXN0IHJlZ2FyZHMsDQo+Pj4+IAlNYXhpbSBMZXZp
dHNreQ0KPj4+PiANCj4+PiANCj4+PiBVcGRhdGVzPw0KPj4gDQo+PiBXZSBhcmUgd29ya2luZyBv
biByZXByb2R1Y2luZyB0aGUgaXNzdWUuIFNvIGZhciB3ZSBoYXZlIG5vdCBzZWVuIHRoZQ0KPj4g
cHJvYmxlbSB3aGVuIHRlc3Rpbmcgd2l0aCBuZXQtbmV4dC4gDQo+PiANCj4+IEkgYXNrZWQgaW4g
cHJldmlvdXMgZW1haWwgYWJvdXQgc29tZSBhZGRpdGlvbmFsIGluZm8gZnJvbSBldGh0b29sDQo+
PiAoLWQsIC1lLCAtUykgYW5kIGtlcm5lbCBjb25maWcuIFRoYXQgd291bGQgaGVscCB1cyB0byBu
YXJyb3cgaXQNCj4+IGRvd24uICANCj4+IA0KPj4gVGhhbmtzLA0KPj4gRW1pbA0KPiBJIGRpZCBz
ZW5kIC1lIGFuZCAtZCBvdXRwdXQuDQoNClNvcnJ5LCBsb29rcyBsaWtlIEkgbG9zdCB0aGUgZW1h
aWwgd2l0aCB0aGUgYXR0YWNoZW1lbnRzLiANCg0KQ291bGQgeW91IHByb3ZpZGUgdGhlIG91dHB1
dCBvZiBkbWVzZyBhZnRlciB0aGUgZmFpbHVyZSBvY2N1cnM/DQogDQo+IFNpbmNlIHlvdSBwcm9i
YWJseSB3YW50IC1TIG91dHB1dCBkdXJpbmcgZmFpbHVyZSwgSSBuZWVkIHRvIHJlY29tcGlsZQ0K
PiBrZXJuZWwgZm9yIHRoYXQuIEkgd2lsbCBkbyB0aGF0IHNvb24uDQo+IA0KPiANCj4gT25lIHF1
ZXN0aW9uLCBpbiB0d28gd2Vla3MgSSBob3BlIDIuNi4zNSB3b24ndCBiZSByZWxlYXNlZD8NCj4g
SWYgc28sIEkgd2lsbCBoYXZlIGVub3VnaCBmcmVlIHRpbWUgdGhlbiB0byBuYXJyb3cgZG93biB0
aGlzIGlzc3VlLg0KPiANCj4gT3RoZXIgc29sdXRpb24sIGlzIHRvIHJldmVydCB0aGlzIGNvbW1p
dC4NCj4gKEkgaGF2ZSBuZXZlciBzZWVuIHRoaXMgcHJvYmxlbSB3aXRoIGl0IHJldmVydGVkKS4N
Cg0KV2UgaGF2ZSBiZWVuIHJ1bm5pbmcgcmVib290IHRlc3RzIG9uIDIgc2VwYXJhdGUgc3lzdGVt
cyB3aXRoIHJlY2VudCBuZXQtbmV4dCBrZXJuZWxzIA0KdXNpbmcgeW91ciBjb25maWcgYW5kIHNv
IGZhciBubyBsdWNrIGluIHJlcHJvZHVjaW5nIHRoaXMgaXNzdWUuIA0KDQpXaGF0IGlzIHRoZSBt
YWtlIG1vZGVsIG9mIHlvdXIgc3lzdGVtIChvciBNQik/DQoNClRoYW5rcywNCkVtaWwNCg==
