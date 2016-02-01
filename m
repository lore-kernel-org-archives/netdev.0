From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: ixgbe: get link speed as a slave nic unrelated with link
Date: Mon, 1 Feb 2016 15:53:33 +0000
Message-ID: <87618083B2453E4A8714035B62D67992505210DB@FMSMSX105.amr.corp.intel.com>
References: <1452258030-63996-5-git-send-email-jeffrey.t.kirsher@intel.com>
 <1454311675-24676-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: "zyjzyj2000@gmail.com" <zyjzyj2000@gmail.com>,
	"Schmitt, Phillip J" <phillip.j.schmitt@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Shteinbock, Boris (Wind River)" <boris.shteinbock@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:2340 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751287AbcBAPxf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2016 10:53:35 -0500
In-Reply-To: <1454311675-24676-1-git-send-email-zyjzyj2000@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogenlqenlqMjAwMEBnbWFpbC5jb20g
W21haWx0bzp6eWp6eWoyMDAwQGdtYWlsLmNvbV0NCj5TZW50OiBTdW5kYXksIEphbnVhcnkgMzEs
IDIwMTYgMTE6MjggUE0NCj5UbzogenlqenlqMjAwMEBnbWFpbC5jb207IFRhbnRpbG92LCBFbWls
IFM7IFNjaG1pdHQsIFBoaWxsaXAgSjsgS2lyc2hlciwNCj5KZWZmcmV5IFQ7IG5ldGRldkB2Z2Vy
Lmtlcm5lbC5vcmc7IGUxMDAwLWRldmVsQGxpc3RzLnNvdXJjZWZvcmdlLm5ldDsNCj5TaHRlaW5i
b2NrLCBCb3JpcyAoV2luZCBSaXZlcikNCj5TdWJqZWN0OiBpeGdiZTogZ2V0IGxpbmsgc3BlZWQg
YXMgYSBzbGF2ZSBuaWMgdW5yZWxhdGVkIHdpdGggbGluaw0KPg0KPg0KPkhpLCBFbWlsDQo+DQo+
VGhhbmtzIGZvciB5b3VyIHBhdGNoLg0KPkFmdGVyIEkgYXBwbGllZCB5b3VyIHBhdGNoLCB0aGUg
Zm9sbG93aW5nIGFyZSB0aGUgZmVlZGJhY2sgZnJvbSBteSB1c2Vycy4NCj4NCj4iDQo+VXNlcnMg
aGFkIHRlc3RlZCB0aGUgbGF0ZXN0IHBhdGNoIHRoYXQgeW91IHByb3ZpZGVkIGFuZCBpdCBpcyBt
dWNoIGltcHJvdmVkDQo+bm93LiBIb3dldmVyIGl04oCZcyBzdGlsbCBub3QgZ29vZCBlbm91Z2gg
YXMgdGhlIHVzZXJzIGFyZSBwbGFubmluZyBmaWVsZA0KPmRlcGxveW1lbnQuIEhlcmUgYXJlIHRo
ZWlyIGZpbmRpbmdzOg0KPg0KPlNvIGNsb3NlLCBidXQgbm90IHF1aXRlIDEwMCUuIEkgZGlkIHJ1
biBvdmVyIDI1MDAgcmUtbmVnb3RpYXRpb25zIG9uIG9uZQ0KPmludGVyZmFjZSBvZiBhIGJvbmRl
ZCBwYWlyIGFuZCBnb3QgdGhlIDAgTUJwcyBzdGF0dXMgdG90YWwgb2YgdGhyZWUgdGltZXMuDQo+
VGhlIGxvbmdlc3QgcnVuIHdpdGhvdXQgc2luZ2xlIGVycm9yIHdhcyBzb21ldGhpbmcgbGlrZSAx
ODAwIHJlLQ0KPm5lZ290aWF0aW9ucyBvciBzby4gU28sIHRoaXMgdmVyc2lvbiBzZWVtcyB0byBp
bXByb3ZlIHRoZSBzaXR1YXRpb24NCj5pbW1lbnNlbHkgKHRoZSB1bnBhdGNoZWQgZHJpdmVyIGZh
aWxzIGxpa2UgMjUlIG9mIHRoZSB0aW1lKSwgYnV0IHRoZXJlDQo+c3RpbGwgc2VlbXMgdG8gcmVt
YWluIHNvbWUgdGlueSByYWNlIHNvbWV3aGVyZS4NCg0KWWVzIGF0IHRoZSB0aW1lIG9mIHRoZSBi
b25kaW5nIGludGVyZmFjZSBjb21pbmcgdXAgdGhlcmUgY2FuIGJlIGEgbWVzc2FnZSBhYm91dCAw
IE1icHMgaW4gZG1lc2csDQpob3dldmVyIHRoZSBhY3R1YWwgYm9uZCBvbmNlIGZ1bGx5IHVwIHdp
bGwgaGF2ZSB0aGUgY29ycmVjdCBzcGVlZHMgYXMgc2VlbiBieToNCiNjYXQgL3Byb2MvbmV0L2Jv
bmRpbmcvYm9uZDANCg0KVGhhbmtzLA0KRW1pbA0KDQoNCg==
