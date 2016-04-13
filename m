From: "Machani, Yaniv" <yanivma@ti.com>
Subject: RE: TCP reaching to maximum throughput after a long time
Date: Wed, 13 Apr 2016 20:26:32 +0000
Message-ID: <AE1C82FB3D0EC64DB1F752C81CBD110139106E71@DFRE01.ent.ti.com>
References: <AE1C82FB3D0EC64DB1F752C81CBD110139100057@DFRE01.ent.ti.com>
	<1460472764.6473.589.camel@edumazet-glaptop3.roam.corp.google.com>
	<570D0E94.3080006@candelatech.com>
	<AE1C82FB3D0EC64DB1F752C81CBD110139101889@DFRE01.ent.ti.com>
	<570D566B.8050302@candelatech.com>
	<1460492253.6473.596.camel@edumazet-glaptop3.roam.corp.google.com>
	<570D5944.5070100@candelatech.com>
	<1460492999.6473.599.camel@edumazet-glaptop3.roam.corp.google.com>
	<570D6B39.3050605@candelatech.com>
	<CAK6E8=f+4BagGi5BzLER=Hn2dDJ5FHWkEqLq=04tnWResk58GQ@mail.gmail.com>
	<1460518349.32504.8.camel@edumazet-glaptop3.roam.corp.google.com>
 <CADVnQy=1eZbWxLRJ3t8grazBJzQrF6LjudiX3HF3sG=sNmGq5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Yuchung Cheng <ycheng@google.com>,
	Ben Greear <greearb@candelatech.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	open list <linux-kernel@vger.kernel.org>,
	"Kama, Meirav" <meiravk@ti.com>
To: Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADVnQy=1eZbWxLRJ3t8grazBJzQrF6LjudiX3HF3sG=sNmGq5Q@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T24gV2VkLCBBcHIgMTMsIDIwMTYgYXQgMTc6MzI6MjksIE5lYWwgQ2FyZHdlbGwgd3JvdGU6DQo+
IE1pbGxlcjsgRXJpYyBEdW1hemV0OyBOYW5kaXRhIER1a2tpcGF0aTsgb3BlbiBsaXN0OyBLYW1h
LCBNZWlyYXYNCj4gU3ViamVjdDogUmU6IFRDUCByZWFjaGluZyB0byBtYXhpbXVtIHRocm91Z2hw
dXQgYWZ0ZXIgYSBsb25nIHRpbWUNCj4gDQo+IEkgbGlrZSB0aGUgaWRlYSB0byBkaXNhYmxlIGh5
c3RhcnQgYWNrLXRyYWluLg0KPiANCj4gDQo+IFlhbml2LCBjYW4geW91IHBsZWFzZSByZS1ydW4g
eW91ciB0ZXN0IHdpdGggQ1VCSUMgaW4gdGhyZWUgZGlmZmVyZW50DQo+IHNjZW5hcmlvczoNCj4g
DQo+IGEpIGVjaG8gMCA+IC9zeXMvbW9kdWxlL3RjcF9jdWJpYy9wYXJhbWV0ZXJzL2h5c3RhcnRf
ZGV0ZWN0DQpUaGlzIGZpeGVzIHRoZSBpc3N1ZXMsIGdvdCB0byBtYXggdGhyb3VnaHB1dCBpbW1l
ZGlhdGVseS4gDQoNCj4gDQo+IGIpIGVjaG8gMSA+IC9zeXMvbW9kdWxlL3RjcF9jdWJpYy9wYXJh
bWV0ZXJzL2h5c3RhcnRfZGV0ZWN0DQo+IA0KVGhpcyBzaG93cyB0aGUgc2FtZSByZXN1bHRzIGFz
IGJlZm9yZSwgc3RhcnRpbmcgbG93IGFuZCBpbmNyZWFzaW5nIHNsb3dseS4NCg0KPg0KPiBjKSBl
Y2hvIDIgPiAvc3lzL21vZHVsZS90Y3BfY3ViaWMvcGFyYW1ldGVycy9oeXN0YXJ0X2RldGVjdA0K
VGhpcyBnZXRzIHVzIGEgYml0IGhpZ2hlciBhdCB0aGUgYmVnaW5uaW5nLCBidXQgbmV2ZXIgKHdh
aXRlZCB+NjAgc2VjKSBnb2VzIHRvIHRoZSBtYXguDQoNCg0KQXBwcmVjaWF0ZSB5b3VyIGhlbHAg
b24gdGhpcy4NCllhbml2DQo+IA0KPiANCj4gVGhpcyBzaG91bGQgaGVscCB1cyBpc29sYXRlIHdo
ZXRoZXIgdGhlIGh5c3RhcnQgYWNrLXRyYWluIGFsZ29yaXRobSBpcyANCj4gY2F1c2luZyBwcm9i
bGVtcyBpbiB0aGlzIHBhcnRpY3VsYXIgY2FzZS4NCj4gDQo+IFRoYW5rcyENCj4gbmVhbA0KPiAN
Cj4gDQo+IA0KPiBPbiBUdWUsIEFwciAxMiwgMjAxNiBhdCAxMTozMiBQTSwgRXJpYyBEdW1hemV0
IA0KPiA8ZXJpYy5kdW1hemV0QGdtYWlsLmNvbT4NCj4gd3JvdGU6DQo+IA0KPiANCj4gCU9uIFR1
ZSwgMjAxNi0wNC0xMiBhdCAyMDowOCAtMDcwMCwgWXVjaHVuZyBDaGVuZyB3cm90ZToNCj4gDQo+
IAk+IGJhc2VkIG9uIHRoZSBwcmV2IHRocmVhZCBJIHByb3Bvc2Ugd2UgZGlzYWJsZSBoeXN0YXJ0
IGFjay10cmFpbi4gSXQgDQo+IGlzDQo+IAk+IGJyaXR0bGUgdW5kZXIgdmFyaW91cyBjaXJjdW1z
dGFuY2VzLiBXZSd2ZSBkaXNhYmxlZCB0aGF0IGF0IEdvb2dsZSANCj4gZm9yDQo+IAk+IHllYXJz
Lg0KPiANCj4gCVJpZ2h0LCBidXQgYmVjYXVzZSB3ZSBhbHNvIHVzZSBzY2hfZnEgcGFja2V0IHNj
aGVkdWxlciBhbmQgcGFjaW5nIDspDQo+IA0KPiANCj4gDQo+IA0KDQoNCg0K
