From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH v2 net-next 1/2] net: dsa: lan9303: Move tag setup to
 new lan9303_setup_tagging
Date: Wed, 11 Oct 2017 14:01:57 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B4A47B@CHN-SV-EXMX02.mchp-main.com>
References: <20171010124953.386-1-privat@egil-hjelmeland.no>
 <20171010124953.386-2-privat@egil-hjelmeland.no>
 <9235D6609DB808459E95D78E17F2E43D40B48C3D@CHN-SV-EXMX02.mchp-main.com>
 <2d03fb99-fd1c-9a0b-3274-eda605c3eb2d@egil-hjelmeland.no>
 <9235D6609DB808459E95D78E17F2E43D40B48CC6@CHN-SV-EXMX02.mchp-main.com>
 <20f8c457-0f61-641e-a12a-7c0bcf2fba21@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: <privat@egil-hjelmeland.no>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20f8c457-0f61-641e-a12a-7c0bcf2fba21@egil-hjelmeland.no>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiA+Pj4+IEBAIC02NDQsNiArNjQ4LDEwIEBAIHN0YXRpYyBpbnQgbGFuOTMwM19zZXR1cChzdHJ1
Y3QgZHNhX3N3aXRjaCAqZHMpDQo+ID4+Pj4gICAgCQlyZXR1cm4gLUVJTlZBTDsNCj4gPj4+PiAg
ICAJfQ0KPiA+Pj4+DQo+ID4+Pj4gKwlyZXQgPSBsYW45MzAzX3NldHVwX3RhZ2dpbmcoY2hpcCk7
DQo+ID4+Pj4gKwlpZiAocmV0KQ0KPiA+Pj4+ICsJCWRldl9lcnIoY2hpcC0+ZGV2LCAiZmFpbGVk
IHRvIHNldHVwIHBvcnQgdGFnZ2luZyAlZFxuIiwgcmV0KTsNCj4gPj4+PiArDQo+ID4+PiBTdGls
bCBtb3ZlIG9uIHdoZW4gZXJyb3IgaGFwcGVucz8NCj4gPj4+DQo+ID4+IEdvb2QgcXVlc3Rpb24u
IEkganVzdCBmb2xsb3dlZCB0aGUgcGF0dGVybiBmcm9tIHRoZSBvcmlnaW5hbCBmdW5jdGlvbiwN
Cj4gPj4gd2hpY2ggd2FzIG5vdCBtYWRlIGJ5IG1lLiBBY3R1YWxseSBJIGRpZCBvbmNlIHJlZmxl
Y3Qgb24gd2hldGhlciB0aGlzDQo+ID4+IHdhcyB0aGUgY29ycmVjdCB3YXkuIFBlcmhhcHMgaXQg
Y291bGQgYmUgYXJndWVkIHRoYXQgaXQgaXMgYmV0dGVyIHRvDQo+ID4+IGFsbG93IHRoZSBkZXZp
Y2UgdG8gY29tZSB1cCwgc28gdGhlIHByb2JsZW0gY2FuIGJlIGludmVzdGlnYXRlZD8NCj4gPiBN
YXliZSBkZXBlbmRzIG9uIHNldmVyaXR5IG9mIHNldHRpbmc/DQo+ID4gQlRXLCBsYW45MzAzX3Nl
dHVwKCkgc3RpbGwgcmV0dXJucyBaRVJPIGF0IHRoZSBlbmQ/DQo+IEkgZGlkIHF1aWNrIHN1cnZl
eSBvZiB0aGUgX3NldHVwIGZ1bmN0aW9ucyBvZiB0aGUgb3RoZXIgZHNhIGRyaXZlcnMuDQo+IFNv
bWUgcmV0dXJuIG9uIGVycm9yLCBzb21lIGlnbm9yZSBlcnJvcnMuDQo+IElmIHlvdSB0aGluayBz
bywgSSBjYW4gbWFrZSBhIHYzIHNlcmllcyB0aGF0IHJldHVybiBvbiBlcnJvci4gT3RoZXJ3aXNl
DQo+IEkgbGVhdmUgaXQgYXMgaXQgaXMuDQoNClVubGVzcyBBbmRyZXcsIFZpdmllbiBvciBGbG9y
aWFuIHJhaXNlcyBmbGFnLCBJIGd1ZXNzIGl0IHdpbGwgYmUgZmluZSBhcy1pcy4NCg0KVGhhbmtz
Lg0KV29vanVuZw0K
