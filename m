From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 5/5] udp: add recvmmsg implementation
Date: Mon, 28 Nov 2016 12:32:07 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB022A28F@AcuExch.aculab.com>
References: <cover.1480086321.git.pabeni@redhat.com>
 <68bfaa7480400457e712fb04ee781410d1bb9479.1480086321.git.pabeni@redhat.com>
 <1165706e-b828-cb12-4bea-b77ccca1cb95@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "Sabrina Dubroca" <sd@queasysnail.net>
To: 'Hannes Frederic Sowa' <hannes@stressinduktion.org>,
        Paolo Abeni <pabeni@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.193]:57596 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932094AbcK1McX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 07:32:23 -0500
In-Reply-To: <1165706e-b828-cb12-4bea-b77ccca1cb95@stressinduktion.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSGFubmVzIEZyZWRlcmljIFNvd2ENCj4gU2VudDogMjUgTm92ZW1iZXIgMjAxNiAxNzow
OQ0KLi4uDQo+IEN1cnJlbnRseSBza19lcnIgaXMgc2V0IHNvIHRoZSBuZXh0IHN5c2NhbGwgd291
bGQgZ2V0IGFuIC1FRkFVTFQsIHdoaWNoDQo+IHNlZW1zIHZlcnkgYmFkIGFuZCBjYW4gYWxzbyBi
ZSBvdmVyd3JpdHRlbiBieSBpbmNvbWluZyBpY21wIHBhY2tldHMsIHNvDQo+IHdlIG5ldmVyIGdl
dCBhIG5vdGlmaWNhdGlvbiB0aGF0IHdlIGFjdHVhbGx5IGhhZCBhIGJhZCBwb2ludGVyIHNvbWV3
aGVyZQ0KPiBpbiB0aGUgbW1zZ2hkci4gQWxzbyBkZWxpdmVyaW5nIC1FRkFVTFQgb24gdGhlIGZv
bGxvdy11cCBzeXNjYWxscyByZWFsbHkNCj4gd2lsbCBtYWtlIHBlb3BsZSBjb25mdXNlZCB0aGF0
IHVzZSBzdHJhY2UuDQoNClNhdmluZyBhbiBlcnJvciBjb2RlIGxpa2UgdGhhdCBzZWVtcyBjb21w
bGV0ZWx5IHdyb25nIHRvIG1lLg0KDQpJdCBpcyBub3QgdW5yZWFzb25hYmxlIGZvciB0aGVyZSB0
byBiZSBtdWx0aXBsZSBzeXN0ZW0gY2FsbHMgYWN0aXZlDQpvbiBhIHNpbmdsZSBzb2NrZXQgYXQg
dGhlIHNhbWUgdGltZSAtIHNvIGFueSBlcnJvciBoYXMgdG8gYmUgcmV0dXJuZWQgdG8NCnRoZSBz
eXN0ZW0gY2FsbCB0aGF0IGdlbmVyYXRlZCBpdC4NCihDdXJyZW50IGxvY2tpbmcgcnVsZXMgbWln
aHQgaW1wb3NlIHJlc3RyaWN0aW9ucywgYnV0IHRoZXkgY291bGQgY2hhbmdlLikNCg0KQSBjb21w
bGV0ZWx5IHN0aWNreSBlcnJvciBjb2RlIG1pZ2h0IGJlIHVzZWZ1bCBpZiB0aGUgb25seSB2YWxp
ZCBhY3Rpb24NCmlzIGNsb3NlKCkuDQoNCklmIGNvcHl0b3VzZXIoKSBmYWlscyBJJ2QgZ3Vlc3Mg
dGhhdCBtb3N0IHN5c3RlbSBjYWxscyBqdXN0IHJldHVybiBFRkFVTFQNCmFuZCBkaXNjYXJkIGFu
eSBkYXRhIHRoYXQgbWlnaHQgaGF2ZSBiZWVuIGNvcGllZCB0byB0aGUgc3RhcnQgb2YgdGhlIHVz
ZXJzDQpidWZmZXIuDQpOb3QgdW5yZWFzb25hYmxlIHNpbmNlIGl0IGlzIGxpa2VseSB0byBiZSBh
IGNvZGluZyBlcnJvci4NCg0KCURhdmlkDQoNCg==
