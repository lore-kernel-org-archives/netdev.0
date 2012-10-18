From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: sock_getsockopt() not exported
Date: Thu, 18 Oct 2012 13:03:55 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7053@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7052@saturn3.aculab.com> <1350552612.26103.1281.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43530 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752359Ab2JRMJL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2012 08:09:11 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22977-06 for <netdev@vger.kernel.org>;
 Thu, 18 Oct 2012 13:09:05 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1350552612.26103.1281.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBPbiBUaHUsIDIwMTItMTAtMTggYXQgMTA6MTEgKzAxMDAsIERhdmlkIExhaWdodCB3cm90ZToN
Cj4gPiBJJ3ZlIG5vdGljZWQgdGhhdCBuZXQvY29yZS9zb2NrLmMgY29udGFpbnMgYW4NCj4gPiAg
ICAgRVhQT1JUX1NZTUJPTChzb2NrX3NldHNvY2tvcHQpDQo+ID4gYnV0IGlzIG1pc3NpbmcgdGhl
IGNvcnJlc3BvbmRpbmcNCj4gPiAgICAgRVhQT1JUX1NZTUJPTChzb2NrX2dldHNvY2tvcHQpDQo+
ID4NCj4gPiBJbi1rZXJuZWwgdXNlcnMgb2Ygc29ja2V0cyBwcm9iYWJseSBtYW5hZ2Ugd2l0aG91
dA0KPiA+IG5lZWRpbmcgdG8gcmVhZCBTT0xfU09DS0VUIG9wdGlvbnMuDQo+ID4gKFRoZXkgZG8g
bmVlZCB0byBzZXQgU09fUkVVU0FERFIgYW5kIFNPX0tFRVBBTElWRS4pDQo+IA0KPiBzb2NrX3Nl
dHNvY2tvcHQoKSBpcyBleHBvcnRlZCBiZWNhdXNlIHN1bnJwYyBuZWVkcyBpdCwgYW5kIHN1bnJw
YyBjYW4gYmUNCj4gYSBtb2R1bGUNCj4gDQo+IHNvY2tfZ2V0c29ja29wdCgpIGlzIG5vdCBleHBv
cnRlZCBiZWNhdXNlIG5vIG1vZHVsZSBuZWVkcyBpdCB5ZXQuDQo+IA0KPiBUaGUgZGF5IG9uZSB1
c2VyIG5lZWRzIGl0LCB3ZSdsbCBhZGQgdGhlIEVYUE9SVF9TWU1CT0woKQ0KDQpUaGUgcHJvYmxl
bSBpcyB0aGF0IGl0IG1pZ2h0IGJlIG5lZWRlZCBieSBhbiAnb3V0IG9mIHRyZWUnIGRyaXZlci4N
CldlIGFscmVhZHkgaGF2ZSB0aGUgZnVuY3Rpb246DQoNCnN0YXRpYyBpbnQNCmRvX2dldHNvY2tv
cHQoc3RydWN0IHNvY2tldCAqc29jaywgaW50IGxldmVsLCBpbnQgbmFtZSwgdm9pZCAqdmFsLCBp
bnQgbGVuKQ0Kew0KICAgIG1tX3NlZ21lbnRfdCBwcmV2ZnMgPSBnZXRfZnMoKTsNCiAgICBpbnQg
cnZhbDsNCg0KICAgIHNldF9mcyhLRVJORUxfRFMpOw0KDQogICAgaWYgKGxldmVsID09IFNPTF9T
T0NLRVQpIHsNCiAgICAgICAgLyogVGhlcmUgaXMgbm8gRVhQT1JUX1NZTUJPTChzb2NrX2dldHNv
Y2tvcHQpIGluIG5ldC9jb3JlL3NvY2suYyAqLw0KICAgICAgICBydmFsID0gLUVJTlZBTDsgLy8g
c29ja19nZXRzb2Nrb3B0KHNvY2ssIGxldmVsLCBuYW1lLCB2YWwsICZsZW4pOw0KICAgIH0gZWxz
ZSB7DQogICAgICAgIHJ2YWwgPSBzb2NrLT5vcHMtPmdldHNvY2tvcHQoc29jaywgbGV2ZWwsIG5h
bWUsIHZhbCwgJmxlbik7DQogICAgfQ0KDQogICAgc2V0X2ZzKHByZXZmcyk7DQogICAgcmV0dXJu
IHJ2YWw7DQp9DQoNCldlIG5lZWQgdG8gZ2V0IG9wdGlvbnMgKGZvciBTQ1RQKSBmb3J0dW5hdGVs
eSB0aGV5IGFyZW4ndA0KU09MX1NPQ0tFVCBvbmVzLg0KDQoJRGF2aWQNCg0K
