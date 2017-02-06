From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 6/8] net: ethernet: annapurna: add wol helpers
 to the Alpine driver
Date: Mon, 6 Feb 2017 11:35:49 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB027C6C3@AcuExch.aculab.com>
References: <20170203181216.30214-1-antoine.tenart@free-electrons.com>
 <20170203181216.30214-7-antoine.tenart@free-electrons.com>
 <08b62752-8bb2-4633-c44f-74eb585e7e52@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "tsahee@annapurnalabs.com" <tsahee@annapurnalabs.com>,
        "rshitrit@annapurnalabs.com" <rshitrit@annapurnalabs.com>,
        "saeed@annapurnalabs.com" <saeed@annapurnalabs.com>,
        "barak@annapurnalabs.com" <barak@annapurnalabs.com>,
        "talz@annapurnalabs.com" <talz@annapurnalabs.com>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>,
        "arnd@arndb.de" <arnd@arndb.de>
To: 'Sergei Shtylyov' <sergei.shtylyov@cogentembedded.com>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.181]:65170 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751343AbdBFLgB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 06:36:01 -0500
In-Reply-To: <08b62752-8bb2-4633-c44f-74eb585e7e52@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogbmV0ZGV2LW93bmVyQHZnZXIua2VybmVsLm9yZyBbbWFpbHRvOm5ldGRldi1vd25lckB2
Z2VyLmtlcm5lbC5vcmddIE9uIEJlaGFsZiBPZiBTZXJnZWkgU2h0eWx5b3YNCj4gU2VudDogMDMg
RmVicnVhcnkgMjAxNyAxODoyMg0KPiBPbiAwMi8wMy8yMDE3IDA5OjEyIFBNLCBBbnRvaW5lIFRl
bmFydCB3cm90ZToNCj4gDQo+ID4gSW1wbGVtZW50IHRoZSBnZXRfd29sKCkgYW5kIHNldF93b2wo
KSBoZWxwZXJzIGluIHRoZSBBbm5hcHVybmEgTGFicw0KPiA+IEFscGluZSBFdGhlcm5ldCBkcml2
ZXIuDQo+ID4gLS0tDQo+ID4gIGRyaXZlcnMvbmV0L2V0aGVybmV0L2FubmFwdXJuYS9hbF9ldGgu
YyB8IDQ0ICsrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKw0KPiA+ICAxIGZpbGUgY2hh
bmdlZCwgNDQgaW5zZXJ0aW9ucygrKQ0KPiA+DQo+ID4gZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0
L2V0aGVybmV0L2FubmFwdXJuYS9hbF9ldGguYyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2FubmFw
dXJuYS9hbF9ldGguYw0KPiA+IGluZGV4IDhkZDg0ZjY2YjVkMS4uZDA2YTc1YTQ5Y2U1IDEwMDY0
NA0KPiA+IC0tLSBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L2FubmFwdXJuYS9hbF9ldGguYw0KPiA+
ICsrKyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2FubmFwdXJuYS9hbF9ldGguYw0KPiA+IEBAIC0y
NTE5LDEwICsyNTE5LDU0IEBAIHN0YXRpYyB1MzIgYWxfZXRoX2dldF9yeGZoX2luZGlyX3NpemUo
c3RydWN0IG5ldF9kZXZpY2UgKm5ldGRldikNCj4gPiAgCXJldHVybiBBTF9FVEhfUlhfUlNTX1RB
QkxFX1NJWkU7DQo+ID4gIH0NCj4gPg0KPiA+ICtzdGF0aWMgdm9pZCBhbF9ldGhfZ2V0X3dvbChz
dHJ1Y3QgbmV0X2RldmljZSAqbmV0ZGV2LA0KPiA+ICsJCQkgICBzdHJ1Y3QgZXRodG9vbF93b2xp
bmZvICp3b2wpDQo+ID4gK3sNCj4gPiArCXN0cnVjdCBhbF9ldGhfYWRhcHRlciAqYWRhcHRlciA9
IG5ldGRldl9wcml2KG5ldGRldik7DQo+ID4gKwlzdHJ1Y3QgcGh5X2RldmljZSAqcGh5ZGV2Ow0K
PiA+ICsNCj4gPiArCXdvbC0+d29sb3B0cyA9IGFkYXB0ZXItPndvbDsNCj4gPiArDQo+ID4gKwlp
ZiAoKGFkYXB0ZXIpICYmIChhZGFwdGVyLT5waHlfZXhpc3QpICYmIChhZGFwdGVyLT5tZGlvX2J1
cykpIHsNCj4gDQo+ICAgICBOb3cgdGhhdCdzIHNvbWV3aGF0IHN0dXBpZCBsb29raW5nLi4uIGRv
ZXMgdGhlIHdob2xlIGRyaXZlciB1c2UgdGhpcyAic3R5bGUiPw0KDQpOb3Qgb25seSB0aGF0LCBp
biBvbmUgb2YgdGhlIHR3byBmdW5jdGlvbnMgaXQgaXMgZm9sbG93ZWQgYnk6DQoNCisJZGV2aWNl
X3NldF93YWtldXBfZW5hYmxlKCZhZGFwdGVyLT5wZGV2LT5kZXYsIGFkYXB0ZXItPndvbCk7DQoN
CldoaWNoIGFzc3VtZXMgdGhhdCAnYWRhcHRlcicgaXMgbm90IE5VTEwuDQpTb21lIHZlcmlmaWVy
cyB3aWxsIGRldGVjdCB0aGF0IGFzIGEgcG9zc2libGUgTlVMTCBwb2ludGVyIGRlcmVmZXJlbmNl
Lg0KDQpQb2ludGVycyBzaG91bGQgb25seSBiZSBjaGVja2VkIGZvciBOVUxMIGlmIHRoZXJlIGFy
ZSB2YWxpZCByZWFzb25zDQp3aHkgdGhleSBjYW4gYmUgTlVMTCBpbiB0aGF0IGNvZGUgcGF0aC4N
CkdldHRpbmcgdGhlcmUgd2l0aCBhIE5VTEwgcG9pbnRlciBkdWVzIHRvIHNvbWUgcmFjZSBjb25k
aXRpb24gaXNuJ3Qgb25lIG9mIHRoZW0uDQoNCglEYXZpZA0KDQoNCg==
