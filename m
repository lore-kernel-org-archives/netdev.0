From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next] mdio_bus: Remove unneeded gpiod NULL check
Date: Thu, 7 Sep 2017 21:51:11 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B1B47F@CHN-SV-EXMX02.mchp-main.com>
References: <1500325749-8382-1-git-send-email-festevam@gmail.com>
 <6f984a9c-e6d3-fd0a-6719-fa9032d43d1d@cogentembedded.com>
 <CAOMZO5ABD9iasv67ehcpTzcjU-iD9=8vQ2vM7Gwc4-v9pnUt-Q@mail.gmail.com>
 <f4cdcb4b-feac-5106-8068-e694dbd3b4e6@cogentembedded.com>
 <CAOMZO5BycGHNocULcScDczRoEvbQqjnRZTDrNAw7=+zpadSOSA@mail.gmail.com>
 <20170718133209.GB32757@lunn.ch>
 <CACRpkdYw5GWv3HRCqnWjDfctLEfzcoFdJ7ib_NVKRgw0+Y9dEg@mail.gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40B1B424@CHN-SV-EXMX02.mchp-main.com>
 <CACRpkdbK03cwzmGs=0nVeCp6NnX0-41dhEotxfDT46O4xDzagQ@mail.gmail.com>
 <81338659-4f46-0f2f-13c3-135b3ac876d7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <andrew@lunn.ch>, <festevam@gmail.com>,
        <sergei.shtylyov@cogentembedded.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <fabio.estevam@nxp.com>
