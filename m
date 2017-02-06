From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH] net: phy: dp83867: Fix for automatically detected PHYs
Date: Mon, 6 Feb 2017 19:16:48 +0000
Message-ID: <1486408607.2857.9.camel@synopsys.com>
References: <20170203165237.22452-1-abrodkin@synopsys.com>
         <20170203171031.GC15900@lunn.ch> <1486143058.2853.27.camel@synopsys.com>
         <9d81d661-de8d-5854-e352-d570bbb3aa43@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "andrew@lunn.ch" <andrew@lunn.ch>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "nsekhar@ti.com" <nsekhar@ti.com>,
        "m-karicheri2@ti.com" <m-karicheri2@ti.com>,
        "linux-snps-arc@lists.infradead.org"
        <linux-snps-arc@lists.infradead.org>,
        "grygorii.strashko@ti.com" <grygorii.strashko@ti.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
To: "f.fainelli@gmail.com" <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9d81d661-de8d-5854-e352-d570bbb3aa43@gmail.com>
Content-Language: en-US
Content-ID: <70C1357BF385BB4A932FD31B20A79796@internal.synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SGkgRmxvcmlhbiwgYWxsLA0KDQpPbiBGcmksIDIwMTctMDItMDMgYXQgMTA6MzQgLTA4MDAsIEZs
b3JpYW4gRmFpbmVsbGkgd3JvdGU6DQo+IE9uIDAyLzAzLzIwMTcgMDk6MzAgQU0sIEFsZXhleSBC
cm9ka2luIHdyb3RlOg0KPiA+IA0KPiA+IEhpIEFuZHJldywNCj4gPiANCj4gPiBPbiBGcmksIDIw
MTctMDItMDMgYXQgMTg6MTAgKzAxMDAsIEFuZHJldyBMdW5uIHdyb3RlOg0KPiA+ID4gDQo+ID4g
PiBPbiBGcmksIEZlYiAwMywgMjAxNyBhdCAwNzo1MjozN1BNICswMzAwLCBBbGV4ZXkgQnJvZGtp
biB3cm90ZToNCj4gPiA+ID4gDQo+ID4gPiA+IA0KPiA+ID4gPiBDdXJyZW50IGltcGxlbW50YXRp
b24gcmV0dXJucyBFTk9ERVYgaWYgZGV2aWNlIHRyZWUgbm9kZSBmb3INCj4gPiA+ID4gcGh5IGlz
IGFic2VudC4gQnV0IGluIHJlYWxpdHkgdGhlcmUncmUgbWFueSBib2FyZHMgd2l0aCB0aGUgb25l
DQo+ID4gPiA+IGFuZCBvbmx5IFBIWSBvbiBib2FyZCBhbmQgTUFDcyB0aGF0IG1heSBmaW5kIGEg
UEhZIGJ5IHF1ZXJ5aW5nDQo+ID4gPiA+IE1ESU8gYnVzLiBPbmUgZ29vZCBleGFtcGxlIGlzIFNU
TU1BQy4NCj4gPiA+IA0KPiA+ID4gSHVtbSwgbm90IHNvIHN1cmUgYWJvdXQgdGhhdC4gVGhhdCBj
aGVjayBmb3IgYW4gT0Ygbm9kZSBoYXMgYWx3YXlzDQo+ID4gPiBiZWVuIHRoZXJlLCBzaW5jZSBk
YXkgb25lIGZvciB0aGlzIGRyaXZlci4NCj4gPiA+IA0KPiA+ID4gV2hhdCBoYXMgY2hhbmdlZCBy
ZWNlbnRseSBpcyB3aGVyZSBpdCBsb29rcyBmb3IgdGhlc2UgZGV2aWNlIHRyZWUNCj4gPiA+IHBy
b3BlcnRpZXMuIEl0IHVzZWQgdG8gd3JvbmdseSBsb29rIGluIHRoZSBNQUMgbm9kZS4gSXQgd2Fz
IGNoYW5nZWQgdG8NCj4gPiA+IGxvb2sgaW4gdGhlIFBIWSBub2RlLiBTbyB0aGlzIGlzIHByb2Jh
Ymx5IHRoZSByZWFzb24geW91IGFyZSBoYXZpbmcNCj4gPiA+IHByb2JsZW1zLg0KPiA+IA0KPiA+
IFdlbGwgd2UgZG9uJ3QgbWVudGlvbiBQSFkgbm9kZSBpbiBvdXIgZGV2aWNlIHRyZWVzIGJlY2F1
c2Ugd2l0aA0KPiA+IDEgUEhZIGNvbm5lY3RlZCB2aWEgTURJTyBidXMgdGhlcmUncyBubyBwb2lu
dCBpbiBzcGVuZGluZyBlbGVjdHJvbnMNCj4gPiBvbiBhZGRpbmcgZXh0cmEgc3R1ZmYuwqANCj4g
DQo+IFRoYXQncyBhIHRlcnJpYmxlIGp1c3RpZmljYXRpb24sIHlvdSBhcmUgcnVubmluZyBMaW51
eCBvbiBkZXZpY2VzLCBpZg0KPiB5b3UgY2FyZSBhYm91dCBlbGVjdHJvbnMgcnVuIGEgdGlueSBS
VE9TIDspDQoNCkFncmVlIDopDQoNCj4gPiANCj4gPiBXZWxsIGluIGNhc2UgaWYgZGVmYXVsdCBz
ZXR0aW5ncyB3b3JrIGZpbmUgLQ0KPiA+IHdoaWNoIHVwIHVudGlsIG5vdyB3YXMgdGhlIGNhc2Ug
Zm9yIHVzLg0KPiANCj4gWW91IHNob3VsZCByZWFsbHkgY29uc2lkZXIgbGlzdGluZyB5b3VyIEV0
aGVybmV0IFBIWSBhcyBhIGNoaWxkIG5vZGUgb2YNCj4gZHdtYWMgTURJTyBidXMgYmVjYXVzZSB0
aGF0IHdpbGwgYmUgYSBjb3JyZWN0IGFuZCBhY2N1cmF0ZQ0KPiByZXByZXNlbnRhdGlvbiBvZiB0
aGUgaGFyZHdhcmUsIGFuZCBpZiB0aGUgUEhZIGRyaXZlciBuZWVkcyBzcGVjaWZpYw0KPiBwcm9w
ZXJ0aWVzIHRvIGJlIGdpdmVuIChlLmc6IHJhbmRvbSBUWC9SWCBkZWxheXMsIGV0Yy4pIHRoYXQg
aXMgdGhlIG9ubHkNCj4gd2F5IHlvdSBjb3VsZCBjb21tdW5pY2F0ZSB0aG9zZSBwcm9wZXJseSB0
byB0aGUgUEhZIGRyaXZlci4NCg0KQWdyZWUgaGVyZSBhcyB3ZWxsLCBpbmRlZWQgSSdtIGdvaW5n
IHRvIHVwZGF0ZSBteSAuZHRzIGJlY2F1c2UNCnRoYXQgaXMgc3VwcG9zZWQgdG8gcmVmbGVjdCBy
ZWFsIEhXIGFuZCBpdCB3aWxsIGJlIHRoYXQgd2F5Lg0KDQpCdXQgc3RpbGwgSSdtIHdvbmRlcmlu
ZyBpZiB0aGF0J3MgYSBtdXN0Pw0KSW4gdGhhdCBjYXNlIHdlIG5lZWQgdG8gdXBkYXRlIGRyaXZl
cnMgZm9yIG90aGVyIFBIWXMgYW5kIHByb2JhYmx5IHN0YXJ0DQpmcm9tIHRoZSBnZW5waHkgdG8g
YWxpZ24gcmVxdWlyZW1lbnRzLg0KDQpPdGhlcndpc2UgcG9vciBndXlzIGxpa2UgbWUgd2hvIHN3
aXRjaGVkIGZyb20gb25lIFBIWSB0byBhbm90aGVyIHdpbGwNCmVuZCB1cCBmcnVzdHJhdGluZyB3
aHkgc3R1ZmYgdGhhdCB1c2VkIHRvIHdvcmsgbm8gbG9uZ2VyIHdvcmtzIDopDQoNCi1BbGV4ZXk=
