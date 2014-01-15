From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH net-next] net/mlx4_core: Warn if device doesn't have
 enough PCI bandwidth
Date: Wed, 15 Jan 2014 23:15:09 +0000
Message-ID: <1389827709.8362.14.camel@jekeller-desk1.amr.corp.intel.com>
References: <1388863024-8718-1-git-send-email-amirv@mellanox.com>
	 <1389042955.9947.110.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Amir Vadai <amirv@mellanox.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8004 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752023AbaAOXPO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 18:15:14 -0500
In-Reply-To: <1389042955.9947.110.camel@bwh-desktop.uk.level5networks.com>
Content-Language: en-US
Content-ID: <CCF4CE43CD57F24FA229C06E5491BDB7@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gTW9uLCAyMDE0LTAxLTA2IGF0IDIxOjE1ICswMDAwLCBCZW4gSHV0Y2hpbmdzIHdyb3RlOg0K
PiBPbiBTYXQsIDIwMTQtMDEtMDQgYXQgMjE6MTcgKzAyMDAsIEFtaXIgVmFkYWkgd3JvdGU6DQo+
ID4gRnJvbTogRXlhbCBQZXJyeSA8ZXlhbHBlQG1lbGxhbm94LmNvbT4NCj4gPiANCj4gPiBDaGVj
ayBpZiB0aGUgZGV2aWNlIGdldCBlbm91Z2ggYmFuZHdpZHRoIGZyb20gdGhlIGVudGlyZSBQQ0kg
Y2hhaW4gdG8gc2F0aXNmeQ0KPiA+IGl0cyBjYXBhYmlsaXRpZXMuIFRoaXMgcGF0Y2ggZGV0ZXJt
aW5lcyB0aGUgUENJZSBkZXZpY2UncyBiYW5kd2lkdGggY2FwYWJpbGl0aWVzDQo+ID4gYnkgcmVh
ZGluZyBpdHMgUENJZSBMaW5rIENhcGFiaWxpdGllcyByZWdpc3RlcnMgYW5kIHRoZW4gY2FsbCB0
aGUNCj4gPiBwY2llX2dldF9taW5pbXVtX2xpbmsgZnVuY3Rpb24gdG8gZW5zdXJlIHRoYXQgdGhl
IGFkYXB0ZXIgaXMgaG9va2VkIGludG8gYSBzbG90DQo+ID4gd2hpY2ggaXMgY2FwYWJsZSBvZiBw
cm92aWRpbmcgdGhlIG5lY2Vzc2FyeSBiYW5kd2lkdGggY2FwYWJpbGl0aWVzLg0KPiBbLi4uXQ0K
PiANCj4gVGhpcyBpcyBlc3NlbnRpYWxseSBhbm90aGVyIGR1cGxpY2F0ZSBvZiB3aGF0IGl4Z2Jl
IGFuZCBpNDBlIGFyZQ0KPiBkb2luZy4uLiAgKEFuZCB0aGUgb3V0LW9mLXRyZWUgdmVyc2lvbiBv
ZiBzZmMgZG9lcyBpdCB0b28sIGJ1dCBJIG5ldmVyDQo+IGZlbHQgdGhhdCB3YXMgcmVhZHkgZm9y
IGluLXRyZWUuKQ0KPiANCj4gV2Ugb3VnaHQgdG8gaGF2ZSBhIGdlbmVyaWMgUENJIGxheWVyIGZ1
bmN0aW9uIHRoYXQgd2FybnMgd2hlbiBhIFBDSWUNCj4gZGV2aWNlIGlzIHJ1bm5pbmcgYmVsb3cg
bWF4aW11bSBsaW5rIHdpZHRoL3NwZWVkLiAgTWF5YmUgZXZlbiBydW4gaXQgYXMNCj4gc29vbiBh
cyB0aGUgZGV2aWNlIGlzIGVudW1lcmF0ZWQsIHNvIHRoYXQgYSBkcml2ZXIgZG9lc24ndCBuZWVk
IHRvIGRvDQo+IGFueXRoaW5nLg0KPiANCj4gQmVuLg0KPiANCg0KSGksDQoNCkkgd2FzIHRoaW5r
aW5nIGFib3V0IHRoaXMgYWdhaW4sIHdhcyB3b25kZXJpbmcgYSBmZXcgdGhpbmdzLiBJcyB0aGlz
DQpzb21ldGhpbmcgeW91IHdlcmUgYWxyZWFkeSBpbnZlc3RpZ2F0aW5nPw0KDQpPbiBhbiBpbXBs
ZW1lbnRhdGlvbiBub3RlLCBob3cgd291bGQgdGhpcyBmdW5jdGlvbiBrbm93IGhvdyBtdWNoDQpi
YW5kd2lkdGggYSBwYXJ0aWN1bGFyIGRldmljZSAob3IgZnVuY3Rpb24/KSB3b3VsZCByZXF1aXJl
PyBJJ20gdGhpbmtpbmcNCm9mIHNvbWV0aGluZyBhbG9uZyB0aGUgbGluZXMgb2YgYSBkcml2ZXIg
ZXNzZW50aWFsbHkgc2F5aW5nIGhvdyBtdWNoIHRoZQ0KZGV2aWNlcyBpdCBzdXBwb3J0cyByZXF1
aXJlPw0KDQpUaGFua3MsDQpKYWtlDQo=
