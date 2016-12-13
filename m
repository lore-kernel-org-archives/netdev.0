From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/3] netns: fix net_generic() "id - 1" bloat
Date: Tue, 13 Dec 2016 14:42:53 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB023DBE9@AcuExch.aculab.com>
References: <20161202012132.GD31170@avx2>
 <063D6719AE5E284EB5DD2968C1650D6DB0234CCB@AcuExch.aculab.com>
 <CACVxJT8axg6i0Lvem=fvKqrjTuOzwg63BDbAuR6bzTPrtLuP+g@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0236F41@AcuExch.aculab.com>
 <CACVxJT8fT0Lbe_ojNjU9DYYO=PO+QzA=jpQb7V6_US8W9D-KTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xemul@openvz.org" <xemul@openvz.org>
To: 'Alexey Dobriyan' <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.189]:61284 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932358AbcLMOnL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 09:43:11 -0500
In-Reply-To: <CACVxJT8fT0Lbe_ojNjU9DYYO=PO+QzA=jpQb7V6_US8W9D-KTQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQWxleGV5IERvYnJpeWFuDQo+IFNlbnQ6IDEzIERlY2VtYmVyIDIwMTYgMTQ6MjMNCi4u
Lg0KPiBXZWxsLCB0aGUgcG9pbnQgb2YgdGhlIHBhdGNoIGlzIHRvIHNhdmUgLnRleHQsIHNvIG1p
Z2h0IGFzIHdlbGwgc2F2ZQ0KPiBhcyBtdWNoIGFzIHBvc3NpYmxlLiBBbnkgZm9ybSBvdGhlciB0
aGFuICJwdHJbaWRdIiBpcyBnb2luZw0KPiB0byBiZSBlaXRoZXIgYmlnZ2VyIG9yIGJpZ2dlciBh
bmQgc2xvd2VyIGFuZCAicHRyIiBzaG91bGQgYmUgdGhlIGZpcnN0IGZpZWxkLg0KDQpZb3UndmUg
bm90IHJlYWQgYW5kIHVuZGVyc3Rvb2QgdGhlIG5leHQgYml0Og0KDQo+ID4gSG93ZXZlciBpZiB5
b3Ugb2Zmc2V0IHRoZSAnaWQnIHZhbHVlcyBzbyB0aGF0IG9ubHkNCj4gPiB2YWx1ZXMgMiB1cCBh
cmUgdmFsaWQgdGhlIGNvZGUgYmVjb21lczoNCj4gPiAgICAgICAgIHJldHVybiBuZXQtPmdlbjIt
PnB0cltpZCAtIDJdOw0KPiA+IHdoaWNoIHdpbGwgYmUgZXhhY3RseSB0aGUgc2FtZSBjb2RlIGFz
Og0KPiA+ICAgICAgICAgcmV0dXJuIG5ldC0+Z2VuMS0+cHRyW2lkXTsNCj4gPiBidXQgaXQgaXMg
bXVjaCBtb3JlIG9idmlvdXMgdGhhdCAnaWQnIHZhbHVlcyBtdXN0IGJlID49IDIuDQo+ID4NCj4g
PiBUaGUgJzInIHNob3VsZCBiZSBnZW5lcmF0ZWQgZnJvbSB0aGUgc3RydWN0dXJlIG9mZnNldCwg
YnV0IHdpdGggbXkgbWV0aG9kDQo+ID4gaXMgZG9lc24ndCBhY3R1YWxseSBtYXR0ZXIgaWYgaXQg
aXMgd3JvbmcuDQoNCklmIHlvdSBoYXZlIGZvby0+YmFyW2lkIC0gY29uc3RdIHRoZW4gdGhlIGNv
bXBpbGVyIGhhcyB0byBhZGQgdGhlDQpvZmZzZXQgb2YgJ2JhcicgYW5kIHN1YnRyYWN0IGZvciAn
Y29uc3QnLg0KSWYgdGhlIG51bWJlcnMgbWF0Y2ggbm8gYWRkIG9yIHN1YnRyYWN0IGlzIG5lZWRl
ZC4NCg0KSXQgaXMgbXVjaCBjbGVhbmVyIHRvIGRvIHRoaXMgYnkgZXhwbGljaXRseSByZW1vdmlu
ZyB0aGUgb2Zmc2V0IG9uIHRoZQ0KYWNjZXNzZXMgdGhhbiB1c2luZyBhIHVuaW9uLg0KDQoJRGF2
aWQNCg0K
