From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [net-next v2 6/6] ixgbe: Add malicious driver detection support
Date: Tue, 27 Jun 2017 20:59:25 +0000
Message-ID: <87618083B2453E4A8714035B62D67992B3E89EA6@FMSMSX105.amr.corp.intel.com>
References: <20170627085131.9831-1-jeffrey.t.kirsher@intel.com>
 <20170627085131.9831-7-jeffrey.t.kirsher@intel.com>
 <CAJ3xEMiEjGDUatUv47wNTfYPfCVo62+Jjs-xFU3ccN0iJm-5Gg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
        "Greenwalt, Paul" <paul.greenwalt@intel.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: Or Gerlitz <gerlitz.or@gmail.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43271 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753535AbdF0U71 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Jun 2017 16:59:27 -0400
In-Reply-To: <CAJ3xEMiEjGDUatUv47wNTfYPfCVo62+Jjs-xFU3ccN0iJm-5Gg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogbmV0ZGV2LW93bmVyQHZnZXIua2Vy
bmVsLm9yZyBbbWFpbHRvOm5ldGRldi1vd25lckB2Z2VyLmtlcm5lbC5vcmddIE9uDQo+QmVoYWxm
IE9mIE9yIEdlcmxpdHoNCj5TZW50OiBUdWVzZGF5LCBKdW5lIDI3LCAyMDE3IDI6MDggQU0NCj5U
bzogS2lyc2hlciwgSmVmZnJleSBUIDxqZWZmcmV5LnQua2lyc2hlckBpbnRlbC5jb20+DQo+Q2M6
IERhdmlkIE1pbGxlciA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD47IEdyZWVud2FsdCwgUGF1bA0KPjxw
YXVsLmdyZWVud2FsdEBpbnRlbC5jb20+OyBMaW51eCBOZXRkZXYgTGlzdCA8bmV0ZGV2QHZnZXIu
a2VybmVsLm9yZz47DQo+bmhvcm1hbkByZWRoYXQuY29tOyBzYXNzbWFubkByZWRoYXQuY29tOyBq
b2dyZWVuZUByZWRoYXQuY29tDQo+U3ViamVjdDogUmU6IFtuZXQtbmV4dCB2MiA2LzZdIGl4Z2Jl
OiBBZGQgbWFsaWNpb3VzIGRyaXZlciBkZXRlY3Rpb24NCj5zdXBwb3J0DQo+DQo+T24gVHVlLCBK
dW4gMjcsIDIwMTcgYXQgMTE6NTEgQU0sIEplZmYgS2lyc2hlcg0KPjxqZWZmcmV5LnQua2lyc2hl
ckBpbnRlbC5jb20+IHdyb3RlOg0KPj4gRnJvbTogUGF1bCBHcmVlbndhbHQgPHBhdWwuZ3JlZW53
YWx0QGludGVsLmNvbT4NCj4+DQo+PiBBZGQgbWFsaWNpb3VzIGRyaXZlciBkZXRlY3Rpb24gKE1E
RCkgc3VwcG9ydCBmb3IgWDU1MCwgWDU1MGVtX2EsDQo+PiBhbmQgWDU1MGVtX3ggZGV2aWNlcy4N
Cj4+DQo+PiBNREQgaXMgYSBoYXJkd2FyZSBTUi1JT1Ygc2VjdXJpdHkgZmVhdHVyZSB3aGljaCB0
aGUgZHJpdmVyIGVuYWJsZXMgYnkNCj4+IGRlZmF1bHQsIGJ1dCBjYW4gYmUgY29udHJvbGxlZCBv
bnxvZmYgYnkgZXRodG9vbCBzZXQtcHJpdi1mbGFncw0KPg0KPndhaXQsIHdlIGhhdmUgdGhlIHRy
dXN0ZWQgdmYgY29uY2VwdCwgd2hpY2ggeW91IGltcGxlbWVudA0KPihpeGdiZV9uZG9fc2V0X3Zm
X3RydXN0KQ0KPnNvIHlvdSBjYW4gZW5hYmxlIGJ5IGRlZmF1bHQgZm9yIGFsbCB2ZnMgYW5kIGRp
c2FibGUgaXQgZm9yIHRydXN0ZWQNCj5vbmVzLCB3aHkgY3JlYXRlW10gIGFuIGl4Z2JlIHNwZWNp
YWwgY29uZmlnIGtub2I/IElNSE8gd2Ugc2hvdWxkIG1heCBhbGwgcG9zc2libGUgZWZmb3J0cyB0
bw0KPmF2b2lkIHByaXYgZXRodG9vbCBmbGFncyB1c2FnZS4NCg0KVGhlICJ0cnVzdGVkIiBvcHRp
b24gd2FzIGFkZGVkIHRvIGFsbG93IHVzZSBjYXNlcyB0aGF0IHdlcmUgbm90IHBvc3NpYmxlIGlu
IHRoZQ0KZGVmYXVsdCBkcml2ZXIgY29uZmlndXJhdGlvbiBmb3IgU1JJT1YgKHByb21pc2N1b3Vz
IG1vZGUsIG92ZXJyaWRpbmcgdGhlIE1BQykuDQpXaGlsZSB0aGVzZSBtb2RlcyBjYW4gbGVhZCB0
byBpc3N1ZXMgKHBlcmZvcm1hbmNlIHdpdGggcHJvbWlzYykgdGhleSBjYW4gc3RpbGwNCmJlIHVz
ZWZ1bCBmb3IgY2VydGFpbiBjb25maWd1cmF0aW9ucy4NCg0KTUREIGlzIGEgY29tcGxldGVseSBk
aWZmZXJlbnQgdHlwZSBvZiBwcm90ZWN0aW9uIHRoYXQgaW5jb3Jwb3JhdGVzIGNoZWNrcyBmb3IN
CnF1ZXVlIGNvbnRleHQsIFR4IGRlc2NyaXB0b3JzIGFuZCBvdXQtb2YtYm91bmRzIERNQS9tZW1v
cnkgYWNjZXNzIHRoYXQgY2FuDQpkaXNydXB0IHRoZSBvcGVyYXRpb24gb2YgdGhlIGludGVyZmFj
ZXMuIFlvdSBjYW4gcmVhZCBtb3JlIGFib3V0IGl0IGluIHRoZSBYNTUwDQpkYXRhc2hlZXQgKHNl
Y3Rpb24gNy45LjQuMyBtYWxpY2lvdXMgRHJpdmVyIERldGVjdGlvbik6DQpodHRwczovL3d3dy5p
bnRlbC5jb20vY29udGVudC93d3cvdXMvZW4vZW1iZWRkZWQvcHJvZHVjdHMvbmV0d29ya2luZy9l
dGhlcm5ldC1jb250cm9sbGVyLXg1NTAtZmFtaWx5LWRvY3VtZW50YXRpb24uaHRtbA0KDQpGb3Ig
dGhhdCByZWFzb24gd2UgZG8gbm90IHdhbnQgdG8gbWFrZSBpdCBwYXJ0IG9mIHRoZSAidHJ1c3Rl
ZCIgb3B0aW9uLg0KDQpJbiBhZGRpdGlvbiBNREQgaXMgYSBnbG9iYWwgc2V0dGluZyBhbmQgY2Fu
bm90IGJlIGNvbmZpZ3VyZWQgcGVyLVZGLg0KDQpUaGFua3MsDQpFbWlsDQoNCg==
