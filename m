From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] inet: fix potential deadlock in reqsk_queue_unlink()
Date: Tue, 18 Aug 2015 11:04:05 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB7E6FA@AcuExch.aculab.com>
References: <1439222953.1084.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150810.211821.2246516216165801977.davem@davemloft.net>
	 <1439497173.7960.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1439498674.7960.14.camel@edumazet-glaptop2.roam.corp.google.com>
 <1439505891.7960.38.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.182]:53576 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727AbbHRLGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 07:06:55 -0400
In-Reply-To: <1439505891.7960.38.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IFNlbnQ6IDEzIEF1Z3VzdCAyMDE1IDIzOjQ1DQo+IFdoZW4g
cmVwbGFjaW5nIGRlbF90aW1lcigpIHdpdGggZGVsX3RpbWVyX3N5bmMoKSwgSSBpbnRyb2R1Y2Vk
DQo+IGEgZGVhZGxvY2sgY29uZGl0aW9uIDoNCj4gDQo+IHJlcXNrX3F1ZXVlX3VubGluaygpIGlz
IGNhbGxlZCBmcm9tIGluZXRfY3NrX3JlcXNrX3F1ZXVlX2Ryb3AoKQ0KPiANCj4gaW5ldF9jc2tf
cmVxc2tfcXVldWVfZHJvcCgpIGNhbiBiZSBjYWxsZWQgZnJvbSBtYW55IGNvbnRleHRzLA0KPiBv
bmUgYmVpbmcgdGhlIHRpbWVyIGhhbmRsZXIgaXRzZWxmIChyZXFza190aW1lcl9oYW5kbGVyKCkp
Lg0KPiANCj4gSW4gdGhpcyBjYXNlLCBkZWxfdGltZXJfc3luYygpIGxvb3BzIGZvcmV2ZXIuDQo+
IA0KPiBTaW1wbGUgZml4IGlzIHRvIHRlc3QgaWYgdGltZXIgaXMgcGVuZGluZy4NCg0KRG9lc24n
dCB0aGF0IG1lYW4geW91IGZhaWwgdG8gd2FpdCBmb3IgdGhlIHRpbWVyIGZ1bmN0aW9uDQp0byBm
aW5pc2ggaWYgeW91IGFyZSBjYWxsaW5nIGZyb20gYSBkaWZmZXJlbnQgY29udGV4dD8NCg0KV2hh
dCB5b3UgbmVlZCB0byBrbm93IGlzIHdoZXRoZXIgdGhlIGN1cnJlbnQgY29udGV4dA0KaXMgdGhh
dCBydW5uaW5nIHRoZSB0aW1lciBpdHNlbGYuDQpJbiB3aGljaCBjYXNlIHlvdSBuZWVkIHRvIG1h
cmsgdGhlIHRpbWVyICd0byBiZSBkZWxldGVkJw0KYW5kIGFjdHVhbGx5IGRlbGV0ZSBpdCB3aGVu
IHRoZSB0aW1lciBmdW5jdGlvbiByZXR1cm5zLg0KKHNvIG90aGVyIGNvZGUgY2FuIHN0aWxsIHdh
aXQgZm9yIGNvbXBsZXRpb24uKQ0KDQoJRGF2aWQNCg0K
