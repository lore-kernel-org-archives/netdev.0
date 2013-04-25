From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [net-next PATCH 0/4] net: frag patchset for fixing LRU scalabilityissue
Date: Thu, 25 Apr 2013 13:57:28 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B71FE@saturn3.aculab.com>
References: <20130424154624.16883.40974.stgit@dragon> <AE90C24D6B3A694183C094C60CF0A2F6026B71F9@saturn3.aculab.com> <1366889995.26911.555.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>,
	"Hannes Frederic Sowa" <hannes@stressinduktion.org>,
	<netdev@vger.kernel.org>, "Eric Dumazet" <eric.dumazet@gmail.com>
To: "Jesper Dangaard Brouer" <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:37294 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755422Ab3DYM6l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 08:58:41 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 09004-03 for <netdev@vger.kernel.org>;
 Thu, 25 Apr 2013 13:58:38 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1366889995.26911.555.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBPbiBXZWQsIDIwMTMtMDQtMjQgYXQgMTc6MjEgKzAxMDAsIERhdmlkIExhaWdodCB3cm90ZToN
Cj4gPiA+IEkgaGF2ZSBkcm9wcGVkIHRoZSBpZGVhIG9mIGRvaW5nICJkaXJlY3QgaGFzaCBjbGVh
bmluZyIuICBJbnN0ZWFkIEkNCj4gPiA+IGhhdmUgc2ltcGx5IGNob29zZW4gdG8gc29sdmUgdGhl
IGdsb2JhbCBMUlUgbGlzdCBwcm9ibGVtLCBieSBtYWtpbmcNCj4gPiA+IHRoZSBMUlUgbGlzdCBi
ZSBwZXIgQ1BVLg0KPiA+DQo+ID4gSG93IGNhbiBhIHBlci1jcHUgTFJVIGxpc3Qgd29yaz8NCj4g
PiBJIHNlZSB0d28gaW1tZWRpYXRlIHByb2JsZW1zOg0KPiA+IC0gRW5zdXJpbmcgdGhlIG5vcm1h
bCAnYWxsb2NhdGUnIGFuZCAnZnJlZScgYXJlIGFsd2F5cyBkb25lDQo+ID4gICBvbiB0aGUgc2Ft
ZSBjcHUgKGZyZWUgd2lsbCBuZWVkIHRvIHJlbW92ZSBpdGVtcyBmcm9tIGFueQ0KPiA+ICAgTFJV
IGxpc3QpLg0KPiA+IC0gRW5zdXJpbmcgdGhhdCB0aGVyZSBhbGwgdGhlIGl0ZW1zIGFyZW4ndCBv
biB0aGUgTFJVIGxpc3RzDQo+ID4gICBvZiBvdGhlciBjcHVzIC0gbWVhbmluZyBvbmUgY2FuJ3Qg
YmUgYWxsb2NhdGVkLg0KPiA+DQo+ID4gVGhlIG9ubHkgd2F5IHRoaXMgY291bGQgd29yayBpcyBp
ZiB0aGUgYWxsb2NhdGlvbiBsaW1pdA0KPiA+IGlzIGFsc28gcGVyLWNwdSBhbmQgeW91IGNhbiBn
dWFyYW50ZWUgdGhhdCB0aGUgYWxsb2MgYW5kDQo+ID4gZnJlZSBmb3IgYW55IGdpdmVuIGl0ZW0g
d2lsbCBhbHdheXMgaGFwcGVuIG9uIHRoZSBzYW1lIGNwdS4NCj4gPg0KPiA+IChhbGxvYyBhcyBp
biAnYWRkIHRvIExSVSBsaXN0LCBmcmVlIGFzIGluICdyZW1vdmUgZnJvbSBMUlUgbGlzdCkuDQo+
IA0KPiBQbGVhc2UgcmVhZCBwYXRjaC0wNC4NCj4gDQo+IEkndmUgYWRkZWQgImNwdV9hbGxvYyIg
dG8gcmVjb3JkIHRoZSBDUFUgd2VyZSB0aGUgZmlyc3QgZnJhZ21lbnQgZ290DQo+IGFsbG9jYXRl
ZC4gIEFmdGVyIHdoaWNoIGFsbCBmcmFncyBnZXRzIGFjY291bnRlZCB0byB0aGF0IENQVSwNCj4g
YWRkL3JlbW92ZS90aW1lb3V0IGV0Yy4NCg0KSG1tbS4uLiB0aGUgZ2VuZXJhbCBpZGVhIGJlaGlu
ZCBtYWtpbmcgYW55dGhpbmcgJ3Blci1jcHUnIGlzIHNvDQp0aGF0IGxvY2tpbmcgaXNuJ3QgcmVx
dWlyZWQuDQpJZiB5b3UgZW5kIHVwIGRvaW5nIHRoZSAncmVtb3ZlJyBhY2NvdW50aW5nIG9uIGEg
ZGlmZmVyZW50IGNwdSB0aGVuDQphbGwgdGhlIGFjdGlvbnMgcmVxdWlyZSBsb2NrcyAtIHdoaWNo
IG1ha2VzIHBlci1jcHUgZGF0YSBtb3JlIG9yDQpsZXNzIHBvaW50bGVzcy4NCg0KSW4gd2hpY2gg
Y2FzZSB5b3UgYXJlIG11Y2ggYmV0dGVyIG9mZiB1c2luZyBhIGhhc2ggdG8gZGV0ZXJtaW5lDQp0
aGUgbGlzdC4NCg0KCURhdmlkDQoNCg==
