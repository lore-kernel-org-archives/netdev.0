From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH NEXT 1/2] net: add external loopback test in ethtool
 self test
Date: Thu, 30 Jun 2011 00:26:37 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80FDF180057@MNEXMB2.qlogic.org>
References: <1309243247-15950-1-git-send-email-amit.salecha@qlogic.com>
	 <1309243247-15950-2-git-send-email-amit.salecha@qlogic.com>
 <1309372139.2714.6.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe006.messaging.microsoft.com ([216.32.181.186]:52405
	"EHLO CH1EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754218Ab1F3F0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 01:26:50 -0400
In-Reply-To: <1309372139.2714.6.camel@bwh-desktop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBCZW4gSHV0Y2hpbmdzIFttYWlsdG86Ymh1dGNoaW5nc0Bzb2xhcmZsYXJlLmNvbV0N
Cj4NCj4gU3ViamVjdDogUmU6IFtQQVRDSCBORVhUIDEvMl0gbmV0OiBhZGQgZXh0ZXJuYWwgbG9v
cGJhY2sgdGVzdCBpbg0KPiBldGh0b29sIHNlbGYgdGVzdA0KPiANCj4gPg0KPiA+IFNvIGFkZGlu
ZyBleHBsaWNpdCBmbGFnIGluIGV0aHRvb2wgc2VsZiB0ZXN0LCB3aGljaCB3aWxsIHNwZWNpZnkN
Cj4gaW50ZXJmYWNlDQo+ID4gdG8gcGVyZm9ybSBleHRlcm5hbCBsb29wYmFjayB0ZXN0Lg0KPiAN
Cj4gVGhlIHRyb3VibGUgd2l0aCBhZGRpbmcgZmxhZ3MgdG8gZW51bSBldGh0b29sX3Rlc3RfZmxh
Z3MgaXMgdGhhdCB0aGVyZQ0KPiBpcyByZWFsbHkgbm8gZ2VuZXJhbCB3YXkgdG8gdGVsbCB3aGV0
aGVyIHRoZSBkcml2ZXIgdW5kZXJzdG9vZCB0aGUNCj4gZmxhZy4NCj4gDQo+IEkgdGhpbmsgeW91
IG5lZWQgdG8gYWRkIGEgc2Vjb25kIGZsYWcgd2hpY2ggdGhlIGRyaXZlciBzZXRzIHRvIGNvbmZp
cm0NCj4gdGhhdCBpdCAqZGlkKiB1c2UgZXh0ZXJuYWwgbG9vcGJhY2suDQo+DQoNCklmIEkgdW5k
ZXJzdG9vZCBjb3JyZWN0bHk6DQpZb3UgYXJlIGNvbmNlcm4gYWJvdXQgZHJpdmVzIHdoaWNoIGRv
ZXNuJ3Qgc3VwcG9ydCBleHRlcm5hbCBsb29wYmFjayB0ZXN0Lg0KSW4gdGhpcyBjYXNlIGFwcGxp
Y2F0aW9uIGRvZXNuJ3QgaGF2ZSBubyBnZW5lcmFsIHdheSB0byBrbm93LCB3aGV0aGVyIGRyaXZl
ciBoYXMNCnBlcmZvcm1lZCBleHRlcm5hbCBsb29wYmFjayB0ZXN0Lg0KVGhvdWdoIHRoZSB0ZXN0
IGNhc2Ugd2lsbCBiZSBtZW50aW9uIGluIHRlc3Qgc2V0LiAocmV0dXJuIGJ5IC5nZXRfc3RyaW5n
cykNCg0KSSB3aWxsIGFkZCBpdCBhbmQgc2VuZCByZXZpc2VkIHBhdGNoLg0KDQo+ID4gKy8qDQo+
ID4gKyAqIEZsYWdzIGRlZmluaXRpb24gb2YgZXRodG9vbF90ZXN0DQo+ID4gKyAqDQo+ID4gKyAq
IEVUSF9URVNUX0ZMX09GRkxJTkU6ICBvbmxpbmUgLyBvZmZsaW5lDQo+ID4gKyAqIEVUSF9URVNU
X0ZMX0ZBSUxFRDogdGVzdCBwYXNzZWQgLyBmYWlsZWQNCj4gPiArICogRVRIX1RFU1RfRkxfRVhU
RVJOQUxfTEI6IHBlcmZvcm0gZXh0ZXJuYWwgbG9vcGJhY2sgdGVzdA0KPiA+ICsgKi8NCj4gPiAr
DQo+IA0KPiBSZXBsYWNpbmcgdGhlIGlubGluZSBjb21tZW50cyB3aXRoIGEgYmxvY2sgY29tbWVu
dCBpcyBmaW5lLCBidXQgcGxlYXNlDQo+IHVzZSBrZXJuZWwtZG9jIGZvcm1hdC4NCj4gDQpJIHdp
bGwgZml4IGl0Lg0KDQotQW1pdA0KDQo=

