From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH v3] net/phy: micrel: Add OF configuration support for
 ksz9021
Date: Mon, 5 Aug 2013 03:03:55 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE015EE4A2@039-SN2MPN1-023.039d.mgd.msft.net>
References: <1375348757-12856-1-git-send-email-xobs@kosagi.com>
 <1375348757-12856-2-git-send-email-xobs@kosagi.com>
 <9848F2DB572E5649BA045B288BE08FBE015ED2F7@039-SN2MPN1-023.039d.mgd.msft.net>
 <5CE77AC80B4242C98833109D6F1C9F85@kosagi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Sascha Hauer <s.hauer@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Steven Rostedt <rostedt@goodmis.org>
To: Sean Cross <xobs@kosagi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0249.outbound.messaging.microsoft.com ([213.199.154.249]:19476
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754296Ab3HEDEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Aug 2013 23:04:04 -0400
In-Reply-To: <5CE77AC80B4242C98833109D6F1C9F85@kosagi.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogU2VhbiBDcm9zcyBbbWFpbHRvOnhvYnNAa29zYWdpLmNvbV0NCkRhdGE6IE1vbmRheSwg
QXVndXN0IDA1LCAyMDEzIDEwOjI0IEFNDQoNCj4gPiA+ICtFeGFtcGxlOg0KPiA+ID4gKyAmZW5l
dCB7DQo+ID4gPiArIG1pY3JlbCxjbGstY29udHJvbC1wYWQtc2tldyA9IDwweGYwZjA+OyAgbWlj
cmVsLHJ4LWRhdGEtcGFkLXNrZXcgPQ0KPiA+ID4gKzwweDAwMDA+OyAgbWljcmVsLHR4LWRhdGEt
cGFkLXNrZXcgPSA8MHhmZmZmPjsgIHN0YXR1cyA9ICJva2F5IjsNCj4gPiA+ICt9Ow0KPiA+ID4g
Kw0KPiA+DQo+ID4NCj4gPg0KPiA+IFRoZSBwaHkgYmluZGluZyBtdXN0IGJlIHRoZSBwaHkgbm9k
ZSwgbm90IHRoZSBldGhlcm5ldCBub2RlLg0KPiA+IFBscyByZWZlciB0bzoNCj4gPiBEb2N1bWVu
dGF0aW9uL2RldmljZXRyZWUvYm9vdGluZy13aXRob3V0LW9mLnR4dA0KPiA+IERvY3VtZW50YXRp
b24vZGV2aWNldHJlZS9iaW5kaW5ncy9uZXQvcGh5LnR4dA0KPiANCj4gVGhpcyB3b24ndCBuZWNl
c3NhcmlseSB3b3JrLiAgSW4gbXkgYm9hcmQsIEkgZG9uJ3QgdGhpbmsgaXQncyBwb3NzaWJsZSB0
bw0KPiBtYW51YWxseSBzcGVjaWZ5IHRoZSBQSFksIGFzIG1vc3Qgb2YgdGhlIGZpZWxkcyByZXF1
aXJlZCBieSB0aGUgT0YgUEhZDQo+IG5vZGUgZG9uJ3QgYXBwbHkgdG8gdGhpcyBkZXZpY2UgKGF0
IGxlYXN0IGFjY29yZGluZyB0byBwaHkudHh0KS4gIFRoZXJlDQo+IGFyZSBubyBpbnRlcnJ1cHRz
LCBubyBpbnRlcnJ1cHQgcGFyZW50LCBhbmQgaXQncyB1bmNsZWFyIHdoYXQgdGhlIHJlZyBvcg0K
PiBsaW51eCxwaGFuZGxlIGZpZWxkcyBkby4gIEFsbCBvZiB0aGVzZSBhcmUgcmVxdWlyZWQgZmll
bGRzLCBub25lIG9mIHdoaWNoDQo+IHNlZW0gdG8gYXBwbHkgdG8gdGhpcyBwYXJ0aWN1bGFyIGJv
YXJkLiAgRnVydGhlcm1vcmUsIGl0IGRvZXNuJ3Qgc2VlbSB0bw0KPiBiZSBwb3NzaWJsZSB0byBz
cGVjaWZ5IGEgcGFydGljdWxhciBQSFksIHN1Y2ggYXMgdGhlIGtzejkwMjEuDQo+IA0KPiBJIHNl
ZSB0aGUgcGF0dGVybiBvZiBnZXR0aW5nIE9GIHNldHRpbmdzIGZyb20gYSBwYXJlbnQncyBub2Rl
IHVzZWQNCj4gZWxzZXdoZXJlIGluIHRoZSBrZXJuZWwuICBGb3IgZXhhbXBsZSwgaW4gbW1jX29m
X3BhcnNlKCksIG9yIG1vcmUNCj4gc2ltaWxhcmx5IGluIHRoZSBjaGlwaWRlYSBjaV9oZHJjX3By
b2JlKCkgZHJpdmVyLg0KDQpZZXMsIHRoZSBwYXRjaCBpcyBvbmx5IHJlYXNvbmFibGUgZm9yIHlv
dXIgcGxhdGZvcm0sIGJ1dCBpdCBpcyB0aGUgcGh5IGRyaXZlciBmb3IgZGlmZmVyZW50IHBsYXRm
b3JtcyB0aGF0IHlvdSBtdXN0IGNvbnNpZGVyYXRlLg0KUGxlYXNlIGFkZCBtb3JlIGV4YW1wbGUg
Y2FzZXMgaW4gYmluZGluZyBkb2MuDQoNCg==
