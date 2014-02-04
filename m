From: =?utf-8?B?U8O4cmVuc2VuLCBTdGVmYW4=?=
	<Stefan.Sorensen@spectralink.com>
Subject: Re: [PATCH] net:cpsw: Pass unhandled ioctl's on to generic phy ioctl
Date: Tue, 4 Feb 2014 15:08:16 +0000
Message-ID: <1391526492.7871.8.camel@e37108.spectralink.com>
References: <1391500242-10554-1-git-send-email-stefan.sorensen@spectralink.com>
	 <1391511050.3003.21.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mugunthanvnm@ti.com" <mugunthanvnm@ti.com>
To: "ben@decadent.org.uk" <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0209.outbound.protection.outlook.com ([207.46.163.209]:12853
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751214AbaBDPYW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Feb 2014 10:24:22 -0500
In-Reply-To: <1391511050.3003.21.camel@deadeye.wl.decadent.org.uk>
Content-Language: en-US
Content-ID: <16B5D27C948C61478E4FEAFA50B58C15@namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCAyMDE0LTAyLTA0IGF0IDEwOjUwICswMDAwLCBCZW4gSHV0Y2hpbmdzIHdyb3RlOg0K
PiA+IFRoaXMgcGF0Y2ggYWxsb3dzIHRoZSB1c2Ugb2YgYSBnZW5lcmljIHRpbWVzdGFtcGluZyBw
aHkgY29ubmVjdGVkDQo+ID4gdG8gdGhlIGNwc3cgaWYgQ1BUUyBzdXBwb3J0IGlzIG5vdCBlbmFi
bGVkLg0KPiANCj4gV2hhdCBpZiBDUFRTIHN1cHBvcnQgaXMgZW5hYmxlZCBpbiB0aGUgZHJpdmVy
LCBidXQgdGhpcyBwYXJ0aWN1bGFyDQo+IG1hY2hpbmUgZG9lc24ndCBoYXZlIGl0IGFuZCB1c2Vz
IGEgdGltZXN0YW1waW5nIFBIWSBpbnN0ZWFkPw0KDQpUaGF0IHdvdWxkIG5vdCB3b3JrLCB0aGUg
Q1BUUyB3aWxsIGdyYWIgdGhlIFNJT0N7RyxTfUhXVFNUQU1QLiBJJ20gbm90DQpzdXJlIGhvdyB0
aGF0IGNvdWxkIGJlIGNvbmZpZ3VyZWQgYXQgcnVudGltZSwgb3RoZXIgdGhhbiBhIHByaXZhdGUN
CmV0aHRvb2wgZmxhZy4NCg0KQWxzbyBpdCBzZWVtIGFzIHRoZSBzaXR1YXRpb24gd2l0aCBhIHRp
bWVzdGFtcGluZyBNQUMgYW5kIGEgdGltZXN0YW1waW5nDQpQSFkgY291bGQgZGVsaXZlciBib2d1
cyBldGh0b29sIHRpbWVzdGFtcGluZyBpbmZvLCBhcyBpdCB3aWxsIGNvbWUgZnJvbQ0KdGhlIFBI
WSBpZiBhdmFpbGFibGUsIGJ1dCB0aGUgdGltZXN0YW1waW5nIHdpbGwgYmUgaGFuZGxlZCBieSB0
aGUgTUFDLg0KDQo+ID4gIAljYXNlIFNJT0NHTUlJUEhZOg0KPiA+ICAJCWRhdGEtPnBoeV9pZCA9
IHByaXYtPnNsYXZlc1tzbGF2ZV9ub10ucGh5LT5hZGRyOw0KPiANCj4gSXQgbG9va3MgbGlrZSB0
aGlzIGV4aXN0aW5nIGNvZGUgaXMgYnJva2VuLCBhcyB0aGUgcGh5IHBvaW50ZXIgY2FuIGJlDQo+
IE5VTEwhDQoNClJpZ2h0LCBidXQgdGhhdCBjb2RlIGNhbiBnbyBhd2F5IHNpbmNlIFNJT0NHTUlJ
UEhZIGlzIGFsc28gaGFuZGxlZCBieQ0KcGh5X21paV9pb2N0bC4gSSB3aWxsIGRlbGV0ZSB0aGF0
IGNhc2UgaW4gdGhlIG5leHQgdmVyc2lvbi4NCg0KPiA+ICsJcmV0dXJuIHBoeV9taWlfaW9jdGwo
cHJpdi0+c2xhdmVzW3NsYXZlX25vXS5waHksIHJlcSwgY21kKTsNCj4gDQo+IFRoaXMgcHJlc3Vt
YWJseSBhbHNvIGVuYWJsZXMgU0lPQ3tHLFN9TUlJUkVHLCBidXQgeW91IGRpZG4ndCBtZW50aW9u
DQo+IHRoYXQuDQoNClllcywgSSB3aWxsIGFkZCB0aGF0IHRvIHRoZSBjb21taXQgbG9nIGluIHRo
ZSBuZXh0IHZlcnNpb24uDQoNClN0ZWZhbg0K
