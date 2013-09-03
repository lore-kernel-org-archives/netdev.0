From: Li Frank-B20596 <B20596@freescale.com>
Subject: RE: [PATCH] net: fec: fix the error to get the previous BD entry
Date: Tue, 3 Sep 2013 15:20:24 +0000
Message-ID: <1F990F8245A4214A8CC4BFFBD9F790F908B46E9A@039-SN1MPN1-001.039d.mgd.msft.net>
References: <1378176078-10380-1-git-send-email-B38611@freescale.com>
	<1F990F8245A4214A8CC4BFFBD9F790F908B45F9F@039-SN1MPN1-001.039d.mgd.msft.net>
	<20130902.203506.1108904049878490946.davem@davemloft.net>
	<1F990F8245A4214A8CC4BFFBD9F790F908B46E06@039-SN1MPN1-001.039d.mgd.msft.net>
 <CAOMZO5AHQr87ka2PrmMCQ0Dr46T=gB5_j1fz9BxhcjyWw9qSnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	Duan Fugang-B38611 <B38611@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:60000
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752453Ab3ICPU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 11:20:29 -0400
In-Reply-To: <CAOMZO5AHQr87ka2PrmMCQ0Dr46T=gB5_j1fz9BxhcjyWw9qSnw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogRmFiaW8gRXN0ZXZhbSBb
bWFpbHRvOmZlc3RldmFtQGdtYWlsLmNvbV0NCj4gU2VudDogVHVlc2RheSwgU2VwdGVtYmVyIDAz
LCAyMDEzIDEwOjE1IEFNDQo+IFRvOiBMaSBGcmFuay1CMjA1OTYNCj4gQ2M6IERhdmlkIE1pbGxl
cjsgRHVhbiBGdWdhbmctQjM4NjExOyBuZXRkZXZAdmdlci5rZXJuZWwub3JnOw0KPiBiaHV0Y2hp
bmdzQHNvbGFyZmxhcmUuY29tOyBzdGVwaGVuQG5ldHdvcmtwbHVtYmVyLm9yZw0KPiBTdWJqZWN0
OiBSZTogW1BBVENIXSBuZXQ6IGZlYzogZml4IHRoZSBlcnJvciB0byBnZXQgdGhlIHByZXZpb3Vz
IEJEIGVudHJ5DQo+IA0KPiBPbiBUdWUsIFNlcCAzLCAyMDEzIGF0IDEyOjEwIFBNLCBMaSBGcmFu
ay1CMjA1OTYgPEIyMDU5NkBmcmVlc2NhbGUuY29tPg0KPiB3cm90ZToNCj4gPg0KPiA+PiA+IEFj
a2VkDQo+ID4+DQo+ID4+IFRoaXMgaXMgbm90IHRoZSBjb3JyZWN0IHdheSB0byBBQ0sgYSBwYXRj
aCwgdGhlIGNvcnJlY3QgZm9ybWF0IGlzOg0KPiA+Pg0KPiA+PiBBY2tlZC1ieTogRGF2aWQgUy4g
TWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KPiA+DQo+ID4NCj4gPiBUaGFua3MNCj4gPg0K
PiA+IEFja2VkLWJ5OiBGcmFuayBMaSA8ZnJhbmsubGlAZnJlZXNjYWxlLm5ldD4NCj4gDQo+IEkg
dGhvdWdodCB5b3VyIGVtYWlsIHdhcyBmcmVlc2NhbGUuY29tIDstKQ0KWWVzLCBJIGFtIHdyb25n
LiANClNvcnJ5LiANCg0KQWNrZWQtYnk6IEZyYW5rIExpIDxmcmFuay5saUBmcmVlc2NhbGUuY29t
Pg0K
