From: Ariel Levkovich <lariel@mellanox.com>
Subject: RE: [PATCH net-next 6/9] net/mlx4_en: Adding support of turning off
 link autonegotiation via ethtool
Date: Mon, 16 Jan 2017 23:08:06 +0000
Message-ID: <DB3PR05MB21933E49B3A1B8CC0C37A32BA7D0@DB3PR05MB219.eurprd05.prod.outlook.com>
References: <1484587805-12666-1-git-send-email-tariqt@mellanox.com>
 <1484587805-12666-7-git-send-email-tariqt@mellanox.com>
 <CAJ3xEMjEPQv=Agz5Wr-2UEL+iv7nz4NAcpCKY9=C4vs6SfKLLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0079.outbound.protection.outlook.com ([104.47.0.79]:45408
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750858AbdAPXIN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 18:08:13 -0500
In-Reply-To: <CAJ3xEMjEPQv=Agz5Wr-2UEL+iv7nz4NAcpCKY9=C4vs6SfKLLA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

KyAgICAgICBNTFg0X1BUWVNfQU5fRElTQUJMRV9DQVAgICA9IDEgPDwgNSwNCg0KSXQncyB0aGVy
ZS4NCg0KQmVzdCBSZWdhcmRzLA0KDQpBcmllbCBMZXZrb3ZpY2gNClN0YWZmIEVuZ2luZWVyLCBT
Vw0KTWVsbGFub3ggVGVjaG5vbG9naWVzDQpCZWl0IE1lbGxhbm94LCBZb2tuZWFtLCBQLk8uQm94
IDU4NiwgSXNyYWVsIDIwNjkyIA0KT2ZmaWNlOiArOTcyLTc0NzIzLTc2NTIsIE1vYmlsZTogKzk3
Mi01Mi0zOTQ3LTcwNCANCnd3dy5tZWxsYW5veC5jb20gDQpGb2xsb3cgdXMgb24gRmFjZWJvb2sg
YW5kIFR3aXR0ZXINCg0KPiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBPciBH
ZXJsaXR6IFttYWlsdG86Z2VybGl0ei5vckBnbWFpbC5jb21dDQo+IFNlbnQ6IE1vbmRheSwgSmFu
dWFyeSAxNiwgMjAxNyA0OjQ4IFBNDQo+IFRvOiBUYXJpcSBUb3VrYW4gPHRhcmlxdEBtZWxsYW5v
eC5jb20+OyBBcmllbCBMZXZrb3ZpY2gNCj4gPGxhcmllbEBtZWxsYW5veC5jb20+DQo+IENjOiBE
YXZpZCBTLiBNaWxsZXIgPGRhdmVtQGRhdmVtbG9mdC5uZXQ+OyBMaW51eCBOZXRkZXYgTGlzdA0K
PiA8bmV0ZGV2QHZnZXIua2VybmVsLm9yZz47IEVyYW4gQmVuIEVsaXNoYSA8ZXJhbmJlQG1lbGxh
bm94LmNvbT4NCj4gU3ViamVjdDogUmU6IFtQQVRDSCBuZXQtbmV4dCA2LzldIG5ldC9tbHg0X2Vu
OiBBZGRpbmcgc3VwcG9ydCBvZiB0dXJuaW5nDQo+IG9mZiBsaW5rIGF1dG9uZWdvdGlhdGlvbiB2
aWEgZXRodG9vbA0KPiANCj4gT24gTW9uLCBKYW4gMTYsIDIwMTcgYXQgNzozMCBQTSwgVGFyaXEg
VG91a2FuIDx0YXJpcXRAbWVsbGFub3guY29tPg0KPiB3cm90ZToNCj4gMDY0NA0KPiA+IC0tLSBh
L2luY2x1ZGUvbGludXgvbWx4NC9kZXZpY2UuaA0KPiA+ICsrKyBiL2luY2x1ZGUvbGludXgvbWx4
NC9kZXZpY2UuaA0KPiA+IEBAIC0xNTM5LDggKzE1MzksMTMgQEAgZW51bSBtbHg0X3B0eXNfcHJv
dG8gew0KPiA+ICAgICAgICAgTUxYNF9QVFlTX0VOID0gMTw8MiwNCj4gPiAgfTsNCj4gPg0KPiA+
ICtlbnVtIG1seDRfcHR5c19mbGFncyB7DQo+ID4gKyAgICAgICBNTFg0X1BUWVNfQU5fRElTQUJM
RV9DQVAgICA9IDEgPDwgNSwNCj4gPiArICAgICAgIE1MWDRfUFRZU19BTl9ESVNBQkxFX0FETUlO
ID0gMSA8PCA2LCB9Ow0KPiA+ICsNCj4gPiAgc3RydWN0IG1seDRfcHR5c19yZWcgew0KPiA+IC0g
ICAgICAgdTggcmVzcnZkMTsNCj4gPiArICAgICAgIHU4IGZsYWdzOw0KPiA+ICAgICAgICAgdTgg
bG9jYWxfcG9ydDsNCj4gPiAgICAgICAgIHU4IHJlc3J2ZDI7DQo+ID4gICAgICAgICB1OCBwcm90
b19tYXNrOw0KPiANCj4gSGkgQXJpZWwsDQo+IA0KPiBJIGRpZG4ndCBzZWUgYW55IG5ldyBkZXYg
Y2FwIGJpdCwgd2hhdCBoYXBwZW5zIHdpdGggRlcgdmVyc2lvbiB3aGljaCBkb24ndA0KPiBzdXBw
b3J0IHRoaXMsIGlzIHRoZSByZXN1bHQgd2VsbCBkZWZpbmVkPyB3aGF0IGlzIGl0Pw0KPiANCj4g
T3IuDQo=
