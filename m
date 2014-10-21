From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net 1/1] hyperv: Fix a bug in netvsc_send()
Date: Tue, 21 Oct 2014 21:25:01 +0000
Message-ID: <19043471dd2242d993fbf4e22a8c246b@DFM-DB3MBX15-08.exchange.corp.microsoft.com>
References: <1412530971-29897-1-git-send-email-kys@microsoft.com>
	<20141005.211129.632749242463744635.davem@davemloft.net>
	<20141009133200.GA17134@sucs.org>
	<96f3d4f6b90a461686b23f64aedcb4fc@BL2PR03MB132.namprd03.prod.outlook.com>
	<20141011103630.GA22272@sucs.org>	<1413911624662.86334@microsoft.com>
 <CALjAwxj1jHUugt+vtJL7duXfTpdoxmCrwTzRmNHGgOdj+Ju3Aw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"apw@canonical.com" <apw@canonical.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: Sitsofe Wheeler <sitsofe@gmail.com>, Long Li <longli@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALjAwxj1jHUugt+vtJL7duXfTpdoxmCrwTzRmNHGgOdj+Ju3Aw@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogU2l0c29mZSBXaGVlbGVy
IFttYWlsdG86c2l0c29mZUBnbWFpbC5jb21dDQo+IFNlbnQ6IFR1ZXNkYXksIE9jdG9iZXIgMjEs
IDIwMTQgNToxNiBQTQ0KPiBUbzogTG9uZyBMaQ0KPiBDYzogRGF2aWQgTWlsbGVyOyBvbGFmQGFl
cGZsZS5kZTsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsNCj4gamFzb3dhbmdAcmVkaGF0LmNvbTsg
bGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZzsgYXB3QGNhbm9uaWNhbC5jb207DQo+IGRldmVs
QGxpbnV4ZHJpdmVycHJvamVjdC5vcmc7IEhhaXlhbmcgWmhhbmcNCj4gU3ViamVjdDogUmU6IFtQ
QVRDSCBuZXQgMS8xXSBoeXBlcnY6IEZpeCBhIGJ1ZyBpbiBuZXR2c2Nfc2VuZCgpDQo+IA0KPiBP
biAyMSBPY3RvYmVyIDIwMTQgMTg6MTMsIExvbmcgTGkgPGxvbmdsaUBtaWNyb3NvZnQuY29tPiB3
cm90ZToNCj4gPiBUaGFua3MgU2l0c29mZS4gVGhpcyBzaG91bGQgaGF2ZSBiZWVuIGZpeGVkIGJ5
IHRoaXMgcGF0Y2g6DQo+ID4gaHR0cDovL2dpdC5rZXJuZWwub3JnL2NnaXQvbGludXgva2VybmVs
L2dpdC9uZXh0L2xpbnV4LQ0KPiBuZXh0LmdpdC9jb21taXQvP2lkPWY4OGU2NzE0OWY5N2Q3M2M3
MDRkNmZlNmY0OTJlZGRlOTc0NjMwMjUNCj4gPg0KPiA+IENhbiB5b3UgZ2l2ZSBpdCBhIHRyeT8N
Cj4gDQo+IEFoIHRoaXMgb25lIHdlbnQgbWFpbmxpbmUgYSBmZXcgZGF5cyBhZ28gc28gSSd2ZSBh
bHJlYWR5IGJlZW4gdHJ5aW5nDQo+IGl0LiBZZXMgaXQgcmVzb2x2ZXMgbXkgcHJvYmxlbSAodGhh
dCBzeXN0ZW0gaXMgbm8gbG9uZ2VyIG9vcHNpbmcgb24NCj4gc3RhcnR1cCkuIEknZCBoYXZlIGFk
ZGVkIG15IFRlc3RlZC1ieSBidXQgaXQncyBhbHJlYWR5IGJlZW4gY29tbWl0dGVkDQo+IDotKQ0K
DQpUaGFuayB5b3UgZm9yIHRoZSB0ZXN0IQ0KDQotIEhhaXlhbmcNCg==
