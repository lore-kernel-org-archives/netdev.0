From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: unix: non blocking recvmsg() should not return
 -EINTR
Date: Wed, 26 Mar 2014 15:00:27 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6E9790@AcuExch.aculab.com>
References: <1395798147.12610.196.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev <netdev@vger.kernel.org>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:46204 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754907AbaCZPBN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 11:01:13 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 06649-10 for <netdev@vger.kernel.org>;
 Wed, 26 Mar 2014 15:01:10 +0000 (GMT)
In-Reply-To: <1395798147.12610.196.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IEZyb206IEVyaWMgRHVtYXpldCA8ZWR1bWF6ZXRAZ29vZ2xl
LmNvbT4NCj4gDQo+IFNvbWUgYXBwbGljYXRpb25zIGRpZG4ndCBleHBlY3QgcmVjdm1zZygpIG9u
IGEgbm9uIGJsb2NraW5nIHNvY2tldA0KPiBjb3VsZCByZXR1cm4gLUVJTlRSLiBUaGlzIHBvc3Np
YmlsaXR5IHdhcyBhZGRlZCBhcyBhIHNpZGUgZWZmZWN0DQo+IG9mIGNvbW1pdCBiM2NhOWIwMmIw
MDcwNCAoIm5ldDogZml4IG11bHRpdGhyZWFkZWQgc2lnbmFsIGhhbmRsaW5nIGluDQo+IHVuaXgg
cmVjdiByb3V0aW5lcyIpLg0KPiANCj4gVG8gaGl0IHRoaXMgYnVnLCB5b3UgbmVlZCB0byBiZSBh
IGJpdCB1bmx1Y2t5LCBhcyB0aGUgdS0+cmVhZGxvY2sNCj4gbXV0ZXggaXMgdXN1YWxseSBoZWxk
IGZvciB2ZXJ5IHNtYWxsIHBlcmlvZHMuDQoNClRoZSBjb21taXQgbWVzc2FnZSBmb3IgYjNjYTli
MDJiMDA3MDQgbG9va3MgdmVyeSBzdHJhbmdlLg0KTWF5YmUgc29tZXRoaW5nIGVsc2UgaXMgd3Jv
bmcuDQoNCklmIHdlIGFzc3VtZSB0aGF0IHUtPnJlYWRsb2NrIGlzIG9ubHkgaGVsZCBmb3IgYSBz
aG9ydCBwZXJpb2QNCndoeSBzaG91bGQgaXQgbWF0dGVyIHRoYW4gdGhlIGtlcm5lbCBkZWNpZGVk
IHRvIGdpdmUgdGhlDQpzaWduYWwgdG8gdGhhdCB0aHJlYWQ/DQoNClRoZXJlIGlzIHRoZSBoaW50
IHRoYXQgaWYgdGhlcmUgYXJlIG11bHRpcGxlIHJlYWRlcnMsIGFsbA0KYnV0IG9uZSBhcmUgYmxv
Y2tlZCB3YWl0aW5nIGZvciB1LT5yZWFkbG9jay4NCkJ1dCBJIHNob3VsZCBiZSBhYmxlIHRvIGhh
dmUgb24gdGhyZWFkL3Byb2Nlc3MgZG9pbmcNCmEgYmxvY2tpbmcgcmVhZCBhbmQgYSBzZWNvbmQg
ZG9pbmcgYSBub24tYmxvY2tpbmcgcmVhZA0KKHRocm91Z2ggYSBkaWZmZXJlbnQgZmQpLg0KDQpJ
ZiB3ZSBhc3N1bWUgdGhhdCBhbGwgcmVhZGVycyBhcmUgZWl0aGVyIGJsb2NraW5nIG9yIG5vbi1i
bG9ja2luZw0KdGhlbiBtYXliZSB1LT5yZWFkbG9jayBzaG91bGQgYmUgYWNxdWlyZWQgbm9uLWlu
dGVycnVwdGlibHkNCmluIHRoZSBub24tYmxvY2sgY2FzZS4NCg0KVGhlbiB5b3UgZG9uJ3QgaGF2
ZSB0byB3b3JyeSBhYm91dCB0aGUgcmV0dXJuIGNvZGUuDQoNCglEYXZpZA0KDQo=
