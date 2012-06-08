From: Roman Kagan <rkagan@parallels.com>
Subject: Re: [PATCH] e1000: save skb counts in TX to avoid cache misses
Date: Fri, 8 Jun 2012 11:37:22 +0400
Message-ID: <1339141042.7850.51.camel@rkaganb.sw.ru>
References: <b838d871c0d507787373061e4edd91a624d62475.1339073391.git.rkagan@parallels.com>
	 <4FD11F49.5060805@gmail.com>
	 <20120607.144358.1732928576389957779.davem@davemloft.net>
	 <20120608021542.GA10112@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"tarbal@gmail.com" <tarbal@gmail.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	"jesse.brandeburg@intel.com" <jesse.brandeburg@intel.com>,
	"bruce.w.allan@intel.com" <bruce.w.allan@intel.com>,
	"carolyn.wyborny@intel.com" <carolyn.wyborny@intel.com>,
	"donald.c.skidmore@intel.com" <donald.c.skidmore@intel.com>,
	"gregory.v.rose@intel.com" <gregory.v.rose@intel.com>,
	"peter.p.waskiewicz.jr@intel.com" <peter.p.waskiewicz.jr@intel.com>,
	"alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>,
	"john.ronciak@intel.com" <john.ronciak@intel.com>,
	"dnelson@redhat.com" <dnelson@redhat.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.or
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120608021542.GA10112@kroah.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T24gRnJpLCAyMDEyLTA2LTA4IGF0IDA2OjE1ICswNDAwLCBHcmVnIEtIIHdyb3RlOg0KPiBPbiBU
aHUsIEp1biAwNywgMjAxMiBhdCAwMjo0Mzo1OFBNIC0wNzAwLCBEYXZpZCBNaWxsZXIgd3JvdGU6
DQo+ID4gRnJvbTogSmVmZiBLaXJzaGVyIDx0YXJiYWxAZ21haWwuY29tPg0KPiA+IERhdGU6IFRo
dSwgMDcgSnVuIDIwMTIgMTQ6Mzg6MTcgLTA3MDANCj4gPiANCj4gPiA+IFRoYW5rcyEgSSBoYXZl
IGFwcGxpZWQgdGhlIHBhdGNoIHRvIG15IHF1ZXVlDQo+ID4gDQo+ID4gV2h5Pw0KPiA+IA0KPiA+
IE15IGltcHJlc3Npb24gaXMgdGhhdCB0aGlzIGlzIGEgcGF0Y2ggYWxyZWFkeSBpbiB0aGUgdHJl
ZSwgYW5kIGl0J3MNCj4gPiBiZWluZyBzdWJtaXR0ZWQgZm9yIC1zdGFibGUgYnV0IHN1Y2ggbWlu
b3IgcGVyZm9ybWFuY2UgaGFja3MgYXJlDQo+ID4gYWJzb2x1dGVseSBub3QgYXBwcm9wcmlhdGUg
Zm9yIC1zdGFibGUgc3VibWlzc2lvbi4NCj4gDQo+IFRoZSBwYXRjaCBkZXNjcmlwdGlvbiBzYXlz
IGl0IGlzIGZpeGluZyByZXBvcnRlZCBvb3BzZXMsDQoNCkV4YWN0bHkuDQoNCj4gYnV0IHRoZSBT
dWJqZWN0OiBpc24ndCBhbGwgdGhhdCBoZWxwZnVsIHRoZXJlLg0KDQpXZWxsIEkganVzdCBwcmVz
ZXJ2ZWQgdGhlIG9yaWdpbmFsIHN1YmplY3QgZnJvbSB0aGUgdXBzdHJlYW0gY29tbWl0Lg0KV2Fu
dCBtZSB0byByZXN1Ym1pdCB3aXRoIGEgbW9yZSBhbGFybWluZyBvbmU/DQoNCj4gU28gd2hpY2gg
aXMgdGhpcz8gIFNob3VsZCBJIGFjY2VwdCBpdCBmb3IgYSBzdGFibGUgcmVsZWFzZSBvciBub3Q/
DQoNCklNTyB5ZXMgOykNCg0KVGhhbmtzLA0KUm9tYW4uDQo=
