From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: "tipc: fix socket timer deadlock" to stable?
Date: Tue, 21 Mar 2017 11:35:27 +0000
Message-ID: <DB5PR0701MB1958BA77574C012D96969F079A3D0@DB5PR0701MB1958.eurprd07.prod.outlook.com>
References: <42aebc97-bd71-a9f8-490b-42d8e81283c6@nokia.com>
 <A2BAEFC30C8FD34388F02C9B3121859D3D7173F1@eusaamb103.ericsson.se>
 <876102a9-a205-36a3-bc29-f0bb2bf70eff@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>, GUNA <gbalasun@gmail.com>,
        "Ying Xue" <ying.xue@windriver.com>
To: Tommi Rantala <tommi.t.rantala@nokia.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:49374 "EHLO
        sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751381AbdCULxD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 07:53:03 -0400
In-Reply-To: <876102a9-a205-36a3-bc29-f0bb2bf70eff@nokia.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogVG9tbWkgUmFudGFsYSBb
bWFpbHRvOnRvbW1pLnQucmFudGFsYUBub2tpYS5jb21dDQo+IFNlbnQ6IFR1ZXNkYXksIE1hcmNo
IDIxLCAyMDE3IDAzOjUwIEFNDQo+IFRvOiBKb24gTWFsb3kgPGpvbi5tYWxveUBlcmljc3Nvbi5j
b20+OyBuZXRkZXZAdmdlci5rZXJuZWwub3JnDQo+IENjOiBEYXZpZCBTLiBNaWxsZXIgPGRhdmVt
QGRhdmVtbG9mdC5uZXQ+OyBHVU5BIDxnYmFsYXN1bkBnbWFpbC5jb20+Ow0KPiBZaW5nIFh1ZSA8
eWluZy54dWVAd2luZHJpdmVyLmNvbT4NCj4gU3ViamVjdDogUmU6ICJ0aXBjOiBmaXggc29ja2V0
IHRpbWVyIGRlYWRsb2NrIiB0byBzdGFibGU/DQo+IA0KPiBPbiAxMy4wMy4yMDE3IDE0OjE4LCBK
b24gTWFsb3kgd3JvdGU6DQo+ID4+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+ID4+IEZy
b206IFRvbW1pIFJhbnRhbGEgW21haWx0bzp0b21taS50LnJhbnRhbGFAbm9raWEuY29tXQ0KPiA+
Pg0KPiA+PiBXZSdyZSBzZWVpbmcgdGhpcyB0aXBjIGRlYWRsb2NrIGluIDQuNC55LCB0aGF0IHdh
cyBmaXhlZCBpbiB0aGUNCj4gPj4gbWFpbmxpbmUgY29tbWl0DQo+ID4+IGYxZDA0OGYyNGU2NmJh
ODVkM2RhYmYzZDA3NmNlZmE1ZjJiNTQ2YjAgInRpcGM6IGZpeCBzb2NrZXQgdGltZXINCj4gPj4g
ZGVhZGxvY2siLg0KPiA+Pg0KPiA+PiBDb3VsZC9zaG91bGQgdGhpcyBwYXRjaCBhbHNvIGJlIGlu
Y2x1ZGVkIGluIHRoZSBzdGFibGUga2VybmVsIHRyZWVzPw0KPiA+DQo+ID4gSSB0aGluayBpdCBz
aG91bGQuIElmIGFjdGlvbiBpcyByZXF1aXJlZCBieSBtZSBoZXJlICg/KSBJIHdpbGwgcmVwb3N0
IHRoZSBjb21taXQNCj4gZm9yIDQuNC4NCj4gPg0KPiA+IC8vL2pvbg0KPiANCj4gSGkgSm9uLCB5
ZXMsIHBsZWFzZSBkbyByZXBvc3QgdGhlIGNvbW1pdC4gQWZ0ZXIgcmVhZGluZyB0aHJvdWdoDQo+
IERvY3VtZW50YXRpb24vbmV0d29ya2luZy9uZXRkZXYtRkFRLnR4dCwgeW91IHByb2JhYmx5IHdh
bnQgdG8gc2VuZCBpdA0KPiB3aXRoIHN1aXRhYmxlIHN1YmplY3QtcHJlZml4IHNvIHRoYXQgdGhl
IHBhdGNoIGlzIG5vdCBsb3N0IGluIHRoZSBub2lzZS4NCj4gDQpPay4gSSdsbCBkbyB0aGF0LiBK
dXN0IGhhdmUgdG8gZG8gcHJvcGVyIHRlc3RpbmcgZmlyc3QuDQoNCi8vL2pvbg0KDQo+ID4+IEkg
anVzdCBjaGVja2VkIHRoYXQgdGhlIHBhdGNoIGFwcGxpZXMgb24gdG9wIG9mIDQuNC41Mywgb25s
eSB0aGUgbGluZQ0KPiA+PiBudW1iZXJzIGFyZSBkaWZmZXJlbnQgY29tcGFyZWQgdG8gdGhlIHVw
c3RyZWFtIGNvbW1pdC4NCj4gDQo+IChBY3R1YWxseSB0aGVyZSBpcyBhbHNvIGEgc21hbGwgY2hh
bmdlIGluIHRoZSBwYXRjaCBjb250ZXh0LikNCj4gDQo+IC1Ub21taQ0K
