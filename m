From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] tcp: auto corking
Date: Fri, 6 Dec 2013 16:30:41 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B746C@saturn3.aculab.com>
References: <1386311765.30495.246.camel@edumazet-glaptop2.roam.corp.google.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7467@saturn3.aculab.com> <52A1F603.2030208@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: base64
Cc: "netdev" <netdev@vger.kernel.org>
To: "Rick Jones" <rick.jones2@hp.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:46577 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751287Ab3LFQi3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 11:38:29 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 08841-07 for <netdev@vger.kernel.org>;
 Fri,  6 Dec 2013 16:31:24 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <52A1F603.2030208@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBSaWNrIEpvbmVzDQo+IE9uIDEyLzA2LzIwMTMgMDI6MzAgQU0sIERhdmlkIExhaWdo
dCB3cm90ZToNCj4gPj4gRnJvbTogRXJpYyBEdW1hemV0IDxlZHVtYXpldEBnb29nbGUuY29tPg0K
PiA+Pg0KPiA+PiBXaXRoIHRoZSBpbnRyb2R1Y3Rpb24gb2YgVENQIFNtYWxsIFF1ZXVlcywgVFNP
IGF1dG8gc2l6aW5nLCBhbmQgVENQDQo+ID4+IHBhY2luZywgd2UgY2FuIGltcGxlbWVudCBBdXRv
bWF0aWMgQ29ya2luZyBpbiB0aGUga2VybmVsLCB0byBoZWxwDQo+ID4+IGFwcGxpY2F0aW9ucyBk
b2luZyBzbWFsbCB3cml0ZSgpL3NlbmRtc2coKSB0byBUQ1Agc29ja2V0cy4NCj4gPg0KPiA+IFBy
ZXN1bWFibHkgdGhpcyBoYXMgdGhlIGdyZWF0ZXN0IGVmZmVjdCBvbiBjb25uZWN0aW9ucyB3aXRo
IE5hZ2xlDQo+ID4gZGlzYWJsZWQ/DQo+IA0KPiBJIHdhcyB3b25kZXJpbmcgd2h5IE5hZ2xlIGRp
ZG4ndCBjYXRjaCB0aGVzZSB0aGluZ3MgYXMgd2VsbC4gIFRoZQ0KPiBuZXRwZXJmIGNvbW1hbmQg
bGluZSBFcmljIHByb3ZpZGVkIHRob3VnaCBkaWRuJ3QgaW5jbHVkZSB0aGUNCj4gdGVzdC1zcGVj
aWZpYyAtRCBvcHRpb24gdGhhdCB3b3VsZCBoYXZlIGRpc2FibGVkIE5hZ2xlLiAgQXQgbGVhc3Qg
bm90DQo+IHVubGVzcyB0aGUgInN1cGVyX25ldHBlcmYiIHdyYXBwZXIgd2FzIGFkZGluZyBpdC4N
Cj4gDQo+IFNvLCB3aHkgZG9lc24ndCBOYWdsZSBjYXRjaCB3aGF0IGlzIHByZXN1bWFibHkgYSBz
dWItTVNTIHNlbmQgd2hpbGUNCj4gdGhlcmUgaXMgZGF0YSBvdXRzdGFuZGluZyBvbiB0aGUgY29u
bmVjdGlvbj8NCg0KTmFnbGUgc2hvdWxkIGJsb2NrIHNlbmRzIGFmdGVyIDIgc2hvcnQgc2VuZHMg
KHdhaXRpbmcgZm9yIG1zcyBvciBhY2spLg0KVHJvdWJsZSBpcyBOYWdsZSBpcyBvbmx5IGFueSB1
c2UgZm9yIHNpbmdsZS1kaXJlY3Rpb25hbCB0cmFmZmljDQphbmQgY29tbWFuZC1yZXNwb25zZSB3
aGVyZSBib3RoIG1lc3NhZ2VzIGFyZSBzbWFsbGVyIHRoYW4gdGhlIG1zcy4NCkZvciBldmVyeXRo
aW5nIGVsc2UgTmFnbGUgaXMgYSByaWdodCBQSVRBLg0KDQpPZiBjb3Vyc2UsIGlmIHlvdSBkaXNh
YmxlIE5hZ2xlIHNsb3cgc3RhcnQgYW5kIGRlbGF5ZWQgYWNrcyBjb25zcGlyZQ0KdG9nZXRoZXIg
dG8gc2VyaW91c2x5IHJlZHVjZSB0aHJvdWdocHV0IG9uIHplcm8tZGVsYXkgbG9jYWwgbGlua3Mu
DQooVHJ5IHNlbmRpbmcgNTAgYnl0ZXMgZXZlcnkgbWlsbGlzZWNvbmQgd2l0aCBubyByZXR1cm4g
dHJhZmZpYy4NClNsb3cgc3RhcnQgb25seSBhbGxvd3MgNCBwYWNrZXRzIGJlIHNlbnQgKG5vdCA0
IE1TUykgZXZlbiB3aGVuIGFuDQptc3Mgb2YgZGF0YSBpcyBidWZmZXJlZCwgYnV0IHRoYXQgaXNu
J3QgZW5vdWdoIHRvIGZvcmNlIGFuIGFjayBvdXQNCmJlZm9yZSB0aGUgdGltZXIgZXhwaXJlcy4p
DQoNCglEYXZpZA0KDQo=
