From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next 15/17] fm10k: fix possible null pointer deref after
 kcalloc
Date: Thu, 21 Apr 2016 20:09:27 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5857A7DB5E@ORSMSX115.amr.corp.intel.com>
References: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1461218969-68578-16-git-send-email-jeffrey.t.kirsher@intel.com>
	 <02874ECE860811409154E81DA85FBB5857A7C1E0@ORSMSX115.amr.corp.intel.com>
	 <20160421.154727.1143899173479860095.davem@davemloft.net>
 <1461268100.3018.5.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:36524 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751041AbcDUUJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 16:09:32 -0400
In-Reply-To: <1461268100.3018.5.camel@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBPbiBUaHUsIDIwMTYtMDQtMjEgYXQgMTU6NDcgLTA0MDAsIERhdmlkIE1pbGxlciB3cm90ZToN
Cj4gPiBGcm9tOiAiS2VsbGVyLCBKYWNvYiBFIiA8amFjb2IuZS5rZWxsZXJAaW50ZWwuY29tPg0K
PiA+IERhdGU6IFRodSwgMjEgQXByIDIwMTYgMTk6NDQ6MjQgKzAwMDANCj4gPg0KPiA+ID4gRGF2
ZSwgcGxlYXNlIGRvbid0IHB1bGwgdGhpcyBwYXRjaC4gS3Jpc2huZWlsIGZvdW5kIGFuIGlzc3Vl
IHdpdGgNCj4gPiA+IHRoaXMgcGF0Y2gsIGFuZCBJIHNlbnQgYSBjb3JyZWN0ZWQgZml4IHRvIHNx
dWFzaCBpbiBidXQgaXQgZGlkbid0DQo+ID4gPiBtYWtlIGl0IGludG8gdGhpcyBvbmUuIEknZCBs
aWtlIHRvIGdldCB0aGUgZml4IHNxdWFzaGVkIGluIGEgcmVzZW5kDQo+ID4gPiBiZWZvcmUgdGhp
cyBpcyBwdWxsZWQgaW50byBuZXQtbmV4dC4NCj4gPg0KPiA+IFRvbyBsYXRlLCBpdCdzIGFscmVh
ZHkgaW4gbXkgdHJlZS4NCj4gDQo+IEkgd2lsbCBhZGRyZXNzIEpha2VzIGNvbmNlcm5zIGluIG15
IG5leHQgZm0xMGsgcHVsbCByZXF1ZXN0Lg0KDQpUaGFua3MgSmVmZi4gU29ycnkgSSBkaWRuJ3Qg
bm90aWNlIHRoaXMgZWFybGllci4NCg0KUmVnYXJkcywNCkpha2UNCg==
