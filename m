From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: RE: kernel BUG at include/net/netns/generic.h:41
Date: Thu, 26 Apr 2012 12:02:17 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91A34FB@SACEXCMBX04-PRD.hq.netapp.com>
References: <20120328002346.GB3077@redhat.com>
 <20120402172600.GA3728@redhat.com>
 <1333390230.13718.34.camel@lade.trondhjem.org>
 <4F7DC37F.7090404@parallels.com> <20120405161241.GA23658@redhat.com>
 <4F7DC4CC.9080502@parallels.com> <20120425225855.GA5537@redhat.com>
 <4F98EA72.6010300@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: Stanislav Kinsbursky <skinsbursky@parallels.com>,
	Dave Jones <davej@redhat.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62043 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752111Ab2DZMC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2012 08:02:29 -0400
In-Reply-To: <4F98EA72.6010300@parallels.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBTdGFuaXNsYXYgS2luc2J1cnNr
eSBbbWFpbHRvOnNraW5zYnVyc2t5QHBhcmFsbGVscy5jb21dDQo+IFNlbnQ6IFRodXJzZGF5LCBB
cHJpbCAyNiwgMjAxMiAyOjI2IEFNDQo+IFRvOiBEYXZlIEpvbmVzOyBNeWtsZWJ1c3QsIFRyb25k
OyBMaW51eCBLZXJuZWw7IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmcNCj4gU3ViamVjdDogUmU6IGtl
cm5lbCBCVUcgYXQgaW5jbHVkZS9uZXQvbmV0bnMvZ2VuZXJpYy5oOjQxDQo+IA0KPiAyNi4wNC4y
MDEyIDAyOjU4LCBEYXZlIEpvbmVzINC90LDQv9C40YHQsNC7Og0KPiA+IE9uIFRodSwgQXByIDA1
LCAyMDEyIGF0IDA4OjE0OjA0UE0gKzA0MDAsIFN0YW5pc2xhdiBLaW5zYnVyc2t5IHdyb3RlOg0K
PiA+ICAgPiAgMDUuMDQuMjAxMiAyMDoxMiwgRGF2ZSBKb25lcyDQv9C40YjQtdGCOg0KPiA+ICAg
PiAgPiAgT24gVGh1LCBBcHIgMDUsIDIwMTIgYXQgMDg6MDg6MzFQTSArMDQwMCwgU3RhbmlzbGF2
IEtpbnNidXJza3kNCj4gd3JvdGU6DQo+ID4gICA+ICA+DQo+ID4gICA+ICA+ICAgID4gICBTbywg
dGhlcmUgYXJlIGZldyBxdWVzdGlvbnMgdG8geW91LCBEYXZlOg0KPiA+ICAgPiAgPiAgICA+ICAg
MSkgY2FuIHRoaXMgaGFwcGVuIChQaXBlRlMgbW91bnQgYXR0ZW1wdCBiZWZvcmUgU1VOUFJDDQo+
IG1vZHVsZSBpbnNlcnRpb24gaGFzDQo+ID4gICA+ICA+ICAgID4gICByZXR1cm5lZCBhbnkgdmFs
dWUpIGluIHlvdXIgY2FzZT8NCj4gPiAgID4gID4NCj4gPiAgID4gID4gIEkgZG9uJ3Qga25vdyBl
bm91Z2ggb2Ygd2hhdCBzeXN0ZW1kIGlzIGRvaW5nIHRvIGFuc3dlciB0aGlzLg0KPiA+ICAgPiAg
Pg0KPiA+ICAgPiAgPiAgICA+ICAgMikgaG93IG9mdGVuIGRvIHlvdSBleHBlcmllbmNlIHRoaXMg
cHJvYmxlbT8gTm90IGV2ZXJ5IGJvb3QsIEkNCj4gc3VwcG9zZT8NCj4gPiAgID4gID4gICAgPiAg
IDMpIEFuZCBpcyBpdCBlYXN5IGZvciB5b3UgdG8gcmVwcm9kdWNlPw0KPiA+ICAgPiAgPg0KPiA+
ICAgPiAgPiAgSXQgaGFwcGVucyBtb3N0IHRoZSB0aW1lLCBidXQgbm90IGV2ZXJ5IHRpbWUuDQo+
ID4gICA+ICA+DQo+ID4gICA+DQo+ID4gICA+ICBPaywgSSdsbCBzZW5kIHRoZSBwYXRjaCBzb29u
Lg0KPiA+ICAgPiAgSG9wZSwgaXQgd2lsbCBoZWxwLg0KPiA+ICAgPg0KPiA+ICAgPiAgLS0NCj4g
PiAgID4gIEJlc3QgcmVnYXJkcywNCj4gPiAgID4gIFN0YW5pc2xhdiBLaW5zYnVyc2t5DQo+ID4N
Cj4gPiBJIGRpZG4ndCBzZWUgYSBmb2xsb3ctdXAgcGF0Y2ggb24gdGhpcywgYW5kIEknbSBzdGls
bCBzZWVpbmcgdGhlIEJVRyBpbiByYzQuDQo+ID4NCj4gPiAJRGF2ZQ0KPiANCj4gRGF2ZSwgc2Vh
cmNoIGZvciAiU1VOUlBDOiByZWdpc3RlciBQaXBlRlMgZmlsZSBzeXN0ZW0gYWZ0ZXIgcGVybmV0
DQo+IHN5YnN5c3RlbSIgaW4geW91ciBtYWlsLg0KPiBZb3UgYXJlIGluIENDIGxpc3QuDQoNCkxp
bnVzIG1lcmdlZCBpdCBsYXN0IG5pZ2h0IHRvZ2V0aGVyIHdpdGggdGhlIG90aGVyIE5GUy1yZWxh
dGVkIGJ1Z2ZpeGVzLi4uDQoNCkNoZWVycw0KICBUcm9uZA0K
