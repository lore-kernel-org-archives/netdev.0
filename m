From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 net] net: solve a NAPI race
Date: Wed, 1 Mar 2017 10:41:37 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFE727EB@AcuExch.aculab.com>
References: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
 <1488166294.9415.172.camel@edumazet-glaptop3.roam.corp.google.com>
 <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UeSpxzgePoidJumQFvM5a2mOC5+rL8gCHqvX-HBvrn74A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: 'Alexander Duyck' <alexander.duyck@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.185]:65320 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752323AbdCAKl7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 05:41:59 -0500
In-Reply-To: <CAKgT0UeSpxzgePoidJumQFvM5a2mOC5+rL8gCHqvX-HBvrn74A@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQWxleGFuZGVyIER1eWNrDQo+IFNlbnQ6IDI4IEZlYnJ1YXJ5IDIwMTcgMTc6MjANCi4u
Lg0KPiBZb3UgbWlnaHQgd2FudCB0byBjb25zaWRlciBqdXN0IHVzaW5nIGEgY29tYmluYXRpb24g
QU5ELCBkaXZpZGUsDQo+IG11bHRpcGx5LCBhbmQgT1IgdG8gYXZvaWQgaGF2aW5nIHRvIGhhdmUg
YW55IGNvbmRpdGlvbmFsIGJyYW5jaGVzDQo+IGJlaW5nIGFkZGVkIGR1ZSB0byB0aGlzIGNvZGUg
cGF0aC4gIEJhc2ljYWxseSB0aGUgbG9naWMgd291bGQgbG9vaw0KPiBsaWtlOg0KPiAgICAgbmV3
ID0gdmFsIHwgTkFQSUZfU1RBVEVfU0NIRUQ7DQo+ICAgICBuZXcgfD0gKHZhbCAmIE5BUElGX1NU
QVRFX1NDSEVEKSAvIE5BUElGX1NUQVRFX1NDSEVEICogTkFQSUZfU1RBVEVfTUlTU0VEOw0KPiAN
Cj4gSW4gYXNzZW1ibGVyIHRoYXQgYWxsIGVuZHMgdXAgZ2V0dGluZyB0cmFuc2xhdGVkIG91dCB0
byBBTkQsIFNITCwgT1IuDQo+IFlvdSBhdm9pZCB0aGUgYnJhbmNoaW5nLCBvciBNT1YvT1IvVEVT
VC9DTU9WIHR5cGUgY29kZSB5b3Ugd291bGQgZW5kDQo+IHVwIHdpdGggb3RoZXJ3aXNlLg0KDQpJ
dCBpcyBhIHNoYW1lIGdjYyBkb2Vzbid0IGNvbnRhaW4gdGhhdCBvcHRpbWlzYXRpb24uDQpJdCBh
bHNvIGRvZXNuJ3QgZXZlbiBtYWtlIGEgZ29vZCBqb2Igb2YgKGEgJiBiKS9iICogYyBzaW5jZSBp
dA0KYWx3YXlzIGRvZXMgYSBzaHIgYW5kIGEgc2FsIChnY2MgNC43LjMgYW5kIDUuNCkuDQoNCldv
cnRoeSBvZiBhICNkZWZpbmUgb3Igc3RhdGljIGlubGluZS4NClNvbWV0aGluZyBsaWtlOg0KI2Rl
ZmluZSBCSVRfSUYodiwgYSwgYikgKChiICYgKGItMSkgPyAodiAmIGEpL2EgKiBiIDogYSA+IGIg
PyAodiAmIGEpIC8gKGEvYikgOiAodiAmIGEpICogKGIvYSkpDQoNCglEYXZpZA0K
