From: "Zhu, Yi" <yi.zhu@intel.com>
Subject: RE: [PATCH V2 2/7] tcp: use limited socket backlog
Date: Thu, 4 Mar 2010 19:04:55 +0800
Message-ID: <DA586906BA1FFC4384FCFD6429ECE860A45A6D9E@shzsmsx502.ccr.corp.intel.com>
References: <1267605389-7369-1-git-send-email-yi.zhu@intel.com>
	 <1267605389-7369-2-git-send-email-yi.zhu@intel.com>
	 <1267606433.2997.4.camel@edumazet-laptop>
	 <1267607162.2370.169.camel@debian>
	 <1267610843.2997.7.camel@edumazet-laptop>
	 <DA586906BA1FFC4384FCFD6429ECE860A45A6999@shzsmsx502.ccr.corp.intel.com>
	 <1267626678.2997.25.camel@edumazet-laptop>
	 <DA586906BA1FFC4384FCFD6429ECE860A45A6BAE@shzsmsx502.ccr.corp.intel.com>
 <1267682431.2943.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5947 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752274Ab0CDLFD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Mar 2010 06:05:03 -0500
In-Reply-To: <1267682431.2943.10.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPiB3cm90ZToNCg0KPj4gQ2FuIHlv
dSBzaG93IG1lIHdoZXJlIHNrX2Ryb3BzIGlzIHVzZWQgYnkgVENQIGFuZCB3aGF0IFNOTVAgTUlC
IHZhbHVlDQo+PiBzaG91bGQgSSB1c2UgZm9yIGJhY2tsb2cgZHJvcHBpbmc/IFRDUF9NSUJfSU5F
UlJTIGRvZXNuJ3Qgc2VlbSBjb3JyZWN0Lg0KDQo+IHNrX2Ryb3AgaXMgbm90IHlldCB1c2VkIGJ5
IFRDUCwgYmVjYXVzZSB3aGVuIGJhY2tsb2cgcHJvY2Vzc2luZyBpcw0KPiBwZXJmb3JtZWQsIFRD
UCBzdGF0ZSBtYWNoaW5lIGhhcyBtdWNoIGZpbmVyIGdyYWluIGNhcGFiaWxpdGllcyB0byBzaG93
DQo+IHdoeSBhIHBhY2tldCBpcyBkcm9wcGVkLiBJbiBvdXIgYmFja2xvZyBkcm9wLCB3ZSBkb250
IGV4YW1pbmUgZGV0YWlscyBvZg0KPiBwYWNrZXQgYW5kIGRyb3AgaXQgYXQgYSBsb3dlciBsZXZl
bC4NCg0KPiBQbGVhc2UgYWRkIGEgbmV3IGNvdW50ZXIsIHNheSBMSU5VWF9NSUJfVENQQkFDS0xP
R0RST1AgOg0KDQo+IDMgYWRkZWQgbGluZXM6DQo+IC0gb25lIGluICJpbmNsdWRlL2xpbnV4L3Nu
bXAuaCIgdG8gZGVmaW5lIHRoZSBNSUIgbmFtZQ0KPiAtIG9uZSB0byBkZWZpbmUgaXRzIHN0cmlu
Zw0KPiAtIG9uZSB0byBwZXJmb3JtIHRoZSBpbmNyZW1lbnQgd2hlbiBhY3R1YWwgZHJvcCBvY2N1
cnMpDQoNCj4gQSBnb29kIHN0YXJ0aW5nIHBvaW50IHdvdWxkIGJlIHRvIHN0dWR5IHJlY2VudCBj
b21taXQNCj4gNzIwMzJmZGJjZGU4YjMzM2U2NWIzNDMwZTFiY2I0MzU4ZTJkNjcxNiBmcm9tIEph
bWFsDQo+ICh4ZnJtOiBJbnRyb2R1Y2UgTElOVVhfTUlCX1hGUk1GV0RIRFJFUlJPUikNCg0KPiBG
b3Igc2tfZHJvcCwganVzdCBpbmNyZW1lbnQgaXQgYW5kIHdlIGNhbiBnZXQgaXQgYXQgZ2VuZXJp
YyBzb2NrIGxldmVsLg0KDQpTaW5jZSBuZWl0aGVyIHNrX2Ryb3BzIG5vciB0aGUgbmV3IE1JQiB2
YWx1ZSBhcmUgdXNlZCBieSBUQ1AgY3VycmVudGx5Lg0KSG93IGFib3V0IEkga2VlcCB0aGUgdGNw
IGJhY2tsb2cgbGltaXQgcGF0Y2ggYXMgaXMgYW5kIHlvdSBpbXBsZW1lbnQNCnRoZSBhYm92ZSBp
biBhbm90aGVyIHBhdGNoPw0KDQpUaGFua3MsDQoteWkNCg==
