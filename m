From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next] mdio_bus: Remove unneeded gpiod NULL check
Date: Fri, 8 Sep 2017 20:03:05 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B1C988@CHN-SV-EXMX02.mchp-main.com>
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
 <9235D6609DB808459E95D78E17F2E43D40B1B47F@CHN-SV-EXMX02.mchp-main.com>
 <c960202c-02e3-3f54-7d0b-b5ece46c6a9e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <andrew@lunn.ch>, <festevam@gmail.com>,
        <sergei.shtylyov@cogentembedded.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <fabio.estevam@nxp.com>,
        <Bryan.Whitehead@microchip.com>
To: <f.fainelli@gmail.com>, <linus.walleij@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa6.microchip.iphmx.com ([216.71.154.253]:60265 "EHLO
        esa6.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756937AbdIHUDW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 16:03:22 -0400
In-Reply-To: <c960202c-02e3-3f54-7d0b-b5ece46c6a9e@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+PiBJIHRoaW5rIGl0IG1lYW5zIENPTkZJR19HUElPTElCPW4gaW4gdGhlIGtlcm5lbCBiZWNh
dXNlIGl0J3Mgbm90IG5lZWRlZCwNCj4gPj4geWV0IHlvdSBydW4gY29kZSAobGlrZSBkcml2ZXJz
L25ldC9waHkvbWRpb19idXMuYykgdGhhdCB1bmNvbmRpdGlvbmFsbHkNCj4gPj4gY2FsbHMgaW50
byBHUElPTElCIGFuZCBhdHRlbXB0cyB0byBjb25maWd1cmUgYSBnaXZlbiBHUElPIGlmIGF2YWls
YWJsZS4NCj4gPiBZZXMuIEknbSBmYWNpbmcgaXNzdWUgb24gUEMgd2hpY2ggd29uJ3QgbmVlZCBH
UElPTElCIGFzIGRlZmF1bHQuDQo+ID4gV2FybmluZyBtZXNzYWdlIGdvZXMgYXdheSB3aGVuIEdQ
SU9MSUIgaXMgZW5hYmxlZCwgYW5kIGZvcnR1bmF0ZWx5LA0KPiA+IFVidW50dSBkZWZhdWx0IGNv
bmZpZyBoYXMgaXQuDQo+ID4gU28sIGl0IG1heSBub3QgYmUgc2VlbiBieSBtYW55IHVzZXJzIHdo
ZW4gd2l0aCBmdWxsL2RlZmF1bHQgY29uZmlndXJhdGlvbi4NCj4gDQo+IFdvb2p1bmcsIEkgc3Vw
cG9zZSB5b3UgYXJlIGFsc28gZ2V0dGluZyBhIHdhcm5pbmcgZnJvbQ0KPiBncGlvZF9zZXRfdmFs
dWVfY2Fuc2xlZXAoKSBkb25lIGluIG1kaW9idXNfdW5yZWdpc3RlcigpIHJpZ2h0PyBXaXRoDQo+
IENPTkZJR19HUElPTElCPW4gZGV2bV9ncGlvZF9nZXRfb3B0aW9uYWwoKSByZXR1cm5zIE5VTEws
IHdoaWNoIHdlDQo+IGRvbid0DQo+IGNoZWNrIGFzIGFuIGVycm9yLCBvbiBwdXJwb3NlIGhvd2V2
ZXIgd2Ugc3RpbGwgY2FsbA0KPiBncGlvZF9zZXRfdmFsdWVfY2Fuc2xlZXAoKSBvbiBhIE5VTEwg
R1BJTyBkZXNjcmlwdG9yLCBzbyB0aGUgZm9sbG93aW5nDQo+IHNob3VsZCBkbzoNCj4gDQo+IGRp
ZmYgLS1naXQgYS9kcml2ZXJzL25ldC9waHkvbWRpb19idXMuYyBiL2RyaXZlcnMvbmV0L3BoeS9t
ZGlvX2J1cy5jDQo+IGluZGV4IGI2ZjlmYTY3MDE2OC4uNjdkYmI3YzI2ODQwIDEwMDY0NA0KPiAt
LS0gYS9kcml2ZXJzL25ldC9waHkvbWRpb19idXMuYw0KPiArKysgYi9kcml2ZXJzL25ldC9waHkv
bWRpb19idXMuYw0KPiBAQCAtNDI0LDcgKzQyNCw4IEBAIHZvaWQgbWRpb2J1c191bnJlZ2lzdGVy
KHN0cnVjdCBtaWlfYnVzICpidXMpDQo+ICAgICAgICAgfQ0KPiANCj4gICAgICAgICAvKiBQdXQg
UEhZcyBpbiBSRVNFVCB0byBzYXZlIHBvd2VyICovDQo+IC0gICAgICAgZ3Bpb2Rfc2V0X3ZhbHVl
X2NhbnNsZWVwKGJ1cy0+cmVzZXRfZ3Bpb2QsIDEpOw0KPiArICAgICAgIGlmICghSVNfRVJSX09S
X05VTEwoYnVzLT5yZXNldF9ncGlvZCkpDQo+ICsgICAgICAgICAgICAgICBncGlvZF9zZXRfdmFs
dWVfY2Fuc2xlZXAoYnVzLT5yZXNldF9ncGlvZCwgMSk7DQo+IA0KPiAgICAgICAgIGRldmljZV9k
ZWwoJmJ1cy0+ZGV2KTsNCj4gIH0NCkhpIEZsb3JpYW4sDQoNClRoYW5rcyBmb3IgdGhlIHBhdGNo
LiBJJ20gYXZvaWRpbmcgd2FybmluZyB3aXRoIENPTkZJR19HUElPTElCPXkgZm9yIG5vdy4NCkkn
bSBjdXJpb3VzIHRoYXQgdGhlcmUgaXMgYSBmaW5hbCBjb25jbHVzaW9uIHRvIHJlc29sdmUgdGhp
cyBpc3N1ZSwNCmVpdGhlciB3aXRoIENPTkZJR19HUElPTElCPXkgb3Igc29tZXRoaW5nIGVsc2Uu
DQoNCi0gV29vanVuZw0K
