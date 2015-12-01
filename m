From: Duan Andy <fugang.duan@freescale.com>
Subject: RE: [PATCH 0/3] net: fec: Reset ethernet PHY whenever the enet_out
 clock
Date: Tue, 1 Dec 2015 01:52:35 +0000
Message-ID: <BN3PR0301MB1219D0A7525EB2535856BE52F50F0@BN3PR0301MB1219.namprd03.prod.outlook.com>
References: <1448883168-30742-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: =?utf-8?B?TG90aGFyIFdhw59tYW5u?= <LW@KARO-electronics.de>,
	Andrew Lunn <andrew@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <Fabio.Estevam@freescale.com>,
	Greg Ungerer <gerg@uclinux.org>,
	Kevin Hao <haokexin@gmail.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Philippe Reynes <tremyfr@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	"Stefan Agner" <stefan@agner.ch>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Uwe Kleine-K?nig" <u.kleine-koenig@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448883168-30742-1-git-send-email-LW@KARO-electronics.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogTG90aGFyIFdhw59tYW5uIDxMV0BLQVJPLWVsZWN0cm9uaWNzLmRlPiBTZW50OiBNb25k
YXksIE5vdmVtYmVyIDMwLCAyMDE1IDc6MzMgUE0NCj4gVG86IEFuZHJldyBMdW5uOyBEYXZpZCBT
LiBNaWxsZXI7IEVzdGV2YW0gRmFiaW8tUjQ5NDk2OyBHcmVnIFVuZ2VyZXI7DQo+IEtldmluIEhh
bzsgTG90aGFyIFdhw59tYW5uOyBMdWNhcyBTdGFjaDsgRHVhbiBGdWdhbmctQjM4NjExOyBQaGls
aXBwZQ0KPiBSZXluZXM7IFJpY2hhcmQgQ29jaHJhbjsgUnVzc2VsbCBLaW5nOyBTYXNjaGEgSGF1
ZXI7IFN0ZWZhbiBBZ25lcjsgbGludXgtDQo+IGtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc7IG5ldGRl
dkB2Z2VyLmtlcm5lbC5vcmc7IEplZmYgS2lyc2hlcjsgVXdlIEtsZWluZS0NCj4gS8O2bmlnDQo+
IFN1YmplY3Q6IFtQQVRDSCAwLzNdIG5ldDogZmVjOiBSZXNldCBldGhlcm5ldCBQSFkgd2hlbmV2
ZXIgdGhlIGVuZXRfb3V0DQo+IGNsb2NrDQo+IA0KPiBUaGlzIHBhdGNoc2V0IGZpeGVzIGEgcmVn
cmVzc2lvbiBpbnRyb2R1Y2VkIGJ5IGNvbW1pdCA4ZmZmNzU1ZTlmOGQgKCJuZXQ6DQo+IGZlYzog
RW5zdXJlIGNsb2NrcyBhcmUgZW5hYmxlZCB3aGlsZSB1c2luZyBtZGlvIGJ1cyIpIGZvciBldGhl
cm5ldCBQSFlzDQo+IHRoYXQgYXJlIHVzaW5nIEVORVRfT1VUIGFzIHJlZmVyZW5jZSBjbG9jayAo
b24gaS5NWDYgb3IgaS5NWDI4KQ0KPiANCkRvIHlvdSBtZWFuIGNvbW1pdCA4ZmZmNzU1ZTlmOGQg
Y2F1c2UgeW91ciBwcm9ibGVtID8gIFRoaXMgY29tbWl0IGp1c3QgbWFuYWdlIGlwZyBjbG9jayBp
biBydW50aW1lIGJlY2F1c2UgbWRpbyBidXMgY2FuIGFjY2VzcyBleHRlcm5hbCBwaHkgc3dpdGNo
IG5vIG1hdHRlciBuZXRkZXYgc3RhdHVzLg0KDQpJIGRvbid0IHRoaW5rIHRoZSBjb21taXQgY2F1
c2UgcGh5IGxpbmsgdXAvZG93biBpc3N1ZS4gIFBoeSBsaW5rIHVwL2Rvd24gaXMgZHVlIHRvIHBo
eSBpcyBub3QgcmVhZHkgYWZ0ZXIgcG93ZXIvY2xvY2sgb24sIGl0IG5lZWQgdG8gZG8gcmVzZXQu
DQoNCg0KPiBUaGUgZmlyc3QgcGF0Y2ggaXMgYSBjbGVhbnVwIHBhdGNoIHRoYXQgcmVtb3ZlcyBy
ZWR1bmRhbnQgTlVMTCBjaGVja3MuDQo+IFRoZSBzZWNvbmQgcGF0Y2ggY29udmVydHMgdGhlIGRy
aXZlciB0byB1c2UgdGhlICdncGlvZCcgZnJhbWV3b3JrLg0KPiBUaGUgdGhpcmQgcGF0Y2ggbWFr
ZXMgc3VyZSwgZmVjX3Jlc2V0X3BoeSgpIGlzIGNhbGxlZCB3aGVuZXZlciB0aGUNCj4gICAgIGVu
ZXRfb3V0IGNsb2NrIGhhcyBiZWVuIChyZS0pZW5hYmxlZCB0byBnZXQgdGhlIFBIWSBpbnRvIGEN
Cj4gICAgIGNvbnNpc3RlbnQgc3RhdGUuDQo=