To: <f.fainelli@gmail.com>, <linus.walleij@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa4.microchip.iphmx.com ([68.232.154.123]:36335 "EHLO
        esa4.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932095AbdIGVv6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 17:51:58 -0400
In-Reply-To: <81338659-4f46-0f2f-13c3-135b3ac876d7@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+Pj4gSWYgc29tZW9uZSBpcyB1c2luZyBHUElPIGRlc2NyaXB0b3JzIHdpdGggR1BJTyBkaXNh
YmxlZCwgaS5lLiBjYWxsaW5nDQo+ID4+PiBncGlvZF9nZXQoKSBhbmQgZnJpZW5kcywgdGhpcyBp
cyB2ZXJ5IGxpa2VseSB0byBiZSBhIGJ1ZywgYW5kIHdoYXQNCj4gPj4+IHRoZSBkcml2ZXIgd2Fu
dHMgdG8gZG8gaXM6DQo+ID4+Pg0KPiA+Pj4gIGRlcGVuZHMgb24gR1BJT0xJQg0KPiA+Pj4NCj4g
Pj4+IG9yDQo+ID4+Pg0KPiA+Pj4gIHNlbGVjdCBHUElPTElCDQo+ID4+Pg0KPiA+Pj4gaW4gS2Nv
bmZpZy4gVGhlIHdob2xlIG9wdGlvbmFsIHRoaW5nIGlzIG1haW5seSBhIGxlZnRvdmVyIGZyb20g
d2hlbiBpdA0KPiA+Pj4gd2FzIHBvc3NpYmxlIHRvIGhhdmUgYSBsb2NhbCBpbXBsZW1lbnRhdGlv
biBvZiB0aGUgR1BJT0xJQiBBUEkgaW4NCj4gPj4+IHNvbWUgY3VzdG9tIGhlYWRlciBmaWxlLCBu
b29uZSBzYW5lIHNob3VsZCBiZSBkb2luZyB0aGF0IGFueW1vcmUsDQo+ID4+PiBhbmQgaWYgdGhl
eSBkbywgdGhleSBjYW4gdmVyeSB3ZWxsIGZhY2UgdGhlIHdhcm5pbmdzLg0KPiA+Pj4NCj4gPj4+
IElmIHNvbWVvbmUgaXMgZmFjaW5nIGEgbG90IG9mIFdBUk5fT04oKSBtZXNzYWdlcyB0byB0aGlz
LCBpdCBpcyBhIGNsZWFyDQo+ID4+PiBpbmRpY2F0aW9uIHRoYXQgdGhleSBuZWVkIHRvIGZpeCB0
aGVpciBLY29uZmlnIGFuZCBpbiB0aGF0IGNhc2UgaXQgaXMgcHJvcGVyLg0KPiA+PiBMaW51cyAm
IEFuZHJldywNCj4gPj4NCj4gPj4gSSBrbmV3IHRoYXQgaXQgaXMgYWxyZWFkeSBpbiBEYXZpZCdz
IHB1bGxpbmcgcmVxdWVzdC4NCj4gPj4gQ29uZmlndXJpbmcgR1BJT0xJQiBpcyB0aGUgcmlnaHQg
c29sdXRpb24gIGV2ZW4gaWYgcGxhdGZvcm0gZG9lc24ndCB1c2UgaXQ/DQo+ID4NCj4gPiBJIGd1
ZXNzPw0KPiA+DQo+ID4gIlBsYXRmb3JtIGRvZXNuJ3QgdXNlIGl0IiB3aGF0IGRvZXMgdGhhdCBt
ZWFuPw0KPiA+DQo+ID4gRG9lcyBpdCBtZWFuIGl0IGRvZXMgbm90IGNhbGwgdGhlDQo+ID4gQVBJ
cyBvZiB0aGUgR1BJT0xJQiwgZG9lcyBpdCBtZWFuIGl0IGRvZXNuJ3QgaGF2ZSBhIEdQSU8gZHJp
dmVyDQo+ID4gYXQgcHJvYmUgKGJ1dCBtYXkgaGF2ZSBvbmUgYnkgaGF2aW5nIGl0IHByb2JlZCBm
cm9tIGEgbW9kdWxlKQ0KPiA+IG9yIGRvZXMgaXQgbWVhbiB0aGUgcGxhdGZvcm0gY2FuIG5ldmVy
IGhhdmUgaXQ/DQo+IA0KPiBJIHRoaW5rIGl0IG1lYW5zIENPTkZJR19HUElPTElCPW4gaW4gdGhl
IGtlcm5lbCBiZWNhdXNlIGl0J3Mgbm90IG5lZWRlZCwNCj4geWV0IHlvdSBydW4gY29kZSAobGlr
ZSBkcml2ZXJzL25ldC9waHkvbWRpb19idXMuYykgdGhhdCB1bmNvbmRpdGlvbmFsbHkNCj4gY2Fs
bHMgaW50byBHUElPTElCIGFuZCBhdHRlbXB0cyB0byBjb25maWd1cmUgYSBnaXZlbiBHUElPIGlm
IGF2YWlsYWJsZS4NClllcy4gSSdtIGZhY2luZyBpc3N1ZSBvbiBQQyB3aGljaCB3b24ndCBuZWVk
IEdQSU9MSUIgYXMgZGVmYXVsdC4NCldhcm5pbmcgbWVzc2FnZSBnb2VzIGF3YXkgd2hlbiBHUElP
TElCIGlzIGVuYWJsZWQsIGFuZCBmb3J0dW5hdGVseSwNClVidW50dSBkZWZhdWx0IGNvbmZpZyBo
YXMgaXQuDQpTbywgaXQgbWF5IG5vdCBiZSBzZWVuIGJ5IG1hbnkgdXNlcnMgd2hlbiB3aXRoIGZ1
bGwvZGVmYXVsdCBjb25maWd1cmF0aW9uLg0KDQo+IFRoaXMgdGhyZWFkIGlzIGFjdHVhbGx5IHdo
YXQgcHJvbXB0ZWQgbWUgdG8gd3JpdGUgdGhpcyBlbWFpbDoNCj4NCj4gaHR0cHM6Ly9sa21sLm9y
Zy9sa21sLzIwMTcvOS8yLzMNClRoYW5rcyBmb3IgdGhlIGxpbmsuDQoNCg0K
