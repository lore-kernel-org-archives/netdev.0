From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next v4 5/5] xen-netback: enable IPv6 TCP GSO to the
 guest
Date: Wed, 16 Oct 2013 16:52:22 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD013B24B@AMSPEX01CL01.citrite.net>
References: <1381503982-1418-1-git-send-email-paul.durrant@citrix.com>
	 <1381503982-1418-6-git-send-email-paul.durrant@citrix.com>
 <1381942156.30409.19.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:50997 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760798Ab3JPQwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 12:52:25 -0400
In-Reply-To: <1381942156.30409.19.camel@kazak.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBJYW4gQ2FtcGJlbGwNCj4gU2Vu
dDogMTYgT2N0b2JlciAyMDEzIDE3OjQ5DQo+IFRvOiBQYXVsIER1cnJhbnQNCj4gQ2M6IHhlbi1k
ZXZlbEBsaXN0cy54ZW4ub3JnOyBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyBXZWkgTGl1OyBEYXZp
ZCBWcmFiZWwNCj4gU3ViamVjdDogUmU6IFtQQVRDSCBuZXQtbmV4dCB2NCA1LzVdIHhlbi1uZXRi
YWNrOiBlbmFibGUgSVB2NiBUQ1AgR1NPIHRvDQo+IHRoZSBndWVzdA0KPiANCj4gT24gRnJpLCAy
MDEzLTEwLTExIGF0IDE2OjA2ICswMTAwLCBQYXVsIER1cnJhbnQgd3JvdGU6DQo+ID4gVGhpcyBw
YXRjaCBhZGRzIGNvZGUgdG8gaGFuZGxlIFNLQl9HU09fVENQVjYgc2ticyBhbmQgY29uc3RydWN0
DQo+IGFwcHJvcHJpYXRlDQo+ID4gZXh0cmEgb3IgcHJlZml4IHNlZ21lbnRzIHRvIHBhc3MgdGhl
IGxhcmdlIHBhY2tldCB0byB0aGUgZnJvbnRlbmQuIE5ldw0KPiA+IHhlbnN0b3JlIGZsYWdzLCBm
ZWF0dXJlLWdzby10Y3B2NiBhbmQgZmVhdHVyZS1nc28tdGNwdjYtcHJlZml4LCBhcmUNCj4gc2Ft
cGxlZA0KPiA+IHRvIGRldGVybWluZSBpZiB0aGUgZnJvbnRlbmQgaXMgY2FwYWJsZSBvZiBoYW5k
bGluZyBzdWNoIHBhY2tldHMuDQo+IA0KPiBJSVJDIHRoZSByZWFzb24gd2UgaGF2ZSBmZWF0dXJl
LWdzby10Y3B2NCBhbmQgZmVhdHVyZS1nc28tdGNwdjQtcHJlZml4DQo+IGlzIHRoYXQgdGhlIGZv
cm1lciBkaWQgdGhpbmdzIGluIGEgd2F5IHdoaWNoIFdpbmRvd3MgY291bGRuJ3QgY29wZSB3aXRo
Lg0KPiBJIGFzc3VtaW5nIHRoYXQgaXMgdHJ1ZSBmb3IgdjYgdG9vLiBCdXQgY291bGQgTGludXgg
Y29wZSB3aXRoIHRoZSBwcmVmaXgNCj4gdmVyc2lvbiB0b28gZm9yIHY2IGFuZCByZWR1Y2UgdGhl
IG51bWJlciBvZiBvcHRpb25zPyBPciBpcyB0aGUNCj4gbm9uLXByZWZpeCB2YXJpYW50IGFjdHVh
bGx5IGJldHRlciwgaWYgdGhlIGd1ZXN0IGNhbiBtYW5hZ2UsIGZvciBzb21lDQo+IHJlYXNvbj8N
Cj4NCg0KVGhlIG5vbi1wcmVmaXggdmFyaWFudCBhY3R1YWxseSBjb252ZXlzIHR5cGUgaW5mb3Jt
YXRpb24gYW5kIHNvIHdpbGwgYmUgYmV0dGVyIGZvciBmcm9udGVuZHMgdGhhdCBkb24ndCBoYXZl
IHRvIHJlLXBhcnNlIHRoZSBoZWFkZXJzIGFueXdheS4NCg0KICBQYXVsDQogDQo+IEkgc3VwcG9z
ZSBpbiB0aGUgZW5kIGl0cyBhbGwgcGlnZ3liYWNraW5nIG9mZiB0aGUgdjQgY29kZSBwYXRocyBz
bw0KPiBzdXBwb3J0aW5nIGJvdGggaXNuJ3QgYSBoYXJkc2hpcC4NCj4gDQoNCg==
