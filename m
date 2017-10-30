From: Nogah Frankel <nogahf@mellanox.com>
Subject: RE: [patch net-next RFC 1/9] net_sch: red: Add offload ability to RED
 qdisc
Date: Mon, 30 Oct 2017 13:54:31 +0000
Message-ID: <DB5PR05MB18954A4B8E0C9F9300F3EE59AC590@DB5PR05MB1895.eurprd05.prod.outlook.com>
References: <20171030085613.8697-1-jiri@resnulli.us>
        <20171030085613.8697-2-jiri@resnulli.us>
 <20171030.212015.742241045938302800.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        mlxsw <mlxsw@mellanox.com>, "andrew@lunn.ch" <andrew@lunn.ch>,
        "vivien.didelot@savoirfairelinux.com"
        <vivien.didelot@savoirfairelinux.com>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "michael.chan@broadcom.com" <michael.chan@broadcom.com>,
        "ganeshgr@chelsio.com" <ganeshgr@chelsio.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        "Leon Romanovsky" <leonro@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        "jakub.kicinski@netronome.com" <jakub.kicinski@netronome.com>,
        "simon.horman@netronome.com" <simon.horman@netronome.com>,
        "pieter.jansenvanvuuren@netronome.com"
        <pieter.jansenvanvu
To: David Miller <davem@davemloft.net>,
        "jiri@resnulli.us" <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr40068.outbound.protection.outlook.com ([40.107.4.68]:54640
        "EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751572AbdJ3Nyi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 09:54:38 -0400
In-Reply-To: <20171030.212015.742241045938302800.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogRGF2aWQgTWlsbGVyIFtt
YWlsdG86ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldF0NCj4gU2VudDogTW9uZGF5LCBPY3RvYmVyIDMwLCAy
MDE3IDI6MjAgUE0NCj4gVG86IGppcmlAcmVzbnVsbGkudXMNCj4gQ2M6IG5ldGRldkB2Z2VyLmtl
cm5lbC5vcmc7IE5vZ2FoIEZyYW5rZWwgPG5vZ2FoZkBtZWxsYW5veC5jb20+OyBqaHNAbW9qYXRh
dHUuY29tOw0KPiB4aXlvdS53YW5nY29uZ0BnbWFpbC5jb207IG1seHN3IDxtbHhzd0BtZWxsYW5v
eC5jb20+OyBhbmRyZXdAbHVubi5jaDsNCj4gdml2aWVuLmRpZGVsb3RAc2F2b2lyZmFpcmVsaW51
eC5jb207IGYuZmFpbmVsbGlAZ21haWwuY29tOyBtaWNoYWVsLmNoYW5AYnJvYWRjb20uY29tOw0K
PiBnYW5lc2hnckBjaGVsc2lvLmNvbTsgU2FlZWQgTWFoYW1lZWQgPHNhZWVkbUBtZWxsYW5veC5j
b20+OyBNYXRhbiBCYXJhaw0KPiA8bWF0YW5iQG1lbGxhbm94LmNvbT47IExlb24gUm9tYW5vdnNr
eSA8bGVvbnJvQG1lbGxhbm94LmNvbT47IElkbyBTY2hpbW1lbA0KPiA8aWRvc2NoQG1lbGxhbm94
LmNvbT47IGpha3ViLmtpY2luc2tpQG5ldHJvbm9tZS5jb207IHNpbW9uLmhvcm1hbkBuZXRyb25v
bWUuY29tOw0KPiBwaWV0ZXIuamFuc2VudmFudnV1cmVuQG5ldHJvbm9tZS5jb207IGpvaG4uaHVy
bGV5QG5ldHJvbm9tZS5jb207DQo+IGFsZXhhbmRlci5oLmR1eWNrQGludGVsLmNvbTsgT3IgR2Vy
bGl0eiA8b2dlcmxpdHpAbWVsbGFub3guY29tPjsNCj4gam9obi5mYXN0YWJlbmRAZ21haWwuY29t
DQo+IFN1YmplY3Q6IFJlOiBbcGF0Y2ggbmV0LW5leHQgUkZDIDEvOV0gbmV0X3NjaDogcmVkOiBB
ZGQgb2ZmbG9hZCBhYmlsaXR5IHRvIFJFRCBxZGlzYw0KPiANCj4gRnJvbTogSmlyaSBQaXJrbyA8
amlyaUByZXNudWxsaS51cz4NCj4gRGF0ZTogTW9uLCAzMCBPY3QgMjAxNyAwOTo1NjowNSArMDEw
MA0KPiANCj4gPiBkaWZmIC0tZ2l0IGEvaW5jbHVkZS91YXBpL2xpbnV4L3BrdF9zY2hlZC5oIGIv
aW5jbHVkZS91YXBpL2xpbnV4L3BrdF9zY2hlZC5oDQo+ID4gaW5kZXggMGU4OGNjMi4uNzQzYzQy
YSAxMDA2NDQNCj4gPiAtLS0gYS9pbmNsdWRlL3VhcGkvbGludXgvcGt0X3NjaGVkLmgNCj4gPiAr
KysgYi9pbmNsdWRlL3VhcGkvbGludXgvcGt0X3NjaGVkLmgNCj4gPiBAQCAtMjU1LDYgKzI1NSw3
IEBAIHN0cnVjdCB0Y19yZWRfcW9wdCB7DQo+ID4gICNkZWZpbmUgVENfUkVEX0VDTgkJMQ0KPiA+
ICAjZGVmaW5lIFRDX1JFRF9IQVJERFJPUAkJMg0KPiA+ICAjZGVmaW5lIFRDX1JFRF9BREFQVEFU
SVZFCTQNCj4gPiArI2RlZmluZSBUQ19SRURfT0ZGTE9BREVECTgNCj4gPiAgfTsNCj4gPg0KPiA+
ICBzdHJ1Y3QgdGNfcmVkX3hzdGF0cyB7DQo+IA0KPiBXaGF0IGtlZXBzIGEgdXNlciBmcm9tIHNl
dHRpbmcgdGhpcyBmbGFnIGluIHRoZSB0Y19yZWRfcW9wdCBpdA0KPiBwYXNzZXMgaW50byB0aGUg
YSBjaGFuZ2Ugb3BlcmF0aW9uPw0KDQpOb3RoaW5nIGtlZXBzIHRoZSB1c2VyIGZyb20gZG9pbmcg
aXQsIGJ1dCBpdCBoYXMgbm8gZWZmZWN0Lg0KVGhlIGRlY2lzaW9uIHRvIG9mZmxvYWQgaXMgdGhl
IGRyaXZlcidzIG9ubHkuDQpJdCBpcyBiYXNpY2FsbHkgYSByZWFkLW9ubHkgZmxhZy4NCg0K
