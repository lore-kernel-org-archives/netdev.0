From: Jiang Wang <Jiang.Wang@riverbed.com>
Subject: RE: [PATCH 1/2] e100: power down PHY if WOL is not enabled
Date: Wed, 14 Dec 2011 22:16:54 +0000
Message-ID: <CEE05A0D7856E14880AD5560634EBEA82AA78752@365EXCH-MBX-P5.nbttech.com>
References: <1323830996-16388-1-git-send-email-Jiang.Wang@riverbed.com>
	 <1323894636.2753.2.camel@bwh-desktop>
	 <CEE05A0D7856E14880AD5560634EBEA82AA78720@365EXCH-MBX-P5.nbttech.com>
 <1323900468.2753.22.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Prasanna Panchamukhi <Prasanna.Panchamukhi@riverbed.com>,
	Chaitanya Lala <Chaitanya.Lala@riverbed.com>,
	"Francis St. Amant" <Francis.St.Amant@riverbed.com>,
	"miles.ito@intel.com" <miles.ito@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1323900468.2753.22.camel@bwh-desktop>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SSBzZWUuIEkgd2lsbCBhZGQgb25lIG1vcmUgY2hlY2sgZm9yIHRoYXQuIFRoYW5rcy4NCg0KLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KSmlhbmcgV2FuZw0KTWVtYmVyIG9m
IFRlY2huaWNhbCBTdGFmZg0KUml2ZXJiZWQgVGVjaG5vbG9neQ0KVGVsOiAoNDA4KSA1MjItNTEw
OQ0KRW1haWw6IEppYW5nLldhbmdAcml2ZXJiZWQuY29tDQp3d3cucml2ZXJiZWQuY29tDQoNCg0K
LS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCkZyb206IEJlbiBIdXRjaGluZ3MgW21haWx0bzpi
aHV0Y2hpbmdzQHNvbGFyZmxhcmUuY29tXSANClNlbnQ6IFdlZG5lc2RheSwgRGVjZW1iZXIgMTQs
IDIwMTEgMjowOCBQTQ0KVG86IEppYW5nIFdhbmcNCkNjOiBKZWZmIEtpcnNoZXI7IEplc3NlIEJy
YW5kZWJ1cmc7IEJydWNlIEFsbGFuOyBDYXJvbHluIFd5Ym9ybnk7IERvbiBTa2lkbW9yZTsgR3Jl
ZyBSb3NlOyBQZXRlciBQIFdhc2tpZXdpY3ogSnI7IEFsZXggRHV5Y2s7IEpvaG4gUm9uY2lhazsg
ZTEwMDAtZGV2ZWxAbGlzdHMuc291cmNlZm9yZ2UubmV0OyBuZXRkZXZAdmdlci5rZXJuZWwub3Jn
OyBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnOyBQcmFzYW5uYSBQYW5jaGFtdWtoaTsgQ2hh
aXRhbnlhIExhbGE7IEZyYW5jaXMgU3QuIEFtYW50OyBtaWxlcy5pdG9AaW50ZWwuY29tDQpTdWJq
ZWN0OiBSRTogW1BBVENIIDEvMl0gZTEwMDogcG93ZXIgZG93biBQSFkgaWYgV09MIGlzIG5vdCBl
bmFibGVkDQoNCk9uIFdlZCwgMjAxMS0xMi0xNCBhdCAyMTo1OSArMDAwMCwgSmlhbmcgV2FuZyB3
cm90ZToNCj4gSGkgQmVuLA0KPiANCj4gRG8geW91IG1lYW4gdGhlIFdPTCBpcyBlbmFibGVkIGJ1
dCBQSFkgaXMgcG93ZXJlZCBvZmYgc29tZWhvdz8gVGhhdCANCj4gc2NlbmFyaW8gc2hvdWxkIG5l
dmVyIGhhcHBlbi4gSWYgV09MIGlzIGVuYWJsZWQsIHRoZXJlIGlzIG5vIGNvZGUgdG8gDQo+IHBv
d2VyIG9mZiBQSFkuDQpbLi4uXQ0KDQpJbml0aWFsIGNvbmRpdGlvbnM6IGludGVyZmFjZSB1cCwg
V09MIG9mZiwgUEhZIG9uLg0KDQoxLiBCcmluZyBpbnRlcmZhY2UgZG93bi4gUEhZIGlzIHR1cm5l
ZCBvZmYuDQoyLiBUdXJuIFdPTCBvbi4gIFBIWSBpcyBzdGlsbCBvZmYsIGJ1dCBuZWVkcyB0byBi
ZSBvbi4NCg0KQmVuLg0KDQotLQ0KQmVuIEh1dGNoaW5ncywgU3RhZmYgRW5naW5lZXIsIFNvbGFy
ZmxhcmUgTm90IHNwZWFraW5nIGZvciBteSBlbXBsb3llcjsgdGhhdCdzIHRoZSBtYXJrZXRpbmcg
ZGVwYXJ0bWVudCdzIGpvYi4NClRoZXkgYXNrZWQgdXMgdG8gbm90ZSB0aGF0IFNvbGFyZmxhcmUg
cHJvZHVjdCBuYW1lcyBhcmUgdHJhZGVtYXJrZWQuDQoNCg==
