From: Razvan Stefanescu <razvan.stefanescu@nxp.com>
Subject: RE: [RESEND PATCH 2/6] staging: fsl-dpaa2/ethsw: Add Freescale DPAA2
 Ethernet Switch driver
Date: Mon, 2 Oct 2017 07:18:52 +0000
Message-ID: <AM3PR04MB0743CC52EC71DC2BC7D0C2BEE67D0@AM3PR04MB0743.eurprd04.prod.outlook.com>
References: <1505825158-8192-1-git-send-email-razvan.stefanescu@nxp.com>
 <1505825158-8192-3-git-send-email-razvan.stefanescu@nxp.com>
 <DB5PR04MB12400025DF190790B4792B50EA7E0@DB5PR04MB1240.eurprd04.prod.outlook.com>
 <AM3PR04MB0743F62497ED0CB445F51524E67E0@AM3PR04MB0743.eurprd04.prod.outlook.com>
 <A4C4732A-CC1F-4707-89F8-E7284F022DB0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "agraf@suse.de" <agraf@suse.de>, "arnd@arndb.de" <arnd@arndb.de>,
        Alexandru Marginean <alexandru.marginean@nxp.com>,
        Ruxandra Ioana Radulescu <ruxandra.radulescu@nxp.com>,
        Laurentiu Tudor <laurentiu.tudor@nxp.com>,
        "stuyoder@gmail.com" <stuyoder@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Bogdan Purcareata <bogdan.purcareata@nxp.com>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <A4C4732A-CC1F-4707-89F8-E7284F022DB0@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBGbG9yaWFuIEZhaW5lbGxpIFtt
