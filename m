From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [PATCH] e1000e: workaround missing power down mii control bit
 on 82571
Date: Thu, 16 Dec 2010 11:28:18 -0800
Message-ID: <8DD2590731AB5D4C9DBF71A877482A9001773F76C4@orsmsx509.amr.corp.intel.com>
References: <20101216182847.GA14985@ajones-laptop.nbttech.com>
 <1292525797.3253.8.camel@bwh-desktop>
 <8DD2590731AB5D4C9DBF71A877482A9001773F7655@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Arthur Jones <ajones@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:55133 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750815Ab0LPTbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Dec 2010 14:31:15 -0500
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A9001773F7655@orsmsx509.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogbmV0ZGV2LW93bmVyQHZnZXIua2Vy
bmVsLm9yZyBbbWFpbHRvOm5ldGRldi1vd25lckB2Z2VyLmtlcm5lbC5vcmddIE9uDQo+QmVoYWxm
IE9mIEFsbGFuLCBCcnVjZSBXDQo+U2VudDogVGh1cnNkYXksIERlY2VtYmVyIDE2LCAyMDEwIDEx
OjA0IEFNDQo+VG86IEJlbiBIdXRjaGluZ3M7IEFydGh1ciBKb25lcw0KPkNjOiBLaXJzaGVyLCBK
ZWZmcmV5IFQ7IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmcNCj5TdWJqZWN0OiBSRTogW1BBVENIXSBl
MTAwMGU6IHdvcmthcm91bmQgbWlzc2luZyBwb3dlciBkb3duIG1paSBjb250cm9sIGJpdCBvbg0K
PjgyNTcxDQo+DQo+Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+PkZyb206IG5ldGRldi1v
d25lckB2Z2VyLmtlcm5lbC5vcmcgW21haWx0bzpuZXRkZXYtb3duZXJAdmdlci5rZXJuZWwub3Jn
XSBPbg0KPj5CZWhhbGYgT2YgQmVuIEh1dGNoaW5ncw0KPj5TZW50OiBUaHVyc2RheSwgRGVjZW1i
ZXIgMTYsIDIwMTAgMTA6NTcgQU0NCj4+VG86IEFydGh1ciBKb25lcw0KPj5DYzogS2lyc2hlciwg
SmVmZnJleSBUOyBuZXRkZXZAdmdlci5rZXJuZWwub3JnDQo+PlN1YmplY3Q6IFJlOiBbUEFUQ0hd
IGUxMDAwZTogd29ya2Fyb3VuZCBtaXNzaW5nIHBvd2VyIGRvd24gbWlpIGNvbnRyb2wgYml0IG9u
DQo+PjgyNTcxDQo+Pg0KPj5BZGRpbmcgdGhpcyBzcGVjaWFsIGNhc2UgaW50byBNRElPIGFjY2Vz
cyBzZWVtcyBsaWtlIGEgcmVhbGx5IG5hc3R5DQo+PmhhY2suICBTdXJlbHkgdGhlIGNhbGxlcnMg
dGhhdCBzZXQgdGhlIGNvbnRyb2wgcmVnaXN0ZXIgc2hvdWxkIHRha2UgY2FyZQ0KPj5vZiB0aGlz
Lg0KPj4NCj4+QmVuLg0KPg0KPkFncmVlZC4gIEkgYW0gc2V0dGluZyB1cCB0byByZXBybyBub3cg
dG8gc2VlIGlmIGl0IGlzIGFuIGFjdHVhbCBoYXJkd2FyZQ0KPmlzc3VlIG9yIGp1c3QgYSBzb2Z0
d2FyZSBidWc7IGVpdGhlciB3YXksIHRoaXMgcGF0Y2ggaXMgbm90IHRoZSBjb3JyZWN0DQo+YXBw
cm9hY2ggYW5kIEknbGwgZm9sbG93IHVwIHNob3J0bHkuDQo+DQo+QnJ1Y2UuDQoNCkl0J3MgdGhl
IHJlc2V0IGluIGUxMDAwX3NldF9zZXR0aW5ncygpIHdoaWNoIGlnbm9yZXMgdGhhdCB3ZSBoYWQg
cHJldmlvdXNseQ0KcG93ZXJlZCBvZmYgdGhlIFBoeS4gIEknbGwgZ28gdGhyb3VnaCB0aGUgcmVz
dCBvZiB0aGUgY29kZSBhbmQgZml4IHVwIHRoaXMNCmFuZCBhbnkgb3RoZXIgb2NjdXJyZW5jZXMg
b2Ygc2ltaWxhciBpc3N1ZXMgcHJvcGVybHkuDQoNClRoYW5rcyBmb3IgcmVwb3J0aW5nIHRoaXMg
aXNzdWUgQXJ0aHVyLg0KDQpCcnVjZS4NCg==
