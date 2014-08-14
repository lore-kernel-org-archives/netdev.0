From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH net] macvlan: Fix the bug when destroy macvlan dev port
Date: Thu, 14 Aug 2014 20:32:43 +0000
Message-ID: <1408048363.20929.1.camel@jekeller-desk1.amr.corp.intel.com>
References: <53EC7D8C.6060908@huawei.com>
	 <CAHA+R7MarK5Jx4ZVmyAnQp-DZ6aRNi=rqd3aKBW7OnB8YWsrbQ@mail.gmail.com>
	 <1408037910.6804.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "dingtianhong@huawei.com" <dingtianhong@huawei.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"cwang@twopensource.com" <cwang@twopensource.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:38607 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753629AbaHNUcp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 16:32:45 -0400
In-Reply-To: <1408037910.6804.22.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Content-ID: <2B471525DE6EE048BB7AB1ACEEF653C8@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVGh1LCAyMDE0LTA4LTE0IGF0IDEwOjM4IC0wNzAwLCBFcmljIER1bWF6ZXQgd3JvdGU6DQo+
IE9uIFRodSwgMjAxNC0wOC0xNCBhdCAwOTo1OCAtMDcwMCwgQ29uZyBXYW5nIHdyb3RlOg0KPiA+
IE9uIFRodSwgQXVnIDE0LCAyMDE0IGF0IDI6MTIgQU0sIERpbmcgVGlhbmhvbmcgPGRpbmd0aWFu
aG9uZ0BodWF3ZWkuY29tPiB3cm90ZToNCj4gPiA+DQo+ID4gPiBUbyBmaXggdGhpcyBwcm9ibGVt
LCB3ZSBuZWVkIHRvIGNoZWNrIHdoZXRoZXIgdGhlIHBvcnQgaXMgZXhpc3Qgd2hlbiBjYWxsaW5n
DQo+ID4gPiBtYWN2bGFuX3BvcnRfZGVzdHJveSgpLCBkbyBub3RoaW5nIGlmIHRoZSBwb3J0IGhh
cyBiZWVuIGRlc3Ryb3llZCB5ZXQuDQo+ID4gPg0KPiA+IA0KPiA+IEFzIEkgc2FpZCwgdGhpcyB3
aWxsIG1ha2UgdGhlIGZpcnN0IGNhbGwgb2YgbWFjdmxhbl9wb3J0X2Rlc3Ryb3koKQ0KPiA+IGZy
ZWUgdGhlIHBvcnQsDQo+ID4gd2hpY2ggd2FzIGZyZWVkIGJ5IHRoZSBsYXN0IG9uZSBiZWZvcmUu
DQo+ID4gDQo+ID4gV2h5IG5vdCBqdXN0IHJldmVydCB5b3VyIGNoYW5nZT8gSXQgZG9lc24ndCBn
aXZlIGFueSBiZW5lZml0Lg0KPiA+IC0tDQo+IA0KPiBZZXMgcGxlYXNlLCBJIHRoaW5rIHBhdGNo
IHNob3VsZCBiZSByZXZlcnRlZC4NCj4gDQo+IA0KDQpBcyBmYXIgYXMgSSBjYW4gdGVsbCBmcm9t
IHRoZSBvcmlnaW5hbCBwYXRjaCwgdGhlIG9ubHkgYWR2YW50YWdlIGl0IGhhcw0KaXMgdGhlIHJl
bW92YWwgb2YgYSBzaW5nbGUgaW50IGZyb20gYSBzdHJ1Y3R1cmUgc2l6ZS4gSSdtIG5vdCBzdXJl
DQp0aGF0J3MgdmVyeSBhZHZhbnRhZ2VvdXMuDQoNClRoZSBvdGhlciBmaXggSSBzYXcgbWlnaHQg
d29yayBpcyBtb3ZlIHRoZSBsaXN0X2RlbCBzbyB0aGF0IHZsYW5zIGlzDQplbXB0aWVkIGluc2lk
ZSB1bmluaXQgaW5zdGVhZCBvZiBkZWxsaW5rLiBUaGlzIHdvdWxkIGJlIHRoZSBzYW1lIHBsYWNl
DQp0aGF0IGNvdW50IHdhcyBkZWNyZW1lbnRlZC4gSG93ZXZlciwgSSB0aGluayB0aGlzIGhhcyBt
YW55IHBvdGVudGlhbA0Kc2lkZSBlZmZlY3RzLCBhbmQgaXMgbm90IHdvcnRoIHRoZSBzYXZpbmcg
b2YgYSBzaW5nbGUgaW50ZWdlcidzIHdvcnRoIG9mDQpzcGFjZSBmcm9tIGEgc3RydWN0dXJlLg0K
DQpUaGFua3MsDQpKYWtlDQo=
