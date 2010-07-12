From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [REGRESSION] e1000e stopped working [MANUALLY BISECTED]
Date: Mon, 12 Jul 2010 15:23:10 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FF4A9B949@rrsmsx501.amr.corp.intel.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>
To: Maxim Levitsky <maximlevitsky@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:17522 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754859Ab0GLVXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jul 2010 17:23:46 -0400
In-Reply-To: <1278950178.17933.2.camel@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TWF4aW0gTGV2aXRza3kgd3JvdGU6DQo+IE9uIE1vbiwgMjAxMC0wNy0wNSBhdCAxMjo1OCArMDMw
MCwgTWF4aW0gTGV2aXRza3kgd3JvdGU6DQo+PiBPbiBNb24sIDIwMTAtMDctMDUgYXQgMDE6MTMg
LTA3MDAsIEplZmYgS2lyc2hlciB3cm90ZToNCj4+PiBPbiBTdW4sIEp1bCA0LCAyMDEwIGF0IDE1
OjQ4LCBNYXhpbSBMZXZpdHNreQ0KPj4+IDxtYXhpbWxldml0c2t5QGdtYWlsLmNvbT4gd3JvdGU6
IA0KPj4+PiBEaWQgZmV3IGd1ZXNzZXMsIGFuZCBub3cgSSBzZWUgdGhhdCByZXZlcnRpbmcgdGhl
IGJlbG93IGNvbW1pdA0KPj4+PiBmaXhlcyB0aGUgcHJvYmxlbS4gDQo+Pj4+IA0KPj4+PiAiZTEw
MDBlOiBGaXgvY2xlYW51cCBQSFkgcmVzZXQgY29kZSBmb3IgSUNIeC9QQ0h4Ig0KPj4+PiBlOThj
YWM0NDdjYzFjYzQxOGRmZjFkNjEwYTVjNzljNGYyYmRlYzdmLg0KPj4+PiANCj4+Pj4gDQo+Pj4+
IEJlc3QgcmVnYXJkcywNCj4+Pj4gICAgICAgIE1heGltIExldml0c2t5DQo+Pj4+IA0KPj4+PiAt
LQ0KPj4+IA0KPj4+IENhbiB5b3UgZ2l2ZSB1cyB0aWxsIFR1ZXNkYXkgdG8gcmVzcG9uZD8gIEkg
a25vdyB0aGF0IHRoZXJlIGFyZSBzb21lDQo+Pj4gYWRkaXRpb25hbCBlMTAwMGUgcGF0Y2hlcyBp
biBteSBxdWV1ZSwgd2hpY2ggbWF5IHJlc29sdmUgdGhlIGlzc3VlLA0KPj4+IGJ1dCB0aGlzIHdl
ZWtlbmQgdGhlIHBvd2VyIGlzIGRvd24gdG8gZG8gc29tZSBpbmZyYXN0cnVjdHVyZQ0KPj4+IHVw
Z3JhZGVzIA0KPj4+IHdoaWNoIHByZXZlbnRzIHVzIGZyb20gZG9pbmcgYW55IGludmVzdGlnYXRp
b24uZGVidWdnaW5nIHVudGlsDQo+Pj4gVHVlc2RheS4NCj4+PiANCj4+IA0KPj4gU3VyZS4NCj4+
IA0KPj4gQmVzdCByZWdhcmRzLA0KPj4gCU1heGltIExldml0c2t5DQo+PiANCj4gDQo+IFVwZGF0
ZXM/DQoNCldlIGFyZSB3b3JraW5nIG9uIHJlcHJvZHVjaW5nIHRoZSBpc3N1ZS4gU28gZmFyIHdl
IGhhdmUgbm90IHNlZW4gdGhlIHByb2JsZW0gd2hlbiB0ZXN0aW5nIHdpdGggbmV0LW5leHQuDQoN
CkkgYXNrZWQgaW4gcHJldmlvdXMgZW1haWwgYWJvdXQgc29tZSBhZGRpdGlvbmFsIGluZm8gZnJv
bSBldGh0b29sICgtZCwgLWUsIC1TKSBhbmQga2VybmVsIGNvbmZpZy4gVGhhdCB3b3VsZCBoZWxw
IHVzIHRvIG5hcnJvdyBpdCBkb3duLg0KDQpUaGFua3MsDQpFbWlsDQo=
