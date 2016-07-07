From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen-devel] [PATCH] xen-netback: correct return value checks on
 xenbus_scanf()
Date: Thu, 7 Jul 2016 10:55:28 +0000
Message-ID: <d0df3b813db94858ab608bd33216c2d9@AMSPEX02CL03.citrite.net>
References: <577E277C02000078000FBEBB@prv-mh.provo.novell.com>
 <577E27B8.2050603@citrix.com> <20160707103513.GB416@citrix.com>
 <577E32BF.9050007@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"Jan Beulich" <JBeulich@suse.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:60279 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756241AbcGGKzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 06:55:36 -0400
In-Reply-To: <577E32BF.9050007@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBuZXRkZXYtb3duZXJAdmdlci5r
ZXJuZWwub3JnIFttYWlsdG86bmV0ZGV2LQ0KPiBvd25lckB2Z2VyLmtlcm5lbC5vcmddIE9uIEJl
aGFsZiBPZiBEYXZpZCBWcmFiZWwNCj4gU2VudDogMDcgSnVseSAyMDE2IDExOjQ1DQo+IFRvOiBX
ZWkgTGl1OyBEYXZpZCBWcmFiZWwNCj4gQ2M6IHhlbi1kZXZlbEBsaXN0cy54ZW5wcm9qZWN0Lm9y
ZzsgSmFuIEJldWxpY2g7IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmcNCj4gU3ViamVjdDogUmU6IFtY
ZW4tZGV2ZWxdIFtQQVRDSF0geGVuLW5ldGJhY2s6IGNvcnJlY3QgcmV0dXJuIHZhbHVlIGNoZWNr
cw0KPiBvbiB4ZW5idXNfc2NhbmYoKQ0KPiANCj4gT24gMDcvMDcvMTYgMTE6MzUsIFdlaSBMaXUg
d3JvdGU6DQo+ID4gT24gVGh1LCBKdWwgMDcsIDIwMTYgYXQgMTA6NTg6MTZBTSArMDEwMCwgRGF2
aWQgVnJhYmVsIHdyb3RlOg0KPiA+PiBPbiAwNy8wNy8xNiAwODo1NywgSmFuIEJldWxpY2ggd3Jv
dGU6DQo+ID4+PiBPbmx5IGEgcG9zaXRpdmUgcmV0dXJuIHZhbHVlIGluZGljYXRlcyBzdWNjZXNz
Lg0KPiA+Pg0KPiA+PiBUaGlzIGlzIG5vdCBjb3JyZWN0Lg0KPiA+Pg0KPiA+DQo+ID4gRG8geW91
IG1lYW4gdGhlIGNvbW1pdCBtZXNzYWdlIGlzIG5vdCBjb3JyZWN0IG9yIHRoZSBjb2RlIGlzIG5v
dA0KPiA+IGNvcnJlY3Q/IElmIGl0IGlzIHRoZSBmb3JtYWwsIGRvIHlvdSBoYXZlIGFueSBzdWdn
ZXN0aW9uIHRvIGZpeCBpdD8NCj4gDQo+IFRoaXMgY29kZSBpcyBjb3JyZWN0IGFzLWlzLCB0aHVz
IHRoZSBjb21taXQgbWVzc2FnZSBpcyB3cm9uZyBvciBtaXNsZWFkaW5nLg0KPiANCg0KSXMgdGhh
dCB0cnVlPyBKYW4gaXMgY29ycmVjdCBpbiBzYXlpbmcgdGhhdCBvbmx5ID4wIGlzIGFuIGluZGlj
YXRvciBvZiBzdWNjZXNzIGFjY29yZGluZyB0byB0aGUgdXN1YWwgc2VtYW50aWNzIG9mIHNjY2Fu
ZigpLiBQZXJzb25hbGx5IEkgdGhpbmsgdGhlIGNvZGUgd291bGQgYmUgY2xlYXJlciBpZiB0aGUg
Y2hlY2tzIGZvciBmYWlsdXJlIHdlcmUgPCAxIHJhdGhlciB0aGFuIDw9IDAuDQoNCiAgUGF1bA0K
DQo+IERhdmlkDQo=
