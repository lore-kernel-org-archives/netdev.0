From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCH net 6/7] qlcnic: Fix reset recovery after transmit
 timeout
Date: Sat, 27 Apr 2013 19:08:50 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A46F62D@avmb2.qlogic.org>
References: <1366978183-7282-1-git-send-email-shahed.shaikh@qlogic.com>
	 <1366978183-7282-7-git-send-email-shahed.shaikh@qlogic.com>
 <1367010061.4035.7.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe010.messaging.microsoft.com ([216.32.180.30]:43643
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752985Ab3D0TI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Apr 2013 15:08:56 -0400
In-Reply-To: <1367010061.4035.7.camel@bwh-desktop.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBCZW4gSHV0Y2hpbmdzIFttYWlsdG86Ymh1dGNoaW5nc0Bzb2xhcmZsYXJlLmNvbV0N
Cj4gU2VudDogU2F0dXJkYXksIEFwcmlsIDI3LCAyMDEzIDI6MzEgQU0NCj4gVG86IFNoYWhlZCBT
aGFpa2gNCj4gQ2M6IERhdmlkIE1pbGxlcjsgbmV0ZGV2OyBEZXB0LU5YIExpbnV4IE5JQyBEcml2
ZXI7IFNvbnkgQ2hhY2tvDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggbmV0IDYvN10gcWxjbmljOiBG
aXggcmVzZXQgcmVjb3ZlcnkgYWZ0ZXIgdHJhbnNtaXQgdGltZW91dA0KPg0KWy4uLl0NCj4gPiAg
CW5ldGlmX2RldmljZV9hdHRhY2gobmV0ZGV2KTsNCj4gPiAtCWlmIChuZXRpZl9ydW5uaW5nKG5l
dGRldikpIHsNCj4gPiAtCQluZXRpZl9jYXJyaWVyX29uKG5ldGRldik7DQo+ID4gLQkJbmV0aWZf
d2FrZV9xdWV1ZShuZXRkZXYpOw0KPiA+IC0JfQ0KPiA+ICsJYWRhcHRlci0+bmV0ZGV2LT50cmFu
c19zdGFydCA9IGppZmZpZXM7DQo+ID4gIH0NCj4gWy4uLl0NCj4gDQo+IFRoZSBkZWxldGlvbnMg
bG9vayBnb29kLCBidXQgaXQgc2hvdWxkIG5vdCBiZSBuZWNlc3NhcnkgdG8gd3JpdGUgdG8NCj4g
dHJhbnNfc3RhcnQuICBXaHkgZG8geW91IHRoaW5rIGl0IGlzIG5lZWRlZD8NCg0KWW91IGFyZSBj
b3JyZWN0LCB3ZSBkb24ndCBoYXZlIHRvIHVwZGF0ZSBuZXRkZXYtPnRyYW5zX3N0YXJ0LiANCldl
IHdlcmUgdXBkYXRpbmcgbmV0ZGV2LT50cmFuc19zdGFydCB0byBwcmV2ZW50IHdhdGNoZG9nIGZy
b20ga2lja2luZyBpbi4NCldhdGNoZG9nIHRpbWVvdXQgd2lsbCBub3QgaGFwcGVuIGJlY2F1c2Ug
d2UgYXJlIHdha2luZyB0aGUgVHggcXVldWUgYW5kIHR1cm5pbmcgdGhlIGNhcnJpZXIgT04gcHJp
b3IgdG8gIGF0dGFjaGluZyB0aGUgZGV2aWNlLg0KIA0KV2Ugd2lsbCBtYWtlIHRoZSByZXF1aXJl
ZCBjaGFuZ2UgYXMgeW91IHN1Z2dlc3RlZCBpbiBWMiBvZiB0aGUgcGF0Y2ggc2VyaWVzLg0KDQpU
aGFua3MsDQpTaGFoZWQNCj4gDQo+IEJlbi4NCj4gDQo+IC0tDQo+IEJlbiBIdXRjaGluZ3MsIFN0
YWZmIEVuZ2luZWVyLCBTb2xhcmZsYXJlIE5vdCBzcGVha2luZyBmb3IgbXkgZW1wbG95ZXI7DQo+
IHRoYXQncyB0aGUgbWFya2V0aW5nIGRlcGFydG1lbnQncyBqb2IuDQo+IFRoZXkgYXNrZWQgdXMg
dG8gbm90ZSB0aGF0IFNvbGFyZmxhcmUgcHJvZHVjdCBuYW1lcyBhcmUgdHJhZGVtYXJrZWQuDQo+
IA0KDQo=
