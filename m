From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Can I limit the number of active tx per TCP socket?
Date: Fri, 7 Mar 2014 16:39:38 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6D7994@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6D3B91@AcuExch.aculab.com>
	 <5318ADB1.5050107@hp.com>
	 <CADVnQyn1+WRqS9HQmMn9JgpBz0Wajg=40yVhdyqv_AAo4tpWUA@mail.gmail.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6D727E@AcuExch.aculab.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6D755C@AcuExch.aculab.com>
	 <1394202127.20149.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6D7699@AcuExch.aculab.com>
 <1394204402.20149.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: 'Neal Cardwell' <ncardwell@google.com>,
	Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:36961 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751935AbaCGQkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2014 11:40:17 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 27352-06 for <netdev@vger.kernel.org>;
 Fri,  7 Mar 2014 16:40:14 +0000 (GMT)
In-Reply-To: <1394204402.20149.29.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IA0KPiBPbiBGcmksIDIwMTQtMDMtMDcgYXQgMTQ6MzUgKzAwMDAs
IERhdmlkIExhaWdodCB3cm90ZToNCj4gDQo+ID4gT25seSB0aGUgb25lIGNvbm5lY3Rpb24gYmV0
d2VlbiB0aGUgdHdvIElQIGFkZHJlc3NlcyBpcyBjYXJyeWluZyB0aGlzIGRhdGEuDQo+ID4gT3Ro
ZXIgY29ubmVjdGlvbnMgY2Fycnkgb3RoZXIgdHJhZmZpYyB0aGF0IGhhcyBlbnRpcmVseSBkaWZm
ZXJlbnQNCj4gPiBjaGFyYWN0ZXJpc3RpY3MuDQouLi4NCj4gQnkgbGV0dGluZyB0aGUgc3RhY2sg
ZG9pbmcgb3B0aW1hbCBhZ2dyZWdhdGlvbiwgeW91J2xsIGhhdmUgbm8gb3ZlcmhlYWQNCj4gYW4g
cGVyZmVjdCBwYWNpbmcgKHVzaW5nIGhpZ2ggcmVzb2x1dGlvbiB0aW1lcikNCg0KSSBkb24ndCBu
ZWVkICdwZXJmZWN0IHBhY2luZycsIGFuZCBpbmRlZWQgaXQgd291bGRuJ3Qgd29yay4NCkknbSBh
bHNvIGFjdHVhbGx5IHNlbmRpbmcgZnJvbSB3aXRoaW4gdGhlIGtlcm5lbCwgc28gaGlnaCByZXNv
bHV0aW9uDQp0aW1lcnMgYXJlbid0IGEgYmlnIHByb2JsZW0uDQoNClRoZSBjb2RlIGFsc28gaGFz
IGEgKHBlciBzb2NrZXQpIGtlcm5lbCB0aHJlYWQgZGVkaWNhdGVkIHRvIHRoZQ0Kc2VuZHMgKHBh
cnRpYWxseSBiZWNhdXNlIHdlIGRpZG4ndCB3b3JrIG91dCBob3cgdG8gZG8gdGhlIGVxdWl2YWxl
bnQNCm9mIHBvbGwgZnJvbSB3aXRoaW4gdGhlIGtlcm5lbCksIGJ1dCBkb2luZyB0aGUgc29ja2V0
IHNlbmQgKGFuZA0KcmVjZWl2ZSkgZnJvbSBzZXBhcmF0ZSBrZXJuZWwgdGhyZWFkcyBoZWxwcyBz
aGFyZSB0aGUgbG9hZCBiZXR3ZWVuDQpjcHVzIC0gbW9zdCBvZiB0aGUgcmVzdCBvZiB0aGUgcHJv
dG9jb2wgc3RhY2sgcnVucyBhcyBhIHNpbmdsZQ0Ka2VybmVsIHRocmVhZCB0byBzaW1wbGlmeSBs
b2NraW5nLg0KDQpGb3J0dW5hdGVseSBJJ20gZmFpcmx5IHN1cmUgdGhhdCBvdXIgY3VzdG9tZXJz
IGRvbid0IHRyeSB0byB1c2UNCnRoZSBzYW1lIHRyYWZmaWMgcGF0dGVybnMgYXMgSSBkbyBpbiB0
ZXN0aW5nLg0KDQpXZSBkbyBoYXZlIGN1c3RvbWVycyBzZW5kaW5nIHZlcnkgbGFyZ2UgbnVtYmVy
cyBvZiBwYWNrZXRzIHRocm91Z2gNCnNjdHAgKEkgYmVsaWV2ZSAxNTAwMCBkYXRhIGNodW5rcy9z
ZWMpLg0KSSBtaWdodCBoYXZlIHRvIGxvb2sgYXQgdGhhdCBjb2RlIHRvIHNlZSBpZiBhbnl0aGlu
ZyBjYW4gYmUNCmRvbmUgdG8gZ2V0IG11bHRpcGxlIGRhdGEgY2h1bmtzIGludG8gYSBzaW5nbGUg
ZXRoZXJuZXQgcGFja2V0Lg0KU2luY2UgZWFjaCBzZW5kKCkgZ2VuZXJhdGVzIGEgc2VwYXJhdGUg
ZGF0YSBjaHVuayBJIGNhbid0IHVzZSBzZW5kdigpDQp0byBtZXJnZSBmcmFnbWVudHMgKGFzIEkg
ZG8gZm9yIHRjcCkuDQoNCglEYXZpZA0KDQo=
