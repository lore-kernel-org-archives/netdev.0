From: "Machani, Yaniv" <yanivma-l0cyMroinI0@public.gmane.org>
Subject: RE: [PATCH 1/4] mac80211: mesh: flush stations before beacons are
 stopped
Date: Wed, 13 Jul 2016 10:11:25 +0000
Message-ID: <AE1C82FB3D0EC64DB1F752C81CBD1101391FC38C@DFRE01.ent.ti.com>
References: <20160628111307.8784-1-yanivma@ti.com>
	 <20160628111307.8784-2-yanivma@ti.com>
	 (sfid-20160628_131058_738638_5F9A964D)
 <1467184459.2461.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Hahn, Maital" <maitalm-l0cyMroinI0@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1467184459.2461.1.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

T24gV2VkLCBKdW4gMjksIDIwMTYgYXQgMTA6MTQ6MTksIEpvaGFubmVzIEJlcmcgd3JvdGU6DQo+
IENjOiBIYWhuLCBNYWl0YWwNCj4gU3ViamVjdDogUmU6IFtQQVRDSCAxLzRdIG1hYzgwMjExOiBt
ZXNoOiBmbHVzaCBzdGF0aW9ucyBiZWZvcmUgYmVhY29ucyANCj4gYXJlIHN0b3BwZWQNCj4gDQo+
IE9uIFR1ZSwgMjAxNi0wNi0yOCBhdCAxNDoxMyArMDMwMCwgWWFuaXYgTWFjaGFuaSB3cm90ZToN
Cj4gPiBGcm9tOiBNYWl0YWwgSGFobiA8bWFpdGFsbUB0aS5jb20+DQo+ID4NCj4gPiBTb21lIGRy
aXZlcnMgKGUuZy4gd2wxOHh4KSBleHBlY3QgdGhhdCB0aGUgbGFzdCBzdGFnZSBpbiB0aGUgDQo+
ID4gZGUtaW5pdGlhbGl6YXRpb24gcHJvY2VzcyB3aWxsIGJlIHN0b3BwaW5nIHRoZSBiZWFjb25z
LCBzaW1pbGFyIHRvIGFwLg0KPiA+IFVwZGF0ZSBpZWVlODAyMTFfc3RvcF9tZXNoKCkgZmxvdyBh
Y2NvcmRpbmdseS4NCj4gPg0KPiBIb3cgd2VsbCBoYXZlIHlvdSB0ZXN0ZWQgdGhhdCB3aXRoIG90
aGVyIGRyaXZlcnM/DQo+IA0KDQpTb3JyeSBmb3IgdGhlIGRlbGF5ZWQgcmVzcG9uc2UgKEkndmUg
YmVlbiBvdXQpIGFuZCB0aGFua3MgZm9yIHlvdXIgY29tbWVudHMsDQpJIGhhdmUgdGVzdGVkIGl0
IHdpdGggUlQzNTcyIGFzIHdlbGwsIGFuZCBkaWRuJ3Qgc2VlIGFueSBpc3N1ZS4NCkknbGwgdXBk
YXRlIHRoZSBjb21tZW50IHRvIHJlZmxlY3QgdGhhdC4NCg0KVGhhbmtzLA0KWWFuaXYNCg0KPiBD
aGFuZ2luZyBiZWhhdmlvdXIgdG8gc29tZXRoaW5nIGEgc2luZ2xlIGRyaXZlciBkZXNpcmVzIGlz
bid0IA0KPiBuZWNlc3NhcmlseSB0aGUgYmVzdCB0aGluZyB0byBkbywgc2luY2UgdGhlcmUgYWx3
YXlzIGFyZSBtdWx0aXBsZSBkcml2ZXJzLg0KPiANCj4gSWYgeW91J3JlIGFibGUgdG8gZGVtb25z
dHJhdGUgdGhhdCBpdCB3b3JrcyB3aXRoIHRoZSBvdGhlciBkcml2ZXJzIEknbSANCj4gd2lsbGlu
ZyB0byB0YWtlIHRoYXQgLSB0aGUgY2hhbmdlIG1ha2VzIHNlbnNlIGFmdGVyIGFsbCwgYW5kIGl0
IHNlZW1zIA0KPiBkcml2ZXJzIG11c3Qgc3VwcG9ydCB0aGlzIG9yZGVyaW5nIHNpbmNlIHBlZXJz
IGFyZSBhbHNvIHJlbW92ZWQgDQo+IGR5bmFtaWNhbGx5Li4uIEJ1dCBzdGlsbC4gRG9uJ3QganVz
dCBtYWtlIGEgY2hhbmdlIGxpa2UgdGhhdCB3aXRob3V0IA0KPiBldmVuIGdpdmluZyBhbnkgaW5k
aWNhdGlvbiB3aHkgeW91IHRoaW5rIGl0J3MgZmluZSBmb3Igb3RoZXIgZHJpdmVycyENCj4gDQo+
IGpvaGFubmVzDQoNCg0K
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
