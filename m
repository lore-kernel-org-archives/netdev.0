From: Duan Andy <fugang.duan@freescale.com>
Subject: RE: [PATCH 0/3] net: fec: Reset ethernet PHY whenever the enet_out
 clock
Date: Tue, 1 Dec 2015 07:33:04 +0000
Message-ID: <BN3PR0301MB12197562445A211CC7F15ADBF50F0@BN3PR0301MB1219.namprd03.prod.outlook.com>
References: <1448883168-30742-1-git-send-email-LW@KARO-electronics.de>
	<BN3PR0301MB1219D0A7525EB2535856BE52F50F0@BN3PR0301MB1219.namprd03.prod.outlook.com>
 <20151201082450.6a4a9421@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Andrew Lunn <andrew@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <Fabio.Estevam@freescale.com>,
	Greg Ungerer <gerg@uclinux.org>,
	Kevin Hao <haokexin@gmail.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Philippe Reynes <tremyfr@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Stefan Agner <stefan@agner.ch>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Uwe Kleine-K?nig <u.kleine-koenig@pengutronix.de>
To: =?utf-8?B?TG90aGFyIFdhw59tYW5u?= <LW@KARO-electronics.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151201082450.6a4a9421@ipc1.ka-ro>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogTG90aGFyIFdhw59tYW5uIDxMV0BLQVJPLWVsZWN0cm9uaWNzLmRlPiBTZW50OiBUdWVz
ZGF5LCBEZWNlbWJlciAwMSwgMjAxNSAzOjI1IFBNDQo+IFRvOiBEdWFuIEZ1Z2FuZy1CMzg2MTEN
Cj4gQ2M6IEFuZHJldyBMdW5uOyBEYXZpZCBTLiBNaWxsZXI7IEVzdGV2YW0gRmFiaW8tUjQ5NDk2
OyBHcmVnIFVuZ2VyZXI7DQo+IEtldmluIEhhbzsgTHVjYXMgU3RhY2g7IFBoaWxpcHBlIFJleW5l
czsgUmljaGFyZCBDb2NocmFuOyBSdXNzZWxsIEtpbmc7DQo+IFNhc2NoYSBIYXVlcjsgU3RlZmFu
IEFnbmVyOyBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnOw0KPiBuZXRkZXZAdmdlci5rZXJu
ZWwub3JnOyBKZWZmIEtpcnNoZXI7IFV3ZSBLbGVpbmUtSz9uaWcNCj4gU3ViamVjdDogUmU6IFtQ
QVRDSCAwLzNdIG5ldDogZmVjOiBSZXNldCBldGhlcm5ldCBQSFkgd2hlbmV2ZXIgdGhlDQo+IGVu
ZXRfb3V0IGNsb2NrDQo+IA0KPiBIaSwNCj4gDQo+ID4gRnJvbTogTG90aGFyIFdhw59tYW5uIDxM
V0BLQVJPLWVsZWN0cm9uaWNzLmRlPiBTZW50OiBNb25kYXksIE5vdmVtYmVyDQo+ID4gMzAsIDIw
MTUgNzozMyBQTQ0KPiA+ID4gVG86IEFuZHJldyBMdW5uOyBEYXZpZCBTLiBNaWxsZXI7IEVzdGV2
YW0gRmFiaW8tUjQ5NDk2OyBHcmVnDQo+ID4gPiBVbmdlcmVyOyBLZXZpbiBIYW87IExvdGhhciBX
YcOfbWFubjsgTHVjYXMgU3RhY2g7IER1YW4gRnVnYW5nLUIzODYxMTsNCj4gPiA+IFBoaWxpcHBl
IFJleW5lczsgUmljaGFyZCBDb2NocmFuOyBSdXNzZWxsIEtpbmc7IFNhc2NoYSBIYXVlcjsgU3Rl
ZmFuDQo+ID4gPiBBZ25lcjsgbGludXgtIGtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc7IG5ldGRldkB2
Z2VyLmtlcm5lbC5vcmc7IEplZmYNCj4gPiA+IEtpcnNoZXI7IFV3ZSBLbGVpbmUtIEvDtm5pZw0K
PiA+ID4gU3ViamVjdDogW1BBVENIIDAvM10gbmV0OiBmZWM6IFJlc2V0IGV0aGVybmV0IFBIWSB3
aGVuZXZlciB0aGUNCj4gPiA+IGVuZXRfb3V0IGNsb2NrDQo+ID4gPg0KPiA+ID4gVGhpcyBwYXRj
aHNldCBmaXhlcyBhIHJlZ3Jlc3Npb24gaW50cm9kdWNlZCBieSBjb21taXQgOGZmZjc1NWU5Zjhk
DQo+ICgibmV0Og0KPiA+ID4gZmVjOiBFbnN1cmUgY2xvY2tzIGFyZSBlbmFibGVkIHdoaWxlIHVz
aW5nIG1kaW8gYnVzIikgZm9yIGV0aGVybmV0DQo+ID4gPiBQSFlzIHRoYXQgYXJlIHVzaW5nIEVO
RVRfT1VUIGFzIHJlZmVyZW5jZSBjbG9jayAob24gaS5NWDYgb3IgaS5NWDI4KQ0KPiA+ID4NCj4g
PiBEbyB5b3UgbWVhbiBjb21taXQgOGZmZjc1NWU5ZjhkIGNhdXNlIHlvdXIgcHJvYmxlbSA/ICBU
aGlzIGNvbW1pdCBqdXN0DQo+IG1hbmFnZSBpcGcgY2xvY2sgaW4gcnVudGltZSBiZWNhdXNlIG1k
aW8gYnVzIGNhbiBhY2Nlc3MgZXh0ZXJuYWwgcGh5DQo+IHN3aXRjaCBubyBtYXR0ZXIgbmV0ZGV2
IHN0YXR1cy4NCj4gPg0KPiBOby4gQWN0dWFsbHkgSSBtZWFudCBjb21taXQgZThmY2ZjZDU2ODRh
ICgibmV0OiBmZWM6IG9wdGltaXplIHRoZSBjbG9jaw0KPiBtYW5hZ2VtZW50IHRvIHNhdmUgcG93
ZXIiKSB3aGljaCBzdGFydGVkIHRvIGRpc2FibGUgdGhlIGNsb2NrcyB3aGVuIG5vdA0KPiBpbiB1
c2UuDQo+IA0KVW5kZXJzdGFuZC4gWWVzLCBkaXNhYmxlIGVuZXRfb3V0IGNsb2NrIGZvciBwb3dl
ciBzYXZpbmcgaXMgbmVjZXNzYXJ5Lg0KDQo+IFNvcnJ5IGZvciB0aGUgY29uZnVzaW9uLA0KPiBM
b3RoYXIgV2HDn21hbm4NCg==
