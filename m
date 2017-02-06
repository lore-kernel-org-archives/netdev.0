From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 2/8] net/mlx5: Configure cache line size for start
 and end padding
Date: Mon, 6 Feb 2017 13:50:23 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB027C806@AcuExch.aculab.com>
References: <20170131205843.23235-1-saeedm@mellanox.com>
 <20170131205843.23235-3-saeedm@mellanox.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0277BC4@AcuExch.aculab.com>
 <VI1PR0501MB2429398983643A6387BE91D0C44C0@VI1PR0501MB2429.eurprd05.prod.outlook.com>
 <CALzJLG_v7kZrioA_VrHT78iatiEOSCp9uWUJFNv1XP6+sMvFzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Saeed Mahameed' <saeedm@dev.mellanox.co.il>,
        Daniel Jurgens <danielj@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.183]:54355 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752499AbdBFNuh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 08:50:37 -0500
In-Reply-To: <CALzJLG_v7kZrioA_VrHT78iatiEOSCp9uWUJFNv1XP6+sMvFzQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogU2FlZWQgTWFoYW1lZWQgDQo+IFNlbnQ6IDA1IEZlYnJ1YXJ5IDIwMTcgMTE6MjQNCj4g
T24gVGh1LCBGZWIgMiwgMjAxNyBhdCA0OjQ3IFBNLCBEYW5pZWwgSnVyZ2VucyA8ZGFuaWVsakBt
ZWxsYW5veC5jb20+IHdyb3RlOg0KPiA+IE9uIDIvMS8yMDE3IDU6MTIgQU0sIERhdmlkIExhaWdo
dCB3cm90ZToNCj4gPj4gRnJvbTogU2FlZWQgTWFoYW1lZWQNCj4gPj4+IFNlbnQ6IDMxIEphbnVh
cnkgMjAxNyAyMDo1OQ0KPiA+Pj4gRnJvbTogRGFuaWVsIEp1cmdlbnMgPGRhbmllbGpAbWVsbGFu
b3guY29tPg0KPiA+Pj4NCj4gPj4+IFRoZXJlIGlzIGEgaGFyZHdhcmUgZmVhdHVyZSB0aGF0IHdp
bGwgcGFkIHRoZSBzdGFydCBvciBlbmQgb2YgYSBETUEgdG8NCj4gPj4+IGJlIGNhY2hlIGxpbmUg
YWxpZ25lZCB0byBhdm9pZCBSTVdzIG9uIHRoZSBsYXN0IGNhY2hlIGxpbmUuIFRoZSBkZWZhdWx0
DQo+ID4+PiBjYWNoZSBsaW5lIHNpemUgc2V0dGluZyBmb3IgdGhpcyBmZWF0dXJlIGlzIDY0Qi4g
VGhpcyBjaGFuZ2UgY29uZmlndXJlcw0KPiA+Pj4gdGhlIGhhcmR3YXJlIHRvIHVzZSAxMjhCIGFs
aWdubWVudCBvbiBzeXN0ZW1zIHdpdGggMTI4QiBjYWNoZSBsaW5lcy4NCj4gPj4gV2hhdCBndWFy
YW50ZWVzIHRoYXQgdGhlIGV4dHJhIGJ5dGVzIGFyZSBhY3R1YWxseSBpbnNpZGUgdGhlIHJlY2Vp
dmUgc2tiJ3MNCj4gPj4gaGVhZCBhbmQgdGFpbCByb29tPw0KPiA+Pg0KPiA+PiAgICAgICBEYXZp
ZA0KPiA+Pg0KPiA+Pg0KPiA+IFRoZSBoYXJkd2FyZSB3b24ndCBvdmVyIHdyaXRlIHRoZSBsZW5n
dGggb2YgdGhlIHBvc3RlZCBidWZmZXIuICBUaGlzIGZlYXR1cmUgaXMgYWxyZWFkeSBlbmFibGVk
IGFuZA0KPiBkZWZhdWx0cyB0byA2NEIgc3RyaWRlLCB0aGlzIHBhdGNoIGp1c3QgY29uZmlndXJl
cyBpdCBwcm9wZXJseSBmb3IgMTI4QiBjYWNoZSBsaW5lIHNpemVzLg0KPiA+DQo+IFJpZ2h0LCBh
bmQgbmV4dCBwYXRjaCB3aWxsIG1ha2Ugc3VyZSBSWCBzdHJpZGUgaXMgYWxpZ25lZCB0byAxMjhC
IGluDQo+IGNhc2UgMTI4QiBjYWNoZWxpbmUgc2l6ZSBjb25maWd1cmVkIGludG8gdGhlIEhXLg0K
DQpEb2Vzbid0IHRoYXQgbWVhbiB0aGVzZSBwYXRjaGVzIGFyZSBpbiB0aGUgd3Jvbmcgb3JkZXI/
DQoNCj4gPiBUaGFua3MgZm9yIHJldmlld2luZyBpdC4NCg0KRG9uJ3QgYXNzdW1lIEkndmUgZG9u
ZSBhbnl0aGluZyBvdGhlciB0aGFuIGxvb2sgZm9yIG9idmlvdXMgZnViYXJzLw0KDQoJRGF2aWQN
Cg0K
