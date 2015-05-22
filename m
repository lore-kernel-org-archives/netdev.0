From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [PATCH v5 3/3] ixgbe: Add new ndo to trust VF
Date: Fri, 22 May 2015 15:07:33 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A07892F9481@ORSMSX108.amr.corp.intel.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05EB28F4@BPXM14GP.gisp.nec.co.jp>
 <F6FB0E698C9B3143BDF729DF22286646912FB5E4@ORSMSX110.amr.corp.intel.com>
 <7F861DC0615E0C47A872E6F3C5FCDDBD05EB3B4A@BPXM14GP.gisp.nec.co.jp>
 <F6FB0E698C9B3143BDF729DF22286646912FBBEC@ORSMSX110.amr.corp.intel.com>
 <7F861DC0615E0C47A872E6F3C5FCDDBD05EB4EE6@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "nhorman@redhat.com" <nhorman@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	Rony Efraim <ronye@mellanox.com>,
	"David Miller" <davem@davemloft.net>,
	Edward Cree <ecree@solarflare.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:61700 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756048AbbEVPHn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2015 11:07:43 -0400
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05EB4EE6@BPXM14GP.gisp.nec.co.jp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQo+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+IEZyb206IEludGVsLXdpcmVkLWxhbiBb
bWFpbHRvOmludGVsLXdpcmVkLWxhbi1ib3VuY2VzQGxpc3RzLm9zdW9zbC5vcmddIE9uDQo+IEJl
aGFsZiBPZiBIaXJvc2hpIFNoaW1hbW90bw0KPiBTZW50OiBUaHVyc2RheSwgTWF5IDIxLCAyMDE1
IDc6MzEgUE0NCj4gVG86IFNraWRtb3JlLCBEb25hbGQgQzsgS2lyc2hlciwgSmVmZnJleSBUOyBp
bnRlbC13aXJlZC0NCj4gbGFuQGxpc3RzLm9zdW9zbC5vcmcNCj4gQ2M6IG5ob3JtYW5AcmVkaGF0
LmNvbTsgam9ncmVlbmVAcmVkaGF0LmNvbTsgTGludXggTmV0ZGV2IExpc3Q7IENob2ksIFN5DQo+
IEpvbmc7IFJvbnkgRWZyYWltOyBEYXZpZCBNaWxsZXI7IEVkd2FyZCBDcmVlOyBPciBHZXJsaXR6
Ow0KPiBzYXNzbWFubkByZWRoYXQuY29tDQo+IFN1YmplY3Q6IFJlOiBbSW50ZWwtd2lyZWQtbGFu
XSBbUEFUQ0ggdjUgMy8zXSBpeGdiZTogQWRkIG5ldyBuZG8gdG8gdHJ1c3QNCj4gVkYNCj4gDQoN
CltiaWcgc25pcF0NCg0KPiBJIHRoaW5rIHlvdXIgY29uY2VybnMgYXJlIHJlbGF0ZWQgdG8gc29t
ZSBvcGVyYXRpb25hbCBhc3N1bXB0aW9ucy4NCj4gTXkgYmFzaWMgY29uY2VwdCBpcywgbm90IHRv
IGNoYW5nZSB0aGUgYmVoYXZpb3Igb2YgVk0sIGV4aXN0aW5nIHVzZXINCj4gb3BlcmF0aW9uLg0K
PiBJIG1lYW4gdGhhdCBJIGRpZG4ndCB0aGluayBpdCdzIGJldHRlciB0aGF0IHRoZSB1c2VyIHNo
b3VsZCBjaGVjayB0aGUgYm90aA0KPiBvZiB0aGUgaXhnYmV2ZiBkcml2ZXIgY2FuIGRlYWwgd2l0
aCBuZXcgQVBJIGFuZCB0aGUgVkYgaXMgdHJ1c3RlZC4NCj4gDQo+IE5vdywgSSB0aGluayB0aGUg
cG9pbnQgaXMgd2hvIHRha2VzIGNhcmUgd2hldGhlciB0aGUgVkYgaXMgdHJ1c3RlZC4gUmlnaHQ/
DQo+IEl0IHNlZW1zIHRoYXQgeW91IHRoaW5rIHRoZSBWRiB1c2VyIHNob3VsZCBoYW5kbGUgdGhh
dCB1c2VyIGlzIHRydXN0ZWQgYW5kDQo+IGRvIHNvbWV0aGluZyB3aXRoIGEgbm90aWNlIHRoYXQg
InlvdSdyZSB0cnVzdGVkIG9yIHVudHJ1c3RlZCIgZnJvbSB0aGUNCj4gaG9zdC4NCj4gSXMgdGhh
dCBjb3JyZWN0Pw0KPiBJIG1hZGUgaXQgaW4gUEYgc2lkZSwgYmVjYXVzZSBpdCBsb29rcyBlYXN5
IHRvIGhhbmRsZSBpdC4gSWYgc29tZXRoaW5nIHRvDQo+IGRvIGluIFZGIHNpZGUsIEkgdGhpbmsg
aXhnYmV2ZiBkcml2ZXIgc2hvdWxkIGhhbmRsZSBpdC4NCg0KU2V0dGluZyB0aGUgVkYgdHJ1c3Rl
ZCBtb2RlIGZlYXR1cmUgc2hvdWxkIG9ubHkgYmUgYWxsb3dlZCB0aHJvdWdoIHRoZSBQRiBhcyBp
dCBpcyB0aGUgb25seSB0cnVzdGVkIGVudGl0eSBmcm9tIHRoZSBzdGFydC4gIFdlIGRvIG5vdCB3
YW50IHRoZSBWRiBiZWluZyBhYmxlIHRvIGRlY2lkZSBmb3IgaXRzZWxmIHRvIGJlIHRydXN0ZWQu
DQoNCi0gR3JlZw0KDQo+IA0KPiB0aGFua3MsDQo+IEhpcm9zaGkNCj4gDQo+IF9fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fDQo+IEludGVsLXdpcmVkLWxhbiBt
YWlsaW5nIGxpc3QNCj4gSW50ZWwtd2lyZWQtbGFuQGxpc3RzLm9zdW9zbC5vcmcNCj4gaHR0cDov
L2xpc3RzLm9zdW9zbC5vcmcvbWFpbG1hbi9saXN0aW5mby9pbnRlbC13aXJlZC1sYW4NCg==
