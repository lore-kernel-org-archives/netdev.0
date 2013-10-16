From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen-devel] [PATCH net-next v4 0/5] xen-netback: IPv6 offload
 support
Date: Wed, 16 Oct 2013 16:53:31 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD013B267@AMSPEX01CL01.citrite.net>
References: <1381503982-1418-1-git-send-email-paul.durrant@citrix.com>
 <1381940401.30409.9.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:55561 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932550Ab3JPQyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 12:54:55 -0400
In-Reply-To: <1381940401.30409.9.camel@kazak.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBJYW4gQ2FtcGJlbGwNCj4gU2Vu
dDogMTYgT2N0b2JlciAyMDEzIDE3OjIwDQo+IFRvOiBQYXVsIER1cnJhbnQNCj4gQ2M6IHhlbi1k
ZXZlbEBsaXN0cy54ZW4ub3JnOyBuZXRkZXZAdmdlci5rZXJuZWwub3JnDQo+IFN1YmplY3Q6IFJl
OiBbWGVuLWRldmVsXSBbUEFUQ0ggbmV0LW5leHQgdjQgMC81XSB4ZW4tbmV0YmFjazogSVB2NiBv
ZmZsb2FkDQo+IHN1cHBvcnQNCj4gDQo+IE9uIEZyaSwgMjAxMy0xMC0xMSBhdCAxNjowNiArMDEw
MCwgUGF1bCBEdXJyYW50IHdyb3RlOg0KPiA+IFRoaXMgcGF0Y2ggc2VyaWVzIGFkZHMgc3VwcG9y
dCBmb3IgY2hlY2tzdW0gYW5kIGxhcmdlIHBhY2tldCBvZmZsb2FkcyBpbnRvDQo+ID4geGVuLW5l
dGJhY2suDQo+ID4gVGVzdGluZyBoYXMgbWFpbmx5IGJlZW4gZG9uZSB1c2luZyB0aGUgTWljcm9z
b2Z0IG5ldHdvcmsgaGFyZHdhcmUNCj4gPiBjZXJ0aWZpY2F0aW9uIHN1aXRlIHJ1bm5pbmcgaW4g
U2VydmVyIDIwMDhSMiBWTXMgd2l0aCBDaXRyaXggUFYgZnJvbnRlbmRzLg0KPiANCj4gQXJlIHRo
ZXJlIGFueSBMaW51eCBuZXRmcm9udCBwYXRjaGVzIGluIGV4aXN0ZW5jZS90aGUgcGlwZWxpbmUg
dG8gdGFrZQ0KPiBhZHZhbnRhZ2Ugb2YgdGhpcz8NCj4gDQoNCkkgd2FzIHdhaXRpbmcgZm9yIHRo
ZSBiYWNrZW5kIHBhdGNoZXMgdG8gYmUgYWNjZXB0ZWQgZmlyc3QgOy0pDQoNCiAgUGF1bA0KDQo+
ID4NCj4gPiB2MjoNCj4gPiAtIEZpeGVkIFdlaSdzIGVtYWlsIGFkZHJlc3MgaW4gQ2MgbGluZXMN
Cj4gPg0KPiA+IHYzOg0KPiA+IC0gUmVzcG9uZGVkIHRvIFdlaSdzIGNvbW1lbnRzOg0KPiA+ICAt
IG5ldGlmLmggbm93IHVwZGF0ZWQgd2l0aCBjb21tZW50cyBhbmQgYSBkZWZpbml0aW9uIG9mDQo+
ID4gICAgWEVOX05FVElGX0dTT19UWVBFX05PTkUuDQo+ID4gIC0gbGltaXRlZCBudW1iZXIgb2Yg
cHVsbHVwcw0KPiA+IC0gUmVzcG9uZGVkIHRvIEFubmllJ3MgY29tbWVudHM6DQo+ID4gIC0gTmV3
IEdTT19CSVQgbWFjcm8NCj4gPg0KPiA+IHY0Og0KPiA+IC0gUmVzcG9uZGVkIHRvIG1vcmUgb2Yg
V2VpJ3MgY29tbWVudHMNCj4gPiAtIFJlbW92ZSBwYXJzaW5nIG9mIElQdjYgZnJhZ21lbnQgaGVh
ZGVyIGFuZCBhZGRlZCB3YXJuaW5nDQo+ID4NCj4gPg0KPiA+IF9fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fDQo+ID4gWGVuLWRldmVsIG1haWxpbmcgbGlzdA0K
PiA+IFhlbi1kZXZlbEBsaXN0cy54ZW4ub3JnDQo+ID4gaHR0cDovL2xpc3RzLnhlbi5vcmcveGVu
LWRldmVsDQo+IA0KDQo=
