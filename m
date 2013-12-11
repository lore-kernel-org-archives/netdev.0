From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net v3 2/2] xen-netback: napi: don't prematurely request
 a tx event
Date: Wed, 11 Dec 2013 10:29:03 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD01AEA51@AMSPEX01CL01.citrite.net>
References: <1386682782-7052-1-git-send-email-paul.durrant@citrix.com>
	 <1386682782-7052-3-git-send-email-paul.durrant@citrix.com>
 <1386755055.30271.2.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:54872 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751183Ab3LKK3t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Dec 2013 05:29:49 -0500
In-Reply-To: <1386755055.30271.2.camel@kazak.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBJYW4gQ2FtcGJlbGwNCj4gU2Vu
dDogMTEgRGVjZW1iZXIgMjAxMyAwOTo0NA0KPiBUbzogUGF1bCBEdXJyYW50DQo+IENjOiB4ZW4t
ZGV2ZWxAbGlzdHMueGVuLm9yZzsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsgV2VpIExpdTsgRGF2
aWQgVnJhYmVsDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggbmV0IHYzIDIvMl0geGVuLW5ldGJhY2s6
IG5hcGk6IGRvbid0IHByZW1hdHVyZWx5DQo+IHJlcXVlc3QgYSB0eCBldmVudA0KPiANCj4gT24g
VHVlLCAyMDEzLTEyLTEwIGF0IDEzOjM5ICswMDAwLCBQYXVsIER1cnJhbnQgd3JvdGU6DQo+ID4g
VGhpcyBwYXRjaCBjaGFuZ2VzIHRoZSBSSU5HX0ZJTkFMX0NIRUNLX0ZPUl9SRVFVRVNUUyBpbg0K
PiA+IHhlbnZpZl9idWlsZF90eF9nb3BzIHRvIGEgY2hlY2sgZm9yIFJJTkdfSEFTX1VOQ09OU1VN
RURfUkVRVUVTVFMNCj4gYXMgdGhlDQo+ID4gZm9ybWVyIGNhbGwgaGFzIHRoZSBzaWRlIGVmZmVj
dCBvZiBhZHZhbmNpbmcgdGhlIHJpbmcgZXZlbnQgcG9pbnRlciBhbmQNCj4gPiB0aGVyZWZvcmUg
aW52aXRpbmcgYW5vdGhlciBpbnRlcnJ1cHQgZnJvbSB0aGUgZnJvbnRlbmQgYmVmb3JlIHRoZSBu
YXBpDQo+ID4gcG9sbCBoYXMgYWN0dWFsbHkgZmluaXNoZWQsIHRoZXJlYnkgZGVmZWF0aW5nIHRo
ZSBwb2ludCBvZiBuYXBpLg0KPiANCj4gTGlrZSBJIHNhaWQgbGFzdCB0aW1lOg0KPiANCj4gQ2Fu
IHlvdSBhZGQgYSByZW1pbmRlciBvZiB3aGVuL3doZXJlIHRoZSByaW5nIGV2ZW50IHBvaW50ZXIg
aXMNCj4gZXZlbnR1YWxseSBhZHZhbmNlZCBub3cgcGxlYXNlLg0KPiANCg0KU29ycnksIEkgbWlz
c2VkIHRoYXQuIFdpbGwgZG8uDQoNCiAgUGF1bA0K
