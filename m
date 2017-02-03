From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH] net: phy: dp83867: Fix for automatically detected PHYs
Date: Fri, 3 Feb 2017 17:30:59 +0000
Message-ID: <1486143058.2853.27.camel@synopsys.com>
References: <20170203165237.22452-1-abrodkin@synopsys.com>
         <20170203171031.GC15900@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "nsekhar@ti.com" <nsekhar@ti.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "m-karicheri2@ti.com" <m-karicheri2@ti.com>,
        "linux-snps-arc@lists.infradead.org"
        <linux-snps-arc@lists.infradead.org>,
        "grygorii.strashko@ti.com" <grygorii.strashko@ti.com>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
To: "andrew@lunn.ch" <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170203171031.GC15900@lunn.ch>
Content-Language: en-US
Content-ID: <4FB9D816B5F6604D8607DB8E26B42005@internal.synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SGkgQW5kcmV3LA0KDQpPbiBGcmksIDIwMTctMDItMDMgYXQgMTg6MTAgKzAxMDAsIEFuZHJldyBM
dW5uIHdyb3RlOg0KPiBPbiBGcmksIEZlYiAwMywgMjAxNyBhdCAwNzo1MjozN1BNICswMzAwLCBB
bGV4ZXkgQnJvZGtpbiB3cm90ZToNCj4gPiANCj4gPiBDdXJyZW50IGltcGxlbW50YXRpb24gcmV0
dXJucyBFTk9ERVYgaWYgZGV2aWNlIHRyZWUgbm9kZSBmb3INCj4gPiBwaHkgaXMgYWJzZW50LiBC
dXQgaW4gcmVhbGl0eSB0aGVyZSdyZSBtYW55IGJvYXJkcyB3aXRoIHRoZSBvbmUNCj4gPiBhbmQg
b25seSBQSFkgb24gYm9hcmQgYW5kIE1BQ3MgdGhhdCBtYXkgZmluZCBhIFBIWSBieSBxdWVyeWlu
Zw0KPiA+IE1ESU8gYnVzLiBPbmUgZ29vZCBleGFtcGxlIGlzIFNUTU1BQy4NCj4gDQo+IEh1bW0s
IG5vdCBzbyBzdXJlIGFib3V0IHRoYXQuIFRoYXQgY2hlY2sgZm9yIGFuIE9GIG5vZGUgaGFzIGFs
d2F5cw0KPiBiZWVuIHRoZXJlLCBzaW5jZSBkYXkgb25lIGZvciB0aGlzIGRyaXZlci4NCj4gDQo+
IFdoYXQgaGFzIGNoYW5nZWQgcmVjZW50bHkgaXMgd2hlcmUgaXQgbG9va3MgZm9yIHRoZXNlIGRl
dmljZSB0cmVlDQo+IHByb3BlcnRpZXMuIEl0IHVzZWQgdG8gd3JvbmdseSBsb29rIGluIHRoZSBN
QUMgbm9kZS4gSXQgd2FzIGNoYW5nZWQgdG8NCj4gbG9vayBpbiB0aGUgUEhZIG5vZGUuIFNvIHRo
aXMgaXMgcHJvYmFibHkgdGhlIHJlYXNvbiB5b3UgYXJlIGhhdmluZw0KPiBwcm9ibGVtcy4NCg0K
V2VsbCB3ZSBkb24ndCBtZW50aW9uIFBIWSBub2RlIGluIG91ciBkZXZpY2UgdHJlZXMgYmVjYXVz
ZSB3aXRoDQoxIFBIWSBjb25uZWN0ZWQgdmlhIE1ESU8gYnVzIHRoZXJlJ3Mgbm8gcG9pbnQgaW4g
c3BlbmRpbmcgZWxlY3Ryb25zDQpvbiBhZGRpbmcgZXh0cmEgc3R1ZmYuIFdlbGwgaW4gY2FzZSBp
ZiBkZWZhdWx0IHNldHRpbmdzIHdvcmsgZmluZSAtDQp3aGljaCB1cCB1bnRpbCBub3cgd2FzIHRo
ZSBjYXNlIGZvciB1cy4NCg0KSnVzdCBpbiBjYXNlIHRoYXQncyBhIHR5cGljYWwgZXhhbXBsZToN
Cmh0dHA6Ly9naXQua2VybmVsLm9yZy9jZ2l0L2xpbnV4L2tlcm5lbC9naXQvdG9ydmFsZHMvbGlu
dXguZ2l0L3RyZWUvYXJjaC9hcmMvYm9vdC9kdHMvYXhzMTB4X21iLmR0c2kjbjU4DQoNCi0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tPjgtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KCWV0aGVybmV0QDB4
MTgwMDAgew0KCQkjaW50ZXJydXB0LWNlbGxzID0gPDE+Ow0KCQljb21wYXRpYmxlID0gInNucHMs
ZHdtYWMiOw0KCQlyZWcgPSA8IDB4MTgwMDAgMHgyMDAwID47DQoJCWludGVycnVwdHMgPSA8IDQg
PjsNCgkJaW50ZXJydXB0LW5hbWVzID0gIm1hY2lycSI7DQoJCXBoeS1tb2RlID0gInJnbWlpIjsN
CgkJc25wcyxwYmwgPSA8IDMyID47DQoJCWNsb2NrcyA9IDwmYXBiY2xrPjsNCgkJY2xvY2stbmFt
ZXMgPSAic3RtbWFjZXRoIjsNCgkJbWF4LXNwZWVkID0gPDEwMD47DQoJfTsNCi0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tPjgtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KDQpUaGlzIGlzIGVzcGVjaWFs
bHkgbmljZSBiZWNhdXNlIHdlIG1heSBjaGFuZ2UgdGhlIGJhc2UtYm9hcmQgYW5kIHVzZQ0KdGhl
cmUgYW5vdGhlciBQSFkgYW5kIGFzIGxvbmcgd2UgaGF2ZSBkcml2ZXJzIGZvciBhbGwgcG9zc2li
bGUgUEhZIGJ1aWx0DQppbiB0aGUga2VybmVsIChvciBhdmFpbGFibGUgdmlhIG1vZHVsZXMpIHBy
b3BlciBkcml2ZXIgd2lsbCBiZSBpbnN0YW50aWF0ZWQNCmJhc2VkIG9uIFBIWSBJRCByZWFkIGZy
b20gTURJTy4gSS5lLiBoYXZpbmcgbm8gUEhZIG5vZGUgaW4gRFQgYWRkcyBmbGV4aWJpbGl0eS4N
Cg0KLUFsZXhleQ==
