From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [PATCH] e1000e: remove e1000_queue_stats
Date: Mon, 11 Jul 2011 13:18:54 -0700
Message-ID: <E0862362F1FF584BBCF7C4EA592A20C40755D948@orsmsx509.amr.corp.intel.com>
References: <1310414440.2860.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9855 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754166Ab1GKUS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 16:18:56 -0400
In-Reply-To: <1310414440.2860.9.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogbmV0ZGV2LW93bmVyQHZnZXIua2Vy
bmVsLm9yZyBbbWFpbHRvOm5ldGRldi1vd25lckB2Z2VyLmtlcm5lbC5vcmddIE9uDQo+QmVoYWxm
IE9mIEVyaWMgRHVtYXpldA0KPlNlbnQ6IE1vbmRheSwgSnVseSAxMSwgMjAxMSAxOjAxIFBNDQo+
VG86IERhdmlkIE1pbGxlcg0KPkNjOiBuZXRkZXY7IEtpcnNoZXIsIEplZmZyZXkgVDsgQnJhbmRl
YnVyZywgSmVzc2UNCj5TdWJqZWN0OiBbUEFUQ0hdIGUxMDAwZTogcmVtb3ZlIGUxMDAwX3F1ZXVl
X3N0YXRzDQo+DQo+c3RydWN0IGUxMDAwX3F1ZXVlX3N0YXRzIGlzIG5vdCB1c2VkLCBsZXRzIHJl
bW92ZSBpdA0KPg0KPlNpZ25lZC1vZmYtYnk6IEVyaWMgRHVtYXpldCA8ZXJpYy5kdW1hemV0QGdt
YWlsLmNvbT4NCj4tLS0NCj4gZHJpdmVycy9uZXQvZTEwMDBlL2UxMDAwLmggfCAgICA3IC0tLS0t
LS0NCj4gMSBmaWxlIGNoYW5nZWQsIDcgZGVsZXRpb25zKC0pDQo+DQo+ZGlmZiAtLWdpdCBhL2Ry
aXZlcnMvbmV0L2UxMDAwZS9lMTAwMC5oIGIvZHJpdmVycy9uZXQvZTEwMDBlL2UxMDAwLmgNCj5p
bmRleCBjMWU3Zjk0Li5lOWQ2ZTBhIDEwMDY0NA0KPi0tLSBhL2RyaXZlcnMvbmV0L2UxMDAwZS9l
MTAwMC5oDQo+KysrIGIvZHJpdmVycy9uZXQvZTEwMDBlL2UxMDAwLmgNCj5AQCAtMTk5LDExICsx
OTksNiBAQCBlbnVtIGUxMDAwX2JvYXJkcyB7DQo+IAlib2FyZF9wY2gybGFuLA0KPiB9Ow0KPg0K
Pi1zdHJ1Y3QgZTEwMDBfcXVldWVfc3RhdHMgew0KPi0JdTY0IHBhY2tldHM7DQo+LQl1NjQgYnl0
ZXM7DQo+LX07DQo+LQ0KPiBzdHJ1Y3QgZTEwMDBfcHNfcGFnZSB7DQo+IAlzdHJ1Y3QgcGFnZSAq
cGFnZTsNCj4gCXU2NCBkbWE7IC8qIG11c3QgYmUgdTY0IC0gd3JpdHRlbiB0byBodyAqLw0KPkBA
IC0yNTcsOCArMjUyLDYgQEAgc3RydWN0IGUxMDAwX3Jpbmcgew0KPiAJaW50IHNldF9pdHI7DQo+
DQo+IAlzdHJ1Y3Qgc2tfYnVmZiAqcnhfc2tiX3RvcDsNCj4tDQo+LQlzdHJ1Y3QgZTEwMDBfcXVl
dWVfc3RhdHMgc3RhdHM7DQo+IH07DQo+DQo+IC8qIFBIWSByZWdpc3RlciBzbmFwc2hvdCB2YWx1
ZXMgKi8NCg0KTm90aGluZyBmdXJ0aGVyIG5lZWRlZC4NCg0KQWNrZWQtYnk6IEJydWNlIEFsbGFu
IDxicnVjZS53LmFsbGFuQGludGVsLmNvbT4NCg==
