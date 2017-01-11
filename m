From: "Kwok, WingMan" <w-kwok2@ti.com>
Subject: RE: Marvell Phy (1510) issue since v4.7 kernel
Date: Wed, 11 Jan 2017 22:41:53 +0000
Message-ID: <230CBA6E4B6B6B418E8730AC28E6FC7E15354AE5@DFLE11.ent.ti.com>
References: <587410EF.5090607@ti.com> <20170109225641.GB22820@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E153545A3@DFLE11.ent.ti.com>
 <20170109235534.GH22820@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E153545C9@DFLE11.ent.ti.com>
 <20170110015336.GA7160@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354AC2@DFLE11.ent.ti.com>
 <20170111222758.GG13033@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Karicheri, Muralidharan" <m-karicheri2@ti.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        "rmk+kernel@arm.linux.org.uk" <rmk+kernel@arm.linux.org.uk>,
        "charles-antoine.couret@nexvision.fr"
        <charles-antoine.couret@nexvision.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx209.ext.ti.com ([198.47.19.16]:63962 "EHLO
        fllnx209.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751778AbdALBbH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 20:31:07 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogS3dvaywgV2luZ01hbg0K
PiBTZW50OiBXZWRuZXNkYXksIEphbnVhcnkgMTEsIDIwMTcgNTozMiBQTQ0KPiBUbzogJ0FuZHJl
dyBMdW5uJzsgJ3JtaytrZXJuZWxAYXJtLmxpbnV4Lm9yZy51aycNCj4gQ2M6IEthcmljaGVyaSwg
TXVyYWxpZGhhcmFuOyBuZXRkZXZAdmdlci5rZXJuZWwub3JnDQo+IFN1YmplY3Q6IFJFOiBNYXJ2
ZWxsIFBoeSAoMTUxMCkgaXNzdWUgc2luY2UgdjQuNyBrZXJuZWwNCj4gDQo+IA0KPiANCj4gPiAt
LS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiA+IEZyb206IEFuZHJldyBMdW5uIFttYWlsdG86
YW5kcmV3QGx1bm4uY2hdDQo+ID4gU2VudDogV2VkbmVzZGF5LCBKYW51YXJ5IDExLCAyMDE3IDU6
MjggUE0NCj4gPiBUbzogS3dvaywgV2luZ01hbg0KPiA+IENjOiBLYXJpY2hlcmksIE11cmFsaWRo
YXJhbjsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZw0KPiA+IFN1YmplY3Q6IFJlOiBNYXJ2ZWxsIFBo
eSAoMTUxMCkgaXNzdWUgc2luY2UgdjQuNyBrZXJuZWwNCj4gPg0KPiA+IE9uIFdlZCwgSmFuIDEx
LCAyMDE3IGF0IDEwOjE4OjAyUE0gKzAwMDAsIEt3b2ssIFdpbmdNYW4gd3JvdGU6DQo+ID4gPg0K
PiA+ID4NCj4gPiA+ID4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gPiA+ID4gRnJvbTog
QW5kcmV3IEx1bm4gW21haWx0bzphbmRyZXdAbHVubi5jaF0NCj4gPiA+ID4gU2VudDogTW9uZGF5
LCBKYW51YXJ5IDA5LCAyMDE3IDg6NTQgUE0NCj4gPiA+ID4gVG86IEt3b2ssIFdpbmdNYW4NCj4g
PiA+ID4gQ2M6IEthcmljaGVyaSwgTXVyYWxpZGhhcmFuOyBuZXRkZXZAdmdlci5rZXJuZWwub3Jn
DQo+ID4gPiA+IFN1YmplY3Q6IFJlOiBNYXJ2ZWxsIFBoeSAoMTUxMCkgaXNzdWUgc2luY2UgdjQu
NyBrZXJuZWwNCj4gPiA+ID4NCj4gPiA+ID4gPiBGcm9tIE1hcnZlbGwncyBicmllZiBkZXNjcmlw
dGlvbg0KPiA+ID4gPiBodHRwOi8vd3d3Lm1hcnZlbGwuY29tL3RyYW5zY2VpdmVycy9hbGFza2Et
Z2JlLywNCj4gPiA+ID4gPiBpdCBzZWVtcyB0aGF0IDg4RTE1MTAvMTUxOCBkb24ndCBzdXBwb3J0
IGZpYmVyLiBPbmx5IDg4RTE1MTINCj4gPiBkb2VzLg0KPiA+ID4gPiBJbg0KPiA+ID4gPiA+IHRo
YXQgY2FzZSwgdGhlIGZpYmVyIHN1cHBvcnQgcGF0Y2ggaXMgbm90IGFwcGxpY2FibGUgdG8NCj4g
PiA+ID4gODhFMTUxMC8xNTE4Lg0KPiA+ID4gPg0KPiA+ID4gPiBPLksuIFRoYXQgbWFrZXMgaXQg
ZWFzaWVyLg0KPiA+ID4gPg0KPiA+ID4gPiBQbGVhc2UgYWRkIHRoZSByZWxldmFudCBJRHMgdG8g
aW5jbHVkZS9saW51eC9tYXJ2ZWxsLmgsIGFuZCBhZGQNCj4gPiA+ID4gZW50cmllcyB0byBkcml2
ZXIvbmV0L3BoeS9tYXJ2ZWxsLmMgZm9yIDE1MTIgd2l0aA0KPiBTVVBQT1JURURfRklCUkUNCj4g
PiBhbmQNCj4gPiA+ID4gMTUxMCBhbmQgMTUxOCB3aXRob3V0Lg0KPiA+ID4gPg0KPiA+ID4gPiAg
ICAgIEFuZHJldw0KPiA+ID4NCj4gPiA+IEJ5IGFueSBjaGFuY2UgeW91IGhhdmUgdGhlIElEIG9m
IDE1MTI/DQo+ID4NCj4gPiBOb3BlLCBzb3JyeS4NCj4gPg0KPiA+IFRyeSBSdXNzZWxsIEtpbmcu
DQo+ID4NCj4gPiAgICAgQW5kcmV3DQo+IA0KPiBSdXNzZWxsLA0KPiANCj4gRG8geW91IGhhdmUg
dGhlIElEIG9mIE1hcnZlbGwgUEhZIDg4RTE1MTI/DQo+IA0KPiBUaGFua3MsDQo+IFdpbmdNYW4N
Cj4gDQoNCmxvb3BpbmcgaW4gQ2hhcmxlcy1BbnRvaW5lIChhdXRob3Igb2YgcGF0Y2gNCndpdGgg
Y29tbWl0IGlkIDZjZmIzYmNjKQ0KDQpDaGFybGVzLUFudG9pbmUsDQoNCkRvIHlvdSBoYXZlIHRo
ZSBJRCBvZiBNYXJ2ZWxsIFBIWSA4OEUxNTEyPw0KDQpUaGFua3MsDQpXaW5nTWFuDQoNCg0KDQo=
