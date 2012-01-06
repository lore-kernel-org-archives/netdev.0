From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [net-next 08/11] e1000e: add Receive Packet Steering (RPS)
 support
Date: Fri, 6 Jan 2012 17:22:43 +0000
Message-ID: <804857E1F29AAC47BF68C404FC60A18403B8ED@ORSMSX102.amr.corp.intel.com>
References: <1325618356-2655-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1325618356-2655-9-git-send-email-jeffrey.t.kirsher@intel.com>
 <1325624728.2832.12.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7375 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752395Ab2AFRWr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jan 2012 12:22:47 -0500
In-Reply-To: <1325624728.2832.12.camel@bwh-desktop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogQmVuIEh1dGNoaW5ncyBbbWFpbHRv
OmJodXRjaGluZ3NAc29sYXJmbGFyZS5jb21dDQo+U2VudDogVHVlc2RheSwgSmFudWFyeSAwMywg
MjAxMiAxOjA1IFBNDQo+VG86IEtpcnNoZXIsIEplZmZyZXkgVA0KPkNjOiBkYXZlbUBkYXZlbWxv
ZnQubmV0OyBBbGxhbiwgQnJ1Y2UgVzsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsNCj5nb3Nwb0By
ZWRoYXQuY29tOyBzYXNzbWFubkByZWRoYXQuY29tDQo+U3ViamVjdDogUmU6IFtuZXQtbmV4dCAw
OC8xMV0gZTEwMDBlOiBhZGQgUmVjZWl2ZSBQYWNrZXQgU3RlZXJpbmcgKFJQUykgc3VwcG9ydA0K
Pg0KPk9uIFR1ZSwgMjAxMi0wMS0wMyBhdCAxMToxOSAtMDgwMCwgSmVmZiBLaXJzaGVyIHdyb3Rl
Og0KPj4gRnJvbTogQnJ1Y2UgQWxsYW4gPGJydWNlLncuYWxsYW5AaW50ZWwuY29tPg0KPj4NCj4+
IEVuYWJsZSBSUFMgYnkgZGVmYXVsdC4gIERpc2FsbG93IGp1bWJvIGZyYW1lcyB3aGVuIGJvdGgg
cmVjZWl2ZSBjaGVja3N1bQ0KPj4gYW5kIHJlY2VpdmUgaGFzaGluZyBhcmUgZW5hYmxlZCBiZWNh
dXNlIHRoZSBoYXJkd2FyZSBjYW5ub3QgZG8gYm90aCBJUA0KPj4gcGF5bG9hZCBjaGVja3N1bSAo
ZW5hYmxlZCB3aGVuIHJlY2VpdmUgY2hlY2tzdW0gaXMgZW5hYmxlZCB3aGVuIHVzaW5nDQo+PiBw
YWNrZXQgc3BsaXQgd2hpY2ggaXMgdXNlZCBmb3IganVtYm8gZnJhbWVzKSBhbmQgcHJvdmlkZSBS
U1MgaGFzaCBhdCB0aGUNCj4+IHNhbWUgdGltZS4NCj5bLi4uXQ0KPg0KPlRoaXMgZG9lc24ndCBz
ZWVtIHRvIGhhdmUgbXVjaCB0byBkbyB3aXRoIFJQUy4gIFJQUyBjYW4gdXNlIGEgaGFyZHdhcmUN
Cj5oYXNoIGJ1dCBkb2Vzbid0IHJlcXVpcmUgaXQuDQo+DQo+WW91IHNob3VsZCBhbHNvIGltcGxl
bWVudCB0aGUgZXRodG9vbCBjb21tYW5kIHRvIHF1ZXJ5IGZsb3cgaGFzaGluZw0KPmJlaGF2aW91
ciAoRVRIVE9PTF9HUlhGSCBjb21tYW5kLCBnZXRfcnhuZmMgb3BlcmF0aW9uKS4NCj4NCj5CZW4u
DQo+DQo+LS0NCj5CZW4gSHV0Y2hpbmdzLCBTdGFmZiBFbmdpbmVlciwgU29sYXJmbGFyZQ0KPk5v
dCBzcGVha2luZyBmb3IgbXkgZW1wbG95ZXI7IHRoYXQncyB0aGUgbWFya2V0aW5nIGRlcGFydG1l
bnQncyBqb2IuDQo+VGhleSBhc2tlZCB1cyB0byBub3RlIHRoYXQgU29sYXJmbGFyZSBwcm9kdWN0
IG5hbWVzIGFyZSB0cmFkZW1hcmtlZC4NCg0KVGhhbmtzIGZvciB0aGUgZmVlZGJhY2sgQmVuLiAg
T25lIHF1ZXN0aW9uOiBpcyB0aGUgZGF0YSByZXR1cm5lZCBmcm9tDQphbiBFVEhUT09MX0dSWEZI
IGNvbW1hbmQgd2l0aCB0aGUgZ2V0X3J4bmZjIG9wZXJhdGlvbiBzdXBwb3NlZCB0byBiZQ0KdGhl
IGRlZmF1bHQgZm9yIHRoZSBkZXZpY2Ugb3IgdGhlIGN1cnJlbnQgc2V0dGluZz8NCg0KVGhhbmtz
LA0KQnJ1Y2UuDQo=
