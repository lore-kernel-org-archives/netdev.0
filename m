From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH] lan78xx: Protect runtime_auto check by #ifdef CONFIG_PM
Date: Mon, 21 Mar 2016 14:59:38 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D404CBFF1@CHN-SV-EXMX02.mchp-main.com>
References: <1458470636-18986-1-git-send-email-geert@linux-m68k.org>
 <56EF2B44.9040807@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <rjw@rjwysocki.net>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <linux-pm@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <linux@roeck-us.net>, <geert@linux-m68k.org>,
	<UNGLinuxDriver@microchip.com>, <davem@davemloft.net>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <56EF2B44.9040807@roeck-us.net>
Content-Language: en-US
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBHdWVudGVyIFJvZWNrIFttYWls
dG86bGludXhAcm9lY2stdXMubmV0XQ0KPiBTZW50OiBTdW5kYXksIE1hcmNoIDIwLCAyMDE2IDY6
NTkgUE0NCj4gVG86IEdlZXJ0IFV5dHRlcmhvZXZlbjsgV29vanVuZyBIdWggLSBDMjE2OTk7IFVO
R0xpbnV4RHJpdmVyOyBEYXZpZCBTLg0KPiBNaWxsZXINCj4gQ2M6IFJhZmFlbCBKLiBXeXNvY2tp
OyBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyBsaW51eC11c2JAdmdlci5rZXJuZWwub3JnOw0KPiBs
aW51eC1wbUB2Z2VyLmtlcm5lbC5vcmc7IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcNCj4g
U3ViamVjdDogUmU6IFtQQVRDSF0gbGFuNzh4eDogUHJvdGVjdCBydW50aW1lX2F1dG8gY2hlY2sg
YnkgI2lmZGVmDQo+IENPTkZJR19QTQ0KPiAgDQo+IE5vdCB0aGF0IGl0IG1hdHRlcnMgYW55bW9y
ZSBzaW5jZSBEYXZpZCByZXZlcnRlZCB0aGUgb3JpZ2luYWwgcGF0Y2gsDQo+IGJ1dCBteSByZWFz
b24gZm9yIG5vdCBzZW5kaW5nIGEgc2ltaWxhciBwYXRjaCB3YXMgdGhhdCBJIHdhc24ndCBzdXJl
DQo+IGlmIC5ydW50aW1lX2F1dG8gc2hvdWxkIGJlIGFjY2Vzc2VkIGZyb20gZHJpdmVycyBpbiB0
aGUgZmlyc3QgcGxhY2UsDQo+IG9yIGlmIHRoZXJlIGlzIHNvbWUgbG9naWNhbCBwcm9ibGVtIHdp
dGggdGhlIGNvZGUuDQo+IA0KDQpCZWNhdXNlIGRyaXZlciBjYW4gZW5hYmxlL2Rpc2FibGUgYXV0
b3N1c3BlbmQgYnkgdXNiX2VuYWJsZV9hdXRvc3VzcGVuZCgpIGFuZA0KdXNiX2Rpc2FibGVfYXV0
b3N1c3BlbmQoKSwgaXQgd291bGQgYmUgbmljZSB0byBoYXZlIGhlbHBlciB0byBmaW5kIG91dCBh
dXRvc3VzcGVuZCBzdGF0dXMuDQoNClRoZSBjb2RlIHBhdGggd2FzIHRvIHV0aWxpemUgYXV0b3N1
c3BlbmQgcG93ZXIgc2F2aW5nLCB3aGVuIGl0IGlzIGVuYWJsZWQuDQoNCldvb2p1bmcNCg0K
