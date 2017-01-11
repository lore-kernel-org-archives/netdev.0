From: "Kwok, WingMan" <w-kwok2@ti.com>
Subject: RE: Marvell Phy (1510) issue since v4.7 kernel
Date: Wed, 11 Jan 2017 23:09:03 +0000
Message-ID: <230CBA6E4B6B6B418E8730AC28E6FC7E15354B2B@DFLE11.ent.ti.com>
References: <587410EF.5090607@ti.com> <20170109225641.GB22820@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E153545A3@DFLE11.ent.ti.com>
 <20170109235534.GH22820@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E153545C9@DFLE11.ent.ti.com>
 <20170110015336.GA7160@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354AC2@DFLE11.ent.ti.com>
 <20170111222758.GG13033@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354AE5@DFLE11.ent.ti.com>
 <20170111225948.GH13033@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "rmk+kernel@arm.linux.org.uk" <rmk+kernel@arm.linux.org.uk>,
        "charles-antoine.couret@nexvision.fr"
        <charles-antoine.couret@nexvision.fr>,
        "Karicheri, Muralidharan" <m-karicheri2@ti.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx209.ext.ti.com ([198.47.19.16]:60587 "EHLO
        fllnx209.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759772AbdAKXKh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 18:10:37 -0500
In-Reply-To: <20170111225948.GH13033@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogQW5kcmV3IEx1bm4gW21h
aWx0bzphbmRyZXdAbHVubi5jaF0NCj4gU2VudDogV2VkbmVzZGF5LCBKYW51YXJ5IDExLCAyMDE3
IDY6MDAgUE0NCj4gVG86IEt3b2ssIFdpbmdNYW4NCj4gQ2M6IHJtaytrZXJuZWxAYXJtLmxpbnV4
Lm9yZy51azsgY2hhcmxlcy1hbnRvaW5lLmNvdXJldEBuZXh2aXNpb24uZnI7DQo+IEthcmljaGVy
aSwgTXVyYWxpZGhhcmFuOyBuZXRkZXZAdmdlci5rZXJuZWwub3JnDQo+IFN1YmplY3Q6IFJlOiBN
YXJ2ZWxsIFBoeSAoMTUxMCkgaXNzdWUgc2luY2UgdjQuNyBrZXJuZWwNCj4gDQo+ID4gbG9vcGlu
ZyBpbiBDaGFybGVzLUFudG9pbmUgKGF1dGhvciBvZiBwYXRjaA0KPiA+IHdpdGggY29tbWl0IGlk
IDZjZmIzYmNjKQ0KPiA+DQo+ID4gQ2hhcmxlcy1BbnRvaW5lLA0KPiA+DQo+ID4gRG8geW91IGhh
dmUgdGhlIElEIG9mIE1hcnZlbGwgUEhZIDg4RTE1MTI/DQo+IA0KPiBJIHN1c3BlY3QgdGhhdCBp
cyB0aGUgd3JvbmcgcXVlc3Rpb24gdG8gYXNrLg0KPiANCj4gVGhlIE1hcnZlbGwgZHJpdmVyIGlz
IGJlaW5nIGxvYWRlZCwgc28gaXQgbXVzdCBiZSB1c2luZyBvbiBvZiB0aGUgSURzDQo+IGluIHRo
ZSBkcml2ZXIuIFRoZXJlIGlzIG5vIElEIGluIHRoZSBkcml2ZXIgc3BlY2lmaWNhbGx5IGZvciB0
aGUNCj4gODhFMTUxMi4gSXQgc2VlbXMgbGlrZSB0aGUgODhFMTUxMiB1c2VzIHRoZSA4OEUxNTEw
IElELg0KPiANCj4gU28gaSB0aGluayB0aGUgY29ycmVjdCBxdWVzdGlvbiBzaG91bGQgYmUsIGhv
dyBjYW4gd2UgdGVsbCB0aGUgODhFMTUxMg0KPiBmcm9tIHRoZSA4OEUxNTEwIGlmIHRoZXkgaGF2
ZSB0aGUgc2FtZSBJRCBpbiByZWdpc3RlciAzLg0KPiANCj4gSXQgYXBwZWFycyB0aGF0IGZvciB0
aGUgODhFMTUxMiwgcGFnZSAwIGFyZSB0aGUgY29wcGVyIHJlZ2lzdGVycyBhbmQNCj4gcGFnZSAx
IGlzIHRoZSBmaWJyZSByZWdpc3RlcnMuIE1heWJlIHRoZSA4OEUxNTEyIGhhcyBhbiBJRCBpbiBw
YWdlIDENCj4gcmVnaXN0ZXIgMz8gTWF5YmUgdGhlIDg4RTE1MTAgZG9lcyBub3QgaGF2ZSBhbiBJ
RCBpbiBwYWdlIDEgcmVnaXN0ZXINCj4gMz8NCj4gDQo+IAlBbmRyZXcNCg0KQW5kcmV3LA0KDQpX
b3VsZCBDaGFybGVzLUFudG9pbmUgYmUgdGhlIGJldHRlciBwZXJzb24gdG8gc3VibWl0IGEgcGF0
Y2gNCnRvIGZpeCB0aGUgb3JpZ2luYWwgcHJvYmxlbSB0aGVuLCBzaW5jZSBoZSB0ZXN0ZWQgdGhl
IG9yaWdpbmFsDQpmaWJlciBzdXBwb3J0IHBhdGNoIHdpdGggMTUxMj8gSSB1bmZvcnR1bmF0ZWx5
IGRvbid0IGhhdmUgdGhlDQpkYXRhc2hlZXQgZm9yIDE1MTIsIGFuZCBpdCBkb2VzIG5vdCBzZWVt
IHRvIGJlIGF2YWlsYWJsZSBwdWJsaWNseS4NCg0KUmVnYXJkcywNCldpbmdNYW4NCg0K
