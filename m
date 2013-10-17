From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen-devel] [PATCH net-next v4 0/5] xen-netback: IPv6 offload
 support
Date: Thu, 17 Oct 2013 08:42:05 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD013B6BE@AMSPEX01CL01.citrite.net>
References: <1381503982-1418-1-git-send-email-paul.durrant@citrix.com>
	 <1381940401.30409.9.camel@kazak.uk.xensource.com>
	 <9AAE0902D5BC7E449B7C8E4E778ABCD013B267@AMSPEX01CL01.citrite.net>
 <1381942838.30409.26.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:54133 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681Ab3JQIm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 04:42:28 -0400
In-Reply-To: <1381942838.30409.26.camel@kazak.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBJYW4gQ2FtcGJlbGwNCj4gU2Vu
dDogMTYgT2N0b2JlciAyMDEzIDE4OjAxDQo+IFRvOiBQYXVsIER1cnJhbnQNCj4gQ2M6IHhlbi1k
ZXZlbEBsaXN0cy54ZW4ub3JnOyBuZXRkZXZAdmdlci5rZXJuZWwub3JnDQo+IFN1YmplY3Q6IFJl
OiBbWGVuLWRldmVsXSBbUEFUQ0ggbmV0LW5leHQgdjQgMC81XSB4ZW4tbmV0YmFjazogSVB2NiBv
ZmZsb2FkDQo+IHN1cHBvcnQNCj4gDQo+IE9uIFdlZCwgMjAxMy0xMC0xNiBhdCAxNzo1MyArMDEw
MCwgUGF1bCBEdXJyYW50IHdyb3RlOg0KPiA+ID4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0N
Cj4gPiA+IEZyb206IElhbiBDYW1wYmVsbA0KPiA+ID4gU2VudDogMTYgT2N0b2JlciAyMDEzIDE3
OjIwDQo+ID4gPiBUbzogUGF1bCBEdXJyYW50DQo+ID4gPiBDYzogeGVuLWRldmVsQGxpc3RzLnhl
bi5vcmc7IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmcNCj4gPiA+IFN1YmplY3Q6IFJlOiBbWGVuLWRl
dmVsXSBbUEFUQ0ggbmV0LW5leHQgdjQgMC81XSB4ZW4tbmV0YmFjazogSVB2Ng0KPiBvZmZsb2Fk
DQo+ID4gPiBzdXBwb3J0DQo+ID4gPg0KPiA+ID4gT24gRnJpLCAyMDEzLTEwLTExIGF0IDE2OjA2
ICswMTAwLCBQYXVsIER1cnJhbnQgd3JvdGU6DQo+ID4gPiA+IFRoaXMgcGF0Y2ggc2VyaWVzIGFk
ZHMgc3VwcG9ydCBmb3IgY2hlY2tzdW0gYW5kIGxhcmdlIHBhY2tldCBvZmZsb2Fkcw0KPiBpbnRv
DQo+ID4gPiA+IHhlbi1uZXRiYWNrLg0KPiA+ID4gPiBUZXN0aW5nIGhhcyBtYWlubHkgYmVlbiBk
b25lIHVzaW5nIHRoZSBNaWNyb3NvZnQgbmV0d29yayBoYXJkd2FyZQ0KPiA+ID4gPiBjZXJ0aWZp
Y2F0aW9uIHN1aXRlIHJ1bm5pbmcgaW4gU2VydmVyIDIwMDhSMiBWTXMgd2l0aCBDaXRyaXggUFYN
Cj4gZnJvbnRlbmRzLg0KPiA+ID4NCj4gPiA+IEFyZSB0aGVyZSBhbnkgTGludXggbmV0ZnJvbnQg
cGF0Y2hlcyBpbiBleGlzdGVuY2UvdGhlIHBpcGVsaW5lIHRvIHRha2UNCj4gPiA+IGFkdmFudGFn
ZSBvZiB0aGlzPw0KPiA+ID4NCj4gPg0KPiA+IEkgd2FzIHdhaXRpbmcgZm9yIHRoZSBiYWNrZW5k
IHBhdGNoZXMgdG8gYmUgYWNjZXB0ZWQgZmlyc3QgOy0pDQo+IA0KPiBJIHRoaW5rIGl0IHdvdWxk
IGJlIHVzZWZ1bCB0byBnZXQgZXQgbGVhc3QgYW4gUkZDIHNvIG90aGVycyBjYW4gdHJ5IGl0DQo+
IGV0Yy4NCj4gDQoNCldlbGwsIGV2ZXJ5b25lIGNhbiBidWlsZCBhbmQgdXNlIHRoZSBXaW5kb3dz
IGZyb250ZW5kIDotKSAoaHR0cHM6Ly9naXRodWIuY29tL3hlbnNlcnZlci93aW4teGVudmlmL3Ry
ZWUvdXBzdHJlYW0pDQoNCkknbGwgdHJ5IHRvIGhhY2sgdXAgc29tZXRoaW5nIGluIHhlbi1uZXRm
cm9udCBzb29uLg0KDQogIFBhdWwNCg==
