From: Andy Duan <fugang.duan@nxp.com>
Subject: Re: IMX6 FEC connection drops occasionally with 'MDIO read timeout'
Date: Thu, 13 Apr 2017 05:45:08 +0000
Message-ID: <0d3d343d-83af-8657-2430-27e188f53b37@nxp.com>
References: <CAJ+vNU1UG2EeJSTStT_BJ+RiRe4a8YwfRgnE6DsRghTLetq_rg@mail.gmail.com>
 <20170407160915.GF23415@lunn.ch>
 <CAJ+vNU2itJEBMLNz--w9FOis_jMHW9c+UPwU6wh+ma59kbeswA@mail.gmail.com>
 <CAOMZO5DnKfNF__HThRBMix-yr6X9-x0VOVm57oeCQ2iwyL8gzg@mail.gmail.com>
 <CAJ+vNU1sBrtno7TiXieN0jKaoNXW8EdKtKO49=FfXy8JNSmd6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
        "Fabio Estevam" <fabio.estevam@nxp.com>,
        Lucas Stach <l.stach@pengutronix.de>,
        "Koen Vandeputte" <koen.vandeputte@ncentric.com>
To: Tim Harvey <tharvey@gateworks.com>,
        Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0060.outbound.protection.outlook.com ([104.47.2.60]:47397
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751598AbdDMFpL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 01:45:11 -0400
In-Reply-To: <CAJ+vNU1sBrtno7TiXieN0jKaoNXW8EdKtKO49=FfXy8JNSmd6A@mail.gmail.com>
Content-Language: en-US
Content-ID: <7B1FBA901448BD498CF3D1E545F4E110@eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQpPbiAyMDE35bm0MDTmnIgxM+aXpSAwMDo1NCwgVGltIEhhcnZleSB3cm90ZToNCj4gT24gV2Vk
LCBBcHIgMTIsIDIwMTcgYXQgOToyNiBBTSwgRmFiaW8gRXN0ZXZhbSA8ZmVzdGV2YW1AZ21haWwu
Y29tPiB3cm90ZToNCj4+IEhpIFRpbSwNCj4+DQo+PiBPbiBXZWQsIEFwciAxMiwgMjAxNyBhdCAx
OjE1IFBNLCBUaW0gSGFydmV5IDx0aGFydmV5QGdhdGV3b3Jrcy5jb20+IHdyb3RlOg0KPj4+IEFu
ZHJldywNCj4+Pg0KPj4+IFRoYW5rcyBmb3IgdGhlIHJlcGx5LiBZb3VyIHRhbGtpbmcgYWJvdXQg
c3VzcGVuZC9yZXN1bWUgcG93ZXINCj4+PiBtYW5hZ2VtZW50IHJpZ2h0PyBUaGUgdXNlcnMgcmVw
b3J0aW5nIHRoaXMgd2VyZSBub3QgdXNpbmcNCj4+PiBzdXNwZW5kL3Jlc3VtZS4NCj4+Pg0KPj4+
IFdpdGggcmVnYXJkcyB0byBjbG9jayBhcmUgeW91IHRhbGtpbmcgYWJvdXQgdGhlIElQRyBjbG9j
az8gSXMgdGhlcmUNCj4+PiBhbnkgb3RoZXIgd2F5IHRoYXQgd291bGQgZ2V0IHR1cm5lZCBvZmYg
b3RoZXIgdGhhbiBmZWMgc3VzcGVuZC9yZXN1bWU/DQo+PiBZZXMsIHRocm91Z2ggcG1fcnVudGlt
ZS4NCj4+DQo+PiBDYW4geW91IGNoZWNrIGlmIHRoaXMgcXVpY2sgZGVidWcgY2hhbmdlIGhlbHA/
DQo+Pg0KPj4gLS0tIGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvZnJlZXNjYWxlL2ZlY19tYWluLmMN
Cj4+ICsrKyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ZyZWVzY2FsZS9mZWNfbWFpbi5jDQo+PiBA
QCAtMzYwNiw4ICszNjA2LDYgQEAgc3RhdGljIGludCBfX21heWJlX3VudXNlZA0KPj4gZmVjX3J1
bnRpbWVfc3VzcGVuZChzdHJ1Y3QgZGV2aWNlICpkZXYpDQo+PiAgICAgICAgICBzdHJ1Y3QgbmV0
X2RldmljZSAqbmRldiA9IGRldl9nZXRfZHJ2ZGF0YShkZXYpOw0KPj4gICAgICAgICAgc3RydWN0
IGZlY19lbmV0X3ByaXZhdGUgKmZlcCA9IG5ldGRldl9wcml2KG5kZXYpOw0KPj4NCj4+IC0gICAg
ICAgY2xrX2Rpc2FibGVfdW5wcmVwYXJlKGZlcC0+Y2xrX2lwZyk7DQo+PiAtDQo+PiAgICAgICAg
ICByZXR1cm4gMDsNCj4+ICAgfQ0KPj4NCj4+DQo+PiBJZiB5b3UgZG9uJ3Qgc2VlIHRoZSBwcm9i
bGVtIHdpdGggaXQsIHRoZW4gaXQgbWVhbnMgd2UgbmVlZCB0byBmaXggdGhlDQo+PiBwbSBydW50
aW1lIHN1cHBvcnQgaW4gdGhpcyBkcml2ZXIuDQo+Pg0KPj4gTW9zdCBsaWtlbHkgcG0gcnVudGlt
ZSBpcyB0dXJuaW5nIG9mZiB0aGUgY2xvY2tzIHdoZW4gaXQgc2hvdWxkIG5vdC4NCj4gRmFiaW8s
DQo+DQo+IE9rLCBJIHVuZGVyc3RhbmQgbm93LiBXZSB3aWxsIGRpc2FibGUgdGhlIElQRyBjbG9j
ayBkaXNhYmxlIGFuZCBzZWUgaWYNCj4gdGhhdCBtYWtlcyBhIGRpZmZlcmVuY2UuDQo+DQo+IFRp
bQ0KRmlyc3RseSwgcGxzIHRyeSB0aGUgY2hhbmdlIHN1Z2dlc3RlZCBieSBBbmRyZXcuDQpJIGd1
ZXNzIHN5c3RlbSBlbnRlciB0byB3YWl0IG1vZGUsIGFuZCBlbmV0IGlycSBjYW5ub3Qgd2FrZXVw
IHN5c3RlbSBpbiANCnJlYWwgdGltZSB0aGF0IGNhdXNlcyBtaWkgaXJxIG11Y2ggbGF0ZW5jeS4g
dGhlbiBtaWkgYnVzIGFjY2VzcyB0aW1lb3V0Lg0KSWYgc28sIGNhbiB5b3UgYWRkIGJlbG93IGNo
YW5nZSB0byB5b3VyIGR0cyBmaWxlIGFuZCB0cnkgaXQgPw0KDQppb211eCBwaW5jdHJsOg0KICAg
ICAgICAgICAgICAgICBwaW5jdHJsX2VuZXRfaXJxOiBlbmV0aXJxZ3JwIHsNCiAgICAgICAgICAg
ICAgICAgICAgICAgICBmc2wscGlucyA9IDwNCk1YNlFETF9QQURfR1BJT182X19FTkVUX0lSUSAg
ICAgICAgICAgICAweDAwMGIxDQogICAgICAgICAgICAgICAgICAgICAgICAgPjsNCiAgICAgICAg
ICAgICAgICAgfTsNCg0KDQomZmVjIHsNCiAgICAgICAgIC4uLg0KICAgICAgICAgcGluY3RybC0w
ID0gPCZwaW5jdHJsX2VuZXQgJnBpbmN0cmxfZW5ldF9pcnE+Ow0KICAgICAgICAgaW50ZXJydXB0
cy1leHRlbmRlZCA9IDwmZ3BpbzEgNiAweDA0PiwgPCZncGMgMCAxMTkgMHgwND47DQogICAgICAg
ICAuLi4NCn07DQoNCiZpMmMzIHsNCiAgICAgICAgIC4uLg0KICAgICAgICAgc3RhdHVzID0gImRp
c2FibGVkIjsNCn07DQoNCg0KUmVnYXJkcywNCkFuZHk=
