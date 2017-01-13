From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2 05/10] drivers: base: Add device_find_class()
Date: Fri, 13 Jan 2017 10:55:38 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB02620D3@AcuExch.aculab.com>
References: <20170112034121.27697-1-f.fainelli@gmail.com>
 <20170112034121.27697-6-f.fainelli@gmail.com>
 <20170112.162135.441956368122992032.davem@davemloft.net>
 <81f5965c-3484-92d9-5c04-94c5b73735d0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jason@lakedaemon.net" <jason@lakedaemon.net>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "sebastian.hesselbarth@gmail.com" <sebastian.hesselbarth@gmail.com>,
        "gregory.clement@free-electrons.com"
        <gregory.clement@free-electrons.com>,
        "linux@armlinux.org.uk" <linux@armlinux.org.uk>,
        "vivien.didelot@savoirfairelinux.com"
        <vivien.didelot@savoirfairelinux.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
To: 'Florian Fainelli' <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <81f5965c-3484-92d9-5c04-94c5b73735d0@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogRmxvcmlhbiBGYWluZWxsaQ0KPiBTZW50OiAxMiBKYW51YXJ5IDIwMTcgMjI6NTENCj4g
T24gMDEvMTIvMjAxNyAwMToyMSBQTSwgRGF2aWQgTWlsbGVyIHdyb3RlOg0KPiA+IEZyb206IEZs
b3JpYW4gRmFpbmVsbGkgPGYuZmFpbmVsbGlAZ21haWwuY29tPg0KPiA+IERhdGU6IFdlZCwgMTEg
SmFuIDIwMTcgMTk6NDE6MTYgLTA4MDANCj4gPg0KPiA+PiBBZGQgYSBoZWxwZXIgZnVuY3Rpb24g
dG8gbG9va3VwIGEgZGV2aWNlIHJlZmVyZW5jZSBnaXZlbiBhIGNsYXNzIG5hbWUuDQo+ID4+IFRo
aXMgaXMgYSBwcmVsaW1pbmFyeSBwYXRjaCB0byByZW1vdmUgYWRob2MgY29kZSBmcm9tIG5ldC9k
c2EvZHNhLmMgYW5kDQo+ID4+IG1ha2UgaXQgbW9yZSBnZW5lcmljLg0KLi4uDQo+ID4+ICtzdGF0
aWMgaW50IGRldl9pc19jbGFzcyhzdHJ1Y3QgZGV2aWNlICpkZXYsIHZvaWQgKmNsYXNzKQ0KPiA+
DQo+ID4gSSBrbm93IHlvdSBhcmUganVzdCBtb3ZpbmcgY29kZSwgYnV0IHRoaXMgY2xhc3MgYXJn
dW1uZXQgaXMgYSBzdHJpbmcNCj4gPiBhbmQgdGh1cyBzaG91bGQgYmUgImNoYXIgKiIgb3IgZXZl
biAiY29uc3QgY2hhciAqIi4NCj4gDQo+IFdlbGwsIHRoaXMgaXMgcmVhbGx5IHNvIHRoYXQgd2Ug
ZG9uJ3QgbmVlZCB0byBjYXN0IHRoZSBhcmd1bWVudHMgcGFzc2VkDQo+IHRvIGRldmljZV9maW5k
X2NoaWxkKCksIHdoaWNoIHRha2VzIGEgdm9pZCAqZGF0YSBhcyB3ZWxsLiBJZiB3ZSBtYWRlDQo+
IHRoYXQgYSBjb25zdCBjaGFyICpjbGFzcywgd2UnZCBnZXQgd2FybmluZ3MgdGhhdCBsb29rIGxp
a2UgdGhlc2U6DQo+IA0KPiBkcml2ZXJzL2Jhc2UvY29yZS5jOiBJbiBmdW5jdGlvbiAnZGV2aWNl
X2ZpbmRfY2xhc3MnOg0KPiBkcml2ZXJzL2Jhc2UvY29yZS5jOjIwODM6Mjogd2FybmluZzogcGFz
c2luZyBhcmd1bWVudCAyIG9mDQo+ICdkZXZpY2VfZmluZF9jaGlsZCcgZGlzY2FyZHMgJ2NvbnN0
JyBxdWFsaWZpZXIgZnJvbSBwb2ludGVyIHRhcmdldCB0eXBlDQo+IFtlbmFibGVkIGJ5IGRlZmF1
bHRdDQo+ICAgcmV0dXJuIGRldmljZV9maW5kX2NoaWxkKHBhcmVudCwgY2xhc3MsIGRldl9pc19j
bGFzcyk7DQo+ICAgXg0KPiBkcml2ZXJzL2Jhc2UvY29yZS5jOjIwNTA6MTY6IG5vdGU6IGV4cGVj
dGVkICd2b2lkIConIGJ1dCBhcmd1bWVudCBpcyBvZg0KPiB0eXBlICdjb25zdCBjaGFyIConDQo+
ICBzdHJ1Y3QgZGV2aWNlICpkZXZpY2VfZmluZF9jaGlsZChzdHJ1Y3QgZGV2aWNlICpwYXJlbnQs
IHZvaWQgKmRhdGEsDQo+ICAgICAgICAgICAgICAgICBeDQouLi4NCg0KTWF5YmUgZGV2aWNlX2Zp
bmRfY2hpbGQoKSBuZWVkcyBjaGFuZ2luZyB0byB0YWtlICdjb25zdCB2b2lkIConID8NCg0KCURh
dmlkDQoNCg==
