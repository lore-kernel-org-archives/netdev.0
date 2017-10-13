From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Kernel Performance Tuning for High Volume SCTP traffic
Date: Fri, 13 Oct 2017 16:35:38 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD00950DD@AcuExch.aculab.com>
References: <CAFKCRVL-e03Cn35-Vvtb8+NSAz3Tk2Hje_Hg5K9HfqgokEBPgg@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0094F48@AcuExch.aculab.com>
 <CAFKCRVLTA8Vrz-36rxfUtOf8Zc9mSPZteAgdyeETsqSa-XsOcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Traiano Welcome' <traiano@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.186]:50488 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750722AbdJMQfj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 12:35:39 -0400
In-Reply-To: <CAFKCRVLTA8Vrz-36rxfUtOf8Zc9mSPZteAgdyeETsqSa-XsOcQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogVHJhaWFubyBXZWxjb21lDQo+IFNlbnQ6IDEzIE9jdG9iZXIgMjAxNyAxNzowNA0KPiBP
biBGcmksIE9jdCAxMywgMjAxNyBhdCAxMTo1NiBQTSwgRGF2aWQgTGFpZ2h0IDxEYXZpZC5MYWln
aHRAYWN1bGFiLmNvbT4gd3JvdGU6DQo+ID4gRnJvbTogVHJhaWFubyBXZWxjb21lDQo+ID4NCj4g
PiAoY29waWVkIHRvIG5ldGRldikNCj4gPj4gU2VudDogMTMgT2N0b2JlciAyMDE3IDA3OjE2DQo+
ID4+IFRvOiBsaW51eC1zY3RwQHZnZXIua2VybmVsLm9yZw0KPiA+PiBTdWJqZWN0OiBLZXJuZWwg
UGVyZm9ybWFuY2UgVHVuaW5nIGZvciBIaWdoIFZvbHVtZSBTQ1RQIHRyYWZmaWMNCj4gPj4NCj4g
Pj4gSGkgTGlzdA0KPiA+Pg0KPiA+PiBJJ20gcnVubmluZyBhIGxpbnV4IHNlcnZlciBwcm9jZXNz
aW5nIGhpZ2ggdm9sdW1lcyBvZiBTQ1RQIHRyYWZmaWMgYW5kDQo+ID4+IGFtIHNlZWluZyBsYXJn
ZSBudW1iZXJzIG9mIHBhY2tldCBvdmVycnVucyAoaWZjb25maWcgb3V0cHV0KS4NCj4gPg0KPiA+
IEknZCBndWVzcyB0aGF0IG92ZXJydW5zIGluZGljYXRlIHRoYXQgdGhlIGV0aGVybmV0IE1BQyBp
cyBmYWlsaW5nIHRvDQo+ID4gY29weSB0aGUgcmVjZWl2ZSBmcmFtZXMgaW50byBrZXJuZWwgbWVt
b3J5Lg0KPiA+IEl0IGlzIHByb2JhYmx5IHJ1bm5pbmcgb3V0IG9mIHJlY2VpdmUgYnVmZmVycywg
YnV0IG1pZ2h0IGJlDQo+ID4gc3VmZmVyaW5nIGZyb20gYSBsYWNrIG9mIGJ1cyBiYW5kd2lkdGgu
DQo+ID4gTUFDIGRyaXZlcnMgdXN1YWxseSBkaXNjYXJkIHJlY2VpdmUgZnJhbWVzIGlmIHRoZXkg
Y2FuJ3QgZ2V0DQo+ID4gYSByZXBsYWNlbWVudCBidWZmZXIgLSBzbyB5b3Ugc2hvdWxkbid0IHJ1
biBvdXQgb2YgcnggYnVmZmVycy4NCj4gPg0KPiA+IFRoaXMgbWVhbnMgdGhlIGVycm9ycyBhcmUg
cHJvYmFibHkgYmVsb3cgU0NUUCAtIHNvIGNoYW5naW5nIFNDVFAgcGFyYW1ldGVycw0KPiA+IGlz
IHVubGlrZWx5IHRvIGhlbHAuDQo+IA0KPiBEb2VzIHRoaXMgbWVhbiB0aGF0IHR1bmluZyBVRFAg
cGVyZm9ybWFuY2UgY291bGQgaGVscCA/IE9yIGRvIHlvdSBtZWFuDQo+IGhhcmR3YXJlIChOSUMp
IHBlcmZvcm1hbmNlIGNvdWxkIGJlIHRoZSBpc3N1ZT8NCg0KSSdkIGNlcnRhaW5seSBjaGVjayBV
RFAgcGVyZm9ybWFuY2UuDQoNCglEYXZpZA0KDQo=