YWlsdG86Zi5mYWluZWxsaUBnbWFpbC5jb21dDQo+IFNlbnQ6IEZyaWRheSwgU2VwdGVtYmVyIDI5
LCAyMDE3IDE5OjExDQo+IFRvOiBSYXp2YW4gU3RlZmFuZXNjdSA8cmF6dmFuLnN0ZWZhbmVzY3VA
bnhwLmNvbT47IEJvZ2RhbiBQdXJjYXJlYXRhDQo+IDxib2dkYW4ucHVyY2FyZWF0YUBueHAuY29t
PjsgZ3JlZ2toQGxpbnV4Zm91bmRhdGlvbi5vcmcNCj4gQ2M6IGRldmVsQGRyaXZlcmRldi5vc3Vv
c2wub3JnOyBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnOw0KPiBuZXRkZXZAdmdlci5rZXJu
ZWwub3JnOyBhZ3JhZkBzdXNlLmRlOyBhcm5kQGFybmRiLmRlOyBBbGV4YW5kcnUgTWFyZ2luZWFu
DQo+IDxhbGV4YW5kcnUubWFyZ2luZWFuQG54cC5jb20+OyBSdXhhbmRyYSBJb2FuYSBSYWR1bGVz
Y3UNCj4gPHJ1eGFuZHJhLnJhZHVsZXNjdUBueHAuY29tPjsgTGF1cmVudGl1IFR1ZG9yIDxsYXVy
ZW50aXUudHVkb3JAbnhwLmNvbT47DQo+IHN0dXlvZGVyQGdtYWlsLmNvbQ0KPiBTdWJqZWN0OiBS
RTogW1JFU0VORCBQQVRDSCAyLzZdIHN0YWdpbmc6IGZzbC1kcGFhMi9ldGhzdzogQWRkIEZyZWVz
Y2FsZSBEUEFBMg0KPiBFdGhlcm5ldCBTd2l0Y2ggZHJpdmVyDQo+IA0KPiBPbiBTZXB0ZW1iZXIg
MjksIDIwMTcgNjo1OToxOCBBTSBQRFQsIFJhenZhbiBTdGVmYW5lc2N1DQo+IDxyYXp2YW4uc3Rl
ZmFuZXNjdUBueHAuY29tPiB3cm90ZToNCj4gPg0KPiA+DQo+ID4+IC0tLS0tT3JpZ2luYWwgTWVz
c2FnZS0tLS0tDQo+ID4+IEZyb206IEJvZ2RhbiBQdXJjYXJlYXRhDQo+ID4+IFNlbnQ6IEZyaWRh
eSwgU2VwdGVtYmVyIDI5LCAyMDE3IDE2OjM2DQo+ID4+IFRvOiBSYXp2YW4gU3RlZmFuZXNjdSA8
cmF6dmFuLnN0ZWZhbmVzY3VAbnhwLmNvbT47DQo+ID4+IGdyZWdraEBsaW51eGZvdW5kYXRpb24u
b3JnDQo+ID4+IENjOiBkZXZlbEBkcml2ZXJkZXYub3N1b3NsLm9yZzsgbGludXgta2VybmVsQHZn
ZXIua2VybmVsLm9yZzsNCj4gPj4gbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsgYWdyYWZAc3VzZS5k
ZTsgYXJuZEBhcm5kYi5kZTsgQWxleGFuZHJ1DQo+ID5NYXJnaW5lYW4NCj4gPj4gPGFsZXhhbmRy
dS5tYXJnaW5lYW5AbnhwLmNvbT47IFJ1eGFuZHJhIElvYW5hIFJhZHVsZXNjdQ0KPiA+PiA8cnV4
YW5kcmEucmFkdWxlc2N1QG54cC5jb20+OyBMYXVyZW50aXUgVHVkb3INCj4gPjxsYXVyZW50aXUu
dHVkb3JAbnhwLmNvbT47DQo+ID4+IHN0dXlvZGVyQGdtYWlsLmNvbQ0KPiA+PiBTdWJqZWN0OiBS
RTogW1JFU0VORCBQQVRDSCAyLzZdIHN0YWdpbmc6IGZzbC1kcGFhMi9ldGhzdzogQWRkDQo+ID5G
cmVlc2NhbGUgRFBBQTINCj4gPj4gRXRoZXJuZXQgU3dpdGNoIGRyaXZlcg0KPiA+Pg0KPiA+PiA+
IEludHJvZHVjZSB0aGUgRFBBQTIgRXRoZXJuZXQgU3dpdGNoIGRyaXZlciwgd2hpY2ggbWFuYWdl
cyBEYXRhcGF0aA0KPiA+U3dpdGNoDQo+ID4+ID4gKERQU1cpIG9iamVjdHMgZGlzY292ZXJlZCBv
biB0aGUgTUMgYnVzLg0KPiA+PiA+DQo+ID4+ID4gU3VnZ2VzdGVkLWJ5OiBBbGV4YW5kcnUgTWFy
Z2luZWFuIDxhbGV4YW5kcnUubWFyZ2luZWFuQG54cC5jb20+DQo+ID4+ID4gU2lnbmVkLW9mZi1i
eTogUmF6dmFuIFN0ZWZhbmVzY3UgPHJhenZhbi5zdGVmYW5lc2N1QG54cC5jb20+DQo+IA0KPiBU
aGlzIGxvb2tzIHByZXR0eSBnb29kIGZvciBhIG5ldyBzd2l0Y2hkZXYgZHJpdmVyLCBpcyB0aGVy
ZSBhIHJlYXNvbiB5b3UgY2FuJ3QNCj4gdGFyZ2V0IGRyaXZlcnMvbmV0L2V0aGVybmV0IGluc3Rl
YWQgb2Ygc3RhZ2luZz8gSXMgaXQgYmVjYXVzZSB0aGUgTUMgYnVzIGNvZGUgaXMNCj4gc3RpbGwg
aW4gc3RhZ2luZyAoQUZBSUNUKT8NCj4gDQpZZXMsIGRyaXZlciBkZXBlbmRzIG9uIE1DIGJ1cywg
d2hpY2ggaXMgc3RpbGwgaW4gc3RhZ2luZy4gIEFsc28sIGNvbnRyb2wgdHJhZmZpYw0KY29kZSB3
aWxsIHJlcXVpcmUgYWNjZXNzIHRvIERQSU8gZnVuY3Rpb25zLCB0aGF0IGFyZSBhbHNvIGluIHN0
YWdpbmcuDQoNCkJlc3QgcmVnYXJkcywNClJhenZhbiBTLg0KPiAtLQ0KPiBGbG9yaWFuDQo=
