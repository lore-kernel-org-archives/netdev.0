From: <Nisar.Sayed@microchip.com>
Subject: RE: [PATCH v4 net 2/3] lan78xx: Allow EEPROM write for less than
 MAX_EEPROM_SIZE
Date: Wed, 20 Sep 2017 15:27:14 +0000
Message-ID: <CE371C1263339941885964188A0225FA33A21C@CHN-SV-EXMX03.mchp-main.com>
References: <20170918220225.3767-1-Nisar.Sayed@microchip.com>
 <20170918220225.3767-3-Nisar.Sayed@microchip.com>
 <17bc270e-9cc1-485a-d6bb-0ebfa143e65e@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>
To: <sergei.shtylyov@cogentembedded.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa2.microchip.iphmx.com ([68.232.149.84]:15989 "EHLO
        esa2.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751408AbdITP1Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 11:27:16 -0400
In-Reply-To: <17bc270e-9cc1-485a-d6bb-0ebfa143e65e@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VGhhbmtzIFNlcmdlaSwgSSB3aWxsIHVwZGF0ZSBpdCBhbmQgc3VibWl0IG5leHQgdmVyc2lvbi4N
Cg0KLSBOaXNhcg0KDQogPiBIZWxsbyENCj4gDQo+IE9uIDA5LzE5LzIwMTcgMDE6MDIgQU0sIE5p
c2FyIFNheWVkIHdyb3RlOg0KPiANCj4gPiBBbGxvdyBFRVBST00gd3JpdGUgZm9yIGxlc3MgdGhh
biBNQVhfRUVQUk9NX1NJWkUNCj4gPg0KPiA+IEZpeGVzOiA1NWQ3ZGU5ZGU2YzMgKCJNaWNyb2No
aXAncyBMQU43ODAwIGZhbWlseSBVU0IgMi8zIHRvDQo+ID4gMTAvMTAwLzEwMDAgRXRoZXJuZXQg
ZGV2aWNlIGRyaXZlciIpDQo+ID4gU2lnbmVkLW9mZi1ieTogTmlzYXIgU2F5ZWQgPE5pc2FyLlNh
eWVkQG1pY3JvY2hpcC5jb20+DQo+ID4gLS0tDQo+ID4gICBkcml2ZXJzL25ldC91c2IvbGFuNzh4
eC5jIHwgOSArKysrLS0tLS0NCj4gPiAgIDEgZmlsZSBjaGFuZ2VkLCA0IGluc2VydGlvbnMoKyks
IDUgZGVsZXRpb25zKC0pDQo+ID4NCj4gPiBkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvdXNiL2xh
bjc4eHguYyBiL2RyaXZlcnMvbmV0L3VzYi9sYW43OHh4LmMNCj4gPiBpbmRleCBmY2Y4NWFlMzc0
MzUuLjMyOTJmNTZmZmUwMiAxMDA2NDQNCj4gPiAtLS0gYS9kcml2ZXJzL25ldC91c2IvbGFuNzh4
eC5jDQo+ID4gKysrIGIvZHJpdmVycy9uZXQvdXNiL2xhbjc4eHguYw0KPiA+IEBAIC0xMjkwLDEx
ICsxMjkwLDEwIEBAIHN0YXRpYyBpbnQgbGFuNzh4eF9ldGh0b29sX3NldF9lZXByb20oc3RydWN0
DQo+IG5ldF9kZXZpY2UgKm5ldGRldiwNCj4gPiAgIAlpZiAocmV0KQ0KPiA+ICAgCQlyZXR1cm4g
cmV0Ow0KPiA+DQo+ID4gLQkvKiBBbGxvdyBlbnRpcmUgZWVwcm9tIHVwZGF0ZSBvbmx5ICovDQo+
ID4gLQlpZiAoKGVlLT5tYWdpYyA9PSBMQU43OFhYX0VFUFJPTV9NQUdJQykgJiYNCj4gPiAtCSAg
ICAoZWUtPm9mZnNldCA9PSAwKSAmJg0KPiA+IC0JICAgIChlZS0+bGVuID09IDUxMikgJiYNCj4g
PiAtCSAgICAoZGF0YVswXSA9PSBFRVBST01fSU5ESUNBVE9SKSkNCj4gPiArCS8qIEludmFsaWQg
RUVQUk9NX0lORElDQVRPUiBhdCBvZmZzZXQgemVybyB3aWxsIHJlc3VsdCBpbiBmYWlsIHRvDQo+
IA0KPiAgICAgcy9mYWlsL2EgZmFpbHVyZS8uDQo+IA0KPiA+ICsJICogbG9hZCBkYXRhIGZyb20g
RUVQUk9NDQo+ID4gKwkgKi8NCj4gPiArCWlmIChlZS0+bWFnaWMgPT0gTEFONzhYWF9FRVBST01f
TUFHSUMpDQo+ID4gICAJCXJldCA9IGxhbjc4eHhfd3JpdGVfcmF3X2VlcHJvbShkZXYsIGVlLT5v
ZmZzZXQsIGVlLT5sZW4sDQo+IGRhdGEpOw0KPiA+ICAgCWVsc2UgaWYgKChlZS0+bWFnaWMgPT0g
TEFONzhYWF9PVFBfTUFHSUMpICYmDQo+ID4gICAJCSAoZWUtPm9mZnNldCA9PSAwKSAmJg0KPiA+
DQo+IA0KPiBNQlIsIFNlcmdlaQ0K
