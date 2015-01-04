From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH net-next v1 0/3] net: fec: add Wake-on-LAN support
Date: Sun, 4 Jan 2015 01:39:02 +0000
Message-ID: <BLUPR03MB373A9BBB32CE2D96D0B91AEF55B0@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1419413441-3406-1-git-send-email-b38611@freescale.com>
	<20141231.130727.1660985956287926494.davem@davemloft.net>
	<CAOMZO5BFbL-J2gM_T0jD3N3P9wHguaNLENE24BRaMQT7E6Lhiw@mail.gmail.com>
	<20141231.142034.494966377580113808.davem@davemloft.net>
 <CAOMZO5De+v_LAOdxGR=OHV3iMXwe8O-Z1dK0uv8ezMU90sMnMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Shawn Guo <shawn.guo@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"Stephen Hemminger" <stephen@networkplumber.org>
To: Fabio Estevam <festevam@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0121.outbound.protection.outlook.com ([207.46.100.121]:39552
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751478AbbADBjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jan 2015 20:39:07 -0500
In-Reply-To: <CAOMZO5De+v_LAOdxGR=OHV3iMXwe8O-Z1dK0uv8ezMU90sMnMA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRmFiaW8gRXN0ZXZhbSA8ZmVzdGV2YW1AZ21haWwuY29tPiBTZW50OiBUaHVyc2RheSwg
SmFudWFyeSAwMSwgMjAxNSAzOjIyIEFNDQo+IFRvOiBEYXZpZCBNaWxsZXINCj4gQ2M6IER1YW4g
RnVnYW5nLUIzODYxMTsgU2hhd24gR3VvOyBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyBCZW4gSHV0
Y2hpbmdzOw0KPiBTdGVwaGVuIEhlbW1pbmdlcg0KPiBTdWJqZWN0OiBSZTogW1BBVENIIG5ldC1u
ZXh0IHYxIDAvM10gbmV0OiBmZWM6IGFkZCBXYWtlLW9uLUxBTiBzdXBwb3J0DQo+IA0KPiBPbiBX
ZWQsIERlYyAzMSwgMjAxNCBhdCA1OjIwIFBNLCBEYXZpZCBNaWxsZXIgPGRhdmVtQGRhdmVtbG9m
dC5uZXQ+IHdyb3RlOg0KPiA+IEZyb206IEZhYmlvIEVzdGV2YW0gPGZlc3RldmFtQGdtYWlsLmNv
bT4NCj4gPiBEYXRlOiBXZWQsIDMxIERlYyAyMDE0IDE3OjAzOjI4IC0wMjAwDQo+ID4NCj4gPj4g
LGJ1dCB3aGVuIHdlIHNlZSB5b3VyIHBhdGNoZXMgYXBwbGllZCB0aGV5IGFwcGVhciB3aXRoIE5p
bXJvZCBBbmR5IGFzDQo+ID4+IHRoZSBhdXRob3IgaW5zdGVhZDoNCj4gPj4gaHR0cHM6Ly9naXQu
a2VybmVsLm9yZy9jZ2l0L2xpbnV4L2tlcm5lbC9naXQvZGF2ZW0vbmV0LW5leHQuZ2l0L2NvbW1p
DQo+ID4+IHQvP2lkPWRlNDBlZDMxYjNjNTc3Y2VmZDdiNTQ5NzIzNjVhMjcyZWNiZTlkZDYNCj4g
Pj4NCj4gPj4gSXQgd291bGQgYmUgbmljZSBpZiB5b3UgY291bGQgdXNlIHRoZSBGcm9tIGZpZWxk
IHRvIG1hdGNoIHRoZSBuYW1lIGluDQo+ID4+IHRoZSBTaWduZWQtb2ZmIHRhZy4NCj4gPg0KPiA+
IEl0J3MgaGlzIGJ1c2luZXNzIHRvIHNldHVwIHRoaW5ncyBwcm9wZXJseSBzbyB0aGV5IG1hdGNo
LCBub3QgbWluZS4gIEkNCj4gPiBqdXN0IHRha2Ugd2hhdCBpcyBpbiB0aGUgcGF0Y2ggYXMtaXMu
DQo+IA0KPiBFeGFjdGx5LiBUaGlzIHdhcyB3aGF0IEkgc3VnZ2VzdGVkIGhpbSB0byBkby4NCg0K
VGhhbmtzIGZvciB5b3VyIHN1Z2dlc3Rpb24uDQpJIGhhdmUgdGhlc2UgdHdvIEVuZ2xpc2ggbmFt
ZS4gU29ycnkgSSB3aWxsIHN5bmMgb25lIG5hbWUgaW4gbGF0ZXIgcGF0Y2guDQoNClJlZ2FyZHMs
DQpBbmR5DQo=
