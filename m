From: "Zou, Yi" <yi.zou@intel.com>
Subject: RE: [PATCH net-next-2.6] net: propagate NETIF_F_HIGHDMA to vlans
Date: Thu, 23 Sep 2010 09:30:03 -0700
Message-ID: <7C88852EF6F99F4EB538472FCFEBE222013DAB2152@orsmsx509.amr.corp.intel.com>
References: <20100923035755.11561.14170.stgit@localhost.localdomain>
	 <20100922.212023.91330415.davem@davemloft.net>
	 <1285219690.2380.70.camel@edumazet-laptop>
	 <AANLkTikDdxFho2ioBHMbze685+garDWF9kF3qFXZA9Hr@mail.gmail.com>
	 <1285222405.2380.80.camel@edumazet-laptop>
 <1285238771.2864.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59508 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754619Ab0IWQa3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Sep 2010 12:30:29 -0400
In-Reply-To: <1285238771.2864.38.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiANCj4gQXV0b21hdGljYWxseSBhbGxvd3MgdmxhbnMgdG8gZ2V0IE5FVElGX0ZfSElHSERNQSBp
ZiB1bmRlcmx5aW5nIGRldmljZQ0KPiBzdXBwb3J0cyBpdC4NCj4gDQo+IE9uIDMyYml0IGFyY2hl
cyAoYW5kIG1vcmUgcHJlY2lzZWx5IGlmIENPTkZJR19ISUdITUVNIGlzIGVuYWJsZWQpLCBpdA0K
PiBjYW4gaGVscCB0byByZWR1Y2UgY29zdCBvZiBpbGxlZ2FsX2hpZ2hkbWEoKSBhbmQgX19za2Jf
bGluZWFyaXplKCkNCj4gY2FsbHMuDQo+IA0KPiBUZXN0ZWQgb24gdGczICwgYm54MiwgYm9uZGlu
ZywgdGhpcyB3b3JrZWQgdmVyeSB3ZWxsLg0KPiANCj4gVGhpcyBpcyBhIGdlbmVyYWxpemF0aW9u
IG9mIGEgcGF0Y2ggcHJvdmlkZWQgYnkgWWkgWm91ICYgSmVmZiBLaXJzaGVyLg0KPiANCj4gU2ln
bmVkLW9mZi1ieTogRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPg0KPiAtLS0N
Cj4gIG5ldC9jb3JlL2Rldi5jIHwgICAgNyArKysrLS0tDQo+ICAxIGZpbGUgY2hhbmdlZCwgNCBp
bnNlcnRpb25zKCspLCAzIGRlbGV0aW9ucygtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL25ldC9jb3Jl
L2Rldi5jIGIvbmV0L2NvcmUvZGV2LmMNCj4gaW5kZXggMmM3OTM0Zi4uZTBjMGI4NiAxMDA2NDQN
Cj4gLS0tIGEvbmV0L2NvcmUvZGV2LmMNCj4gKysrIGIvbmV0L2NvcmUvZGV2LmMNCj4gQEAgLTUw
NTgsMTAgKzUwNTgsMTEgQEAgaW50IHJlZ2lzdGVyX25ldGRldmljZShzdHJ1Y3QgbmV0X2Rldmlj
ZSAqZGV2KQ0KPiAgCWlmIChkZXYtPmZlYXR1cmVzICYgTkVUSUZfRl9TRykNCj4gIAkJZGV2LT5m
ZWF0dXJlcyB8PSBORVRJRl9GX0dTTzsNCj4gDQo+IC0JLyogRW5hYmxlIEdSTyBmb3IgdmxhbnMg
YnkgZGVmYXVsdCBpZiBkZXYtPmZlYXR1cmVzIGhhcyBHUk8gYWxzby4NCj4gLQkgKiB2bGFuX2Rl
dl9pbml0KCkgd2lsbCBkbyB0aGUgZGV2LT5mZWF0dXJlcyBjaGVjay4NCj4gKwkvKiBFbmFibGUg
R1JPIGFuZCBORVRJRl9GX0hJR0hETUEgZm9yIHZsYW5zIGJ5IGRlZmF1bHQsDQo+ICsJICogdmxh
bl9kZXZfaW5pdCgpIHdpbGwgZG8gdGhlIGRldi0+ZmVhdHVyZXMgY2hlY2ssIHNvIHRoZXNlDQo+
IGZlYXR1cmVzDQo+ICsJICogYXJlIGVuYWJsZWQgb25seSBpZiBzdXBwb3J0ZWQgYnkgdW5kZXJs
eWluZyBkZXZpY2UuDQo+ICAJICovDQo+IC0JZGV2LT52bGFuX2ZlYXR1cmVzIHw9IE5FVElGX0Zf
R1JPOw0KPiArCWRldi0+dmxhbl9mZWF0dXJlcyB8PSAoTkVUSUZfRl9HUk8gfCBORVRJRl9GX0hJ
R0hETUEpOw0KPiANCj4gIAlyZXQgPSBjYWxsX25ldGRldmljZV9ub3RpZmllcnMoTkVUREVWX1BP
U1RfSU5JVCwgZGV2KTsNCj4gIAlyZXQgPSBub3RpZmllcl90b19lcnJubyhyZXQpOw0KPiANCkNv
b2wsIHRoYW5rcyBmb3IgdGFraW5nIGNhcmUgb2YgdGhpcywgRXJpYy4NCg0KLXlpDQo=
