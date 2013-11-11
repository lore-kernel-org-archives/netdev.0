From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: TCP performance regression
Date: Mon, 11 Nov 2013 15:05:54 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73F9@saturn3.aculab.com>
References: <21120.27501.32323.332316@gargle.gargle.HOWL> <1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com> <21120.29720.673157.151074@gargle.gargle.HOWL> <1384152853.16391.19.camel@edumazet-glaptop2.roam.corp.google.com> <21120.37647.979237.40802@gargle.gargle.HOWL> <1384180069.16391.32.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>, "Dave Taht" <dave.taht@gmail.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Sujith Manoharan" <sujith@msujith.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55032 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753675Ab3KKPJX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Nov 2013 10:09:23 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 10666-07 for <netdev@vger.kernel.org>;
 Mon, 11 Nov 2013 15:09:19 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1384180069.16391.32.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBPbiBNb24sIDIwMTMtMTEtMTEgYXQgMTM6NDkgKzA1MzAsIFN1aml0aCBNYW5vaGFyYW4gd3Jv
dGU6DQo+IA0KPiA+IEkgYW0gbm90IHJlYWxseSBjbGVhciBvbiBob3cgdGhpcyByZWdyZXNzaW9u
IGNhbiBiZSBmaXhlZCBpbiB0aGUgZHJpdmVyDQo+ID4gc2luY2UgdGhlIG1ham9yaXR5IG9mIHRo
ZSB0cmFuc21pc3Npb24vYWdncmVnYXRpb24gbG9naWMgaXMgcHJlc2VudCBpbiB0aGUNCj4gPiBU
WCBjb21wbGV0aW9uIHBhdGguDQo+IA0KPiBXZSBoYXZlIG1hbnkgY2hvaWNlcy4NCj4gDQo+IDEp
IEFkZCBiYWNrIGEgbWluaW11bSBvZiB+MTI4IEsgb2Ygb3V0c3RhbmRpbmcgYnl0ZXMgcGVyIFRD
UCBzZXNzaW9uLA0KPiAgICBzbyB0aGF0IGJ1Z2d5IGRyaXZlcnMgY2FuIHN1c3RhaW4gJ2xpbmUg
cmF0ZScuDQo+IA0KPiAgICBOb3RlIHRoYXQgd2l0aCAxMDAgY29uY3VycmVudCBUQ1Agc3RyZWFt
cywgdG90YWwgYW1vdW50IG9mIGJ5dGVzDQo+ICAgIHF1ZXVlZCBvbiB0aGUgTklDIGlzIDEyIE1C
Lg0KPiAgICBBbmQgcGZpZm9fZmFzdCBxZGlzYyB3aWxsIGRyb3AgcGFja2V0cyBhbnl3YXkuDQo+
IA0KPiAgICBUaGF0cyB3aGF0IHdlIGNhbGwgJ0J1ZmZlckJsb2F0Jw0KPiANCj4gMikgVHJ5IGxv
d2VyIHZhbHVlcyBsaWtlIDY0Sy4gU3RpbGwgYnVmZmVyYmxvYXQuDQo+IA0KPiAzKSBGaXggYnVn
Z3kgZHJpdmVycywgdXNpbmcgYSBwcm9wZXIgbG9naWMsIG9yIHNob3J0ZXIgdGltZXJzIChtdm5l
dGENCj4gY2FzZSBmb3IgZXhhbXBsZSkNCj4gDQo+IDQpIEFkZCBhIG5ldyBuZXRkZXYgYXR0cmli
dXRlLCBzbyB0aGF0IHdlbGwgYmVoYXZpbmcgTklDIGRyaXZlcnMgZG8gbm90DQo+IGhhdmUgdG8g
YXJ0aWZpY2lhbGx5IGZvcmNlIFRDUCBzdGFjayB0byBxdWV1ZSB0b28gbWFueSBieXRlcyBpbg0K
PiBRZGlzYy9OSUMgcXVldWVzLg0KDQpPciwgbWF5YmU6DQo1KSBjYWxsIHNrYl9vcnBoYW4oKSAo
SSB0aGluayB0aGF0IGlzIHRoZSBjb3JyZWN0IGZ1bmN0aW9uKSB3aGVuIHRyYW5zbWl0DQogICBw
YWNrZXRzIGFyZSBnaXZlbiB0byB0aGUgaGFyZHdhcmUuDQogICBJIHRoaW5rIHRoYXQgaWYgdGhl
IG1hYyBkcml2ZXIgc3VwcG9ydHMgQlFMIHRoaXMgY291bGQgYmUgZG9uZSBhcyBzb29uDQogICBh
cyB0aGUgQlFMIHJlc291cmNlIGlzIGFzc2lnbmVkIHRvIHRoZSBwYWNrZXQuDQogICBJIHN1c3Bl
Y3QgdGhpcyBjb3VsZCBiZSBkb25lIHVuY29uZGl0aW9uYWxseS4NCg0KQ2xlYXJseSB0aGUgc2ti
IG1heSBhbHNvIG5lZWQgdG8gYmUgZnJlZWQgdG8gYWxsb3cgcHJvdG9jb2wNCnJldHJhbnNtaXNz
aW9ucyB0byBjb21wbGV0ZSBwcm9wZXJseSAtIGJ1dCB0aGF0IHdvbid0IGJlIHNvIHRpbWluZw0K
Y3JpdGljYWwuDQoNCkkgcmVtZW1iZXIgKGEgbG9uZyB0aW1lIGFnbykgZ2V0dGluZyBhIG1lYXN1
cmFibGUgcGVyZm9ybWFuY2UgaW5jcmVhc2UNCmJ5IGRpc2FibGluZyB0aGUgJ2VuZCBvZiB0cmFu
c21pdCcgaW50ZXJydXB0IGFuZCBvbmx5IGRvaW5nIHR4IHRpZHl1cA0Kd2hlbiB0aGUgZHJpdmVy
IHdhcyBhY3RpdmUgZm9yIG90aGVyIHJlYXNvbnMuDQpUaGVyZSB3ZXJlIDIgcmVhc29ucyBmb3Ig
ZW5hYmxpbmcgdGhlIGludGVycnVwdDoNCjEpIHR4IHJpbmcgZnVsbC4NCjIpIHR4IGJ1ZmZlciBo
YWQgYSB1c2VyLWRlZmluZWQgZGVsZXRlIGZ1bmN0aW9uLg0KDQoJRGF2aWQNCg0K
