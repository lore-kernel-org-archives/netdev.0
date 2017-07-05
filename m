From: Chris Paterson <Chris.Paterson2@renesas.com>
Subject: RE: [PATCH v 1/2] ravb: Add support for r8a7743 SoC
Date: Wed, 5 Jul 2017 13:51:50 +0000
Message-ID: <TY1PR06MB0702B8D1C817F6C3CBD93D99B7D40@TY1PR06MB0702.apcprd06.prod.outlook.com>
References: <1499259711-56175-1-git-send-email-biju.das@bp.renesas.com>
 <1499259711-56175-2-git-send-email-biju.das@bp.renesas.com>
 <CAMuHMdVMunZ0trcNmMg4KkEd+d88foep7C0kU=yLQNk5JojosA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Biju Das <biju.das@bp.renesas.com>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdVMunZ0trcNmMg4KkEd+d88foep7C0kU=yLQNk5JojosA@mail.gmail.com>
Content-Language: en-US
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SGVsbG8gR2VlcnQsIFNlcmdlaSwNCg0KPiBGcm9tOiBnZWVydC51eXR0ZXJob2V2ZW5AZ21haWwu
Y29tDQo+IFttYWlsdG86Z2VlcnQudXl0dGVyaG9ldmVuQGdtYWlsLmNvbV0gT24gQmVoYWxmIE9m
IEdlZXJ0IFV5dHRlcmhvZXZlbg0KPiBTZW50OiAwNSBKdWx5IDIwMTcgMTQ6NDcNCj4gDQo+IEhp
IEJpanUsDQo+IA0KPiBPbiBXZWQsIEp1bCA1LCAyMDE3IGF0IDM6MDEgUE0sIEJpanUgRGFzIDxi
aWp1LmRhc0BicC5yZW5lc2FzLmNvbT4gd3JvdGU6DQo+ID4gQWRkIHN1cHBvcnQgZm9yIEdpZ2Fi
aXQgRXRoZXJuZXQgRS1NQUMgb24gcjhhNzc0MyAoUlovRzFNKSBTb0MuDQo+ID4gUmVuZXNhcyBS
Wi9HMU0gKFI4QTc3NDMpIFNvQyBFdGhlcm5ldCBBVkIgSVAgaXMgaWRlbnRpY2FsIHRvIHRoZSBS
LUNhcg0KPiA+IEdlbjIgZmFtaWx5Lg0KPiA+DQo+ID4gU2lnbmVkLW9mZi1ieTogQmlqdSBEYXMg
PGJpanUuZGFzQGJwLnJlbmVzYXMuY29tPg0KPiA+IFJldmlld2VkLWJ5OiBDaHJpcyBQYXRlcnNv
biA8Y2hyaXMucGF0ZXJzb24yQHJlbmVzYXMuY29tPg0KPiANCj4gVGhhbmtzIGZvciB5b3VyIHBh
dGNoIQ0KPiANCj4gPiAtLS0gYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9yZW5lc2FzL3JhdmJfbWFp
bi5jDQo+ID4gKysrIGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvcmVuZXNhcy9yYXZiX21haW4uYw0K
PiA+IEBAIC0xODY5LDYgKzE4NjksNyBAQCBzdGF0aWMgaW50IHJhdmJfbWRpb19yZWxlYXNlKHN0
cnVjdCByYXZiX3ByaXZhdGUNCj4gPiAqcHJpdikgIH0NCj4gPg0KPiA+ICBzdGF0aWMgY29uc3Qg
c3RydWN0IG9mX2RldmljZV9pZCByYXZiX21hdGNoX3RhYmxlW10gPSB7DQo+ID4gKyAgICAgICB7
IC5jb21wYXRpYmxlID0gInJlbmVzYXMsZXRoZXJhdmItcjhhNzc0MyIsIC5kYXRhID0gKHZvaWQN
Cj4gPiArICopUkNBUl9HRU4yIH0sDQo+ID4gICAgICAgICB7IC5jb21wYXRpYmxlID0gInJlbmVz
YXMsZXRoZXJhdmItcjhhNzc5MCIsIC5kYXRhID0gKHZvaWQNCj4gKilSQ0FSX0dFTjIgfSwNCj4g
PiAgICAgICAgIHsgLmNvbXBhdGlibGUgPSAicmVuZXNhcyxldGhlcmF2Yi1yOGE3Nzk0IiwgLmRh
dGEgPSAodm9pZA0KPiAqKVJDQVJfR0VOMiB9LA0KPiA+ICAgICAgICAgeyAuY29tcGF0aWJsZSA9
ICJyZW5lc2FzLGV0aGVyYXZiLXJjYXItZ2VuMiIsIC5kYXRhID0gKHZvaWQNCj4gPiAqKVJDQVJf
R0VOMiB9LA0KPiANCj4gQXMgU2VyZ2VpIGFscmVhZHkgbWVudGlvbmVkLCBhIGRyaXZlciB1cGRh
dGUgaXMgbm90IG5lZWRlZCBkdWUgdG8gdGhlDQo+IHByZXNlbmNlIG9mIGZhbWlseS1zcGVjaWZp
YyBjb21wYXRpYmxlIHZhbHVlcy4NCj4gUGxlYXNlIGRyb3AgdGhhdCBwYXJ0LCBhbmQgeW91IGNh
biBhZGQgbXk6DQo+IFJldmlld2VkLWJ5OiBHZWVydCBVeXR0ZXJob2V2ZW4gPGdlZXJ0K3JlbmVz
YXNAZ2xpZGVyLmJlPg0KDQpTaG91bGQgdGhlIG90aGVyIGNvbXBhdGlibGUgdmFsdWVzIChyOGE3
NzkwLCA5NCBldGMpIGJlIHJlbW92ZWQgdGhlbj8gT3IgYXJlIHRoZXkgbmVlZGVkIGZvciBiYWNr
d2FyZHMgY29tcGF0aWJpbGl0eT8NCg0KS2luZCByZWdhcmRzLCBDaHJpcw0KDQo+IA0KPiBHcntv
ZXRqZSxlZXRpbmd9cywNCj4gDQo+ICAgICAgICAgICAgICAgICAgICAgICAgIEdlZXJ0DQo+IA0K
PiAtLQ0KPiBHZWVydCBVeXR0ZXJob2V2ZW4gLS0gVGhlcmUncyBsb3RzIG9mIExpbnV4IGJleW9u
ZCBpYTMyIC0tIGdlZXJ0QGxpbnV4LQ0KPiBtNjhrLm9yZw0KPiANCj4gSW4gcGVyc29uYWwgY29u
dmVyc2F0aW9ucyB3aXRoIHRlY2huaWNhbCBwZW9wbGUsIEkgY2FsbCBteXNlbGYgYSBoYWNrZXIu
IEJ1dA0KPiB3aGVuIEknbSB0YWxraW5nIHRvIGpvdXJuYWxpc3RzIEkganVzdCBzYXkgInByb2dy
YW1tZXIiIG9yIHNvbWV0aGluZyBsaWtlIHRoYXQuDQo+ICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgLS0gTGludXMgVG9ydmFsZHMNCg==
