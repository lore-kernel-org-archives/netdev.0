From: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
Subject: RE: [PATCH v3 6/8] thunderbolt: Networking state machine
Date: Sun, 17 Jul 2016 07:04:04 +0000
Message-ID: <E607265CB020454880711A6F96C05A03893CEE28@hasmsx107.ger.corp.intel.com>
References: <1468495702-7467-1-git-send-email-amir.jer.levy@intel.com>
 <1468495702-7467-7-git-send-email-amir.jer.levy@intel.com>
 <CAP=VYLoAUw+8B7BwzopBTeZjMYbZpOnUOE9tEnYH6718TjW_pQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "andreas.noever@gmail.com" <andreas.noever@gmail.com>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	thunderbolt-linux <thunderbolt-linux@intel.com>,
	"Westerberg, Mika" <mika.westerberg@intel.com>,
	"Winkler, Tomas" <tomas.winkler@intel.com>
To: "Gortmaker, Paul (Wind River)" <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10058 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751742AbcGQHEM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jul 2016 03:04:12 -0400
In-Reply-To: <CAP=VYLoAUw+8B7BwzopBTeZjMYbZpOnUOE9tEnYH6718TjW_pQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gRnJpLCBKdWwgMTUgMjAxNiwgMDM6MjUgQU0sIFBhdWwgR29ydG1ha2VyIHdyb3RlOg0KPiA+
IGRpZmYgLS1naXQgYS9kcml2ZXJzL3RodW5kZXJib2x0L2ljbS9uZXQuYw0KPiA+IGIvZHJpdmVy
cy90aHVuZGVyYm9sdC9pY20vbmV0LmMgbmV3IGZpbGUgbW9kZSAxMDA2NDQgaW5kZXgNCj4gPiAw
MDAwMDAwLi5lOTgzZGZiDQo+ID4gLS0tIC9kZXYvbnVsbA0KPiA+ICsrKyBiL2RyaXZlcnMvdGh1
bmRlcmJvbHQvaWNtL25ldC5jDQo+ID4gQEAgLTAsMCArMSw4MDIgQEANCj4gPg0KPiArLyoqKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKg0KPiAq
KioqKioqKioqKg0KPiA+ICsqKioqKioqKioqKg0KPiA+ICsgKg0KPiA+ICsgKiBJbnRlbCBUaHVu
ZGVyYm9sdChUTSkgZHJpdmVyDQo+ID4gKyAqIENvcHlyaWdodChjKSAyMDE0IC0gMjAxNiBJbnRl
bCBDb3Jwb3JhdGlvbi4NCj4gPiArICoNCj4gPiArICogVGhpcyBwcm9ncmFtIGlzIGZyZWUgc29m
dHdhcmU7IHlvdSBjYW4gcmVkaXN0cmlidXRlIGl0IGFuZC9vcg0KPiA+ICttb2RpZnkgaXQNCj4g
PiArICogdW5kZXIgdGhlIHRlcm1zIGFuZCBjb25kaXRpb25zIG9mIHRoZSBHTlUgR2VuZXJhbCBQ
dWJsaWMgTGljZW5zZSwNCj4gPiArICogdmVyc2lvbiAyLCBhcyBwdWJsaXNoZWQgYnkgdGhlIEZy
ZWUgU29mdHdhcmUgRm91bmRhdGlvbi4NCj4gPiArICoNCj4gPiArICogVGhpcyBwcm9ncmFtIGlz
IGRpc3RyaWJ1dGVkIGluIHRoZSBob3BlIGl0IHdpbGwgYmUgdXNlZnVsLCBidXQNCj4gPiArV0lU
SE9VVA0KPiA+ICsgKiBBTlkgV0FSUkFOVFk7IHdpdGhvdXQgZXZlbiB0aGUgaW1wbGllZCB3YXJy
YW50eSBvZg0KPiBNRVJDSEFOVEFCSUxJVFkNCj4gPiArb3INCj4gPiArICogRklUTkVTUyBGT1Ig
QSBQQVJUSUNVTEFSIFBVUlBPU0UuICBTZWUgdGhlIEdOVSBHZW5lcmFsIFB1YmxpYw0KPiA+ICtM
aWNlbnNlIGZvcg0KPiA+ICsgKiBtb3JlIGRldGFpbHMuDQo+ID4gKyAqDQo+ID4gKyAqIFlvdSBz
aG91bGQgaGF2ZSByZWNlaXZlZCBhIGNvcHkgb2YgdGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNl
bnNlDQo+ID4gK2Fsb25nDQo+ID4gKyAqIHdpdGggdGhpcyBwcm9ncmFtLiAgSWYgbm90LCBzZWUg
PGh0dHA6Ly93d3cuZ251Lm9yZy9saWNlbnNlcy8+Lg0KPiA+ICsgKg0KPiA+ICsgKiBUaGUgZnVs
bCBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSBpcyBpbmNsdWRlZCBpbiB0aGlzDQo+ID4gK2Rp
c3RyaWJ1dGlvbiBpbg0KPiA+ICsgKiB0aGUgZmlsZSBjYWxsZWQgIkNPUFlJTkciLg0KPiA+ICsg
Kg0KPiA+ICsgKiBDb250YWN0IEluZm9ybWF0aW9uOg0KPiA+ICsgKiBJbnRlbCBUaHVuZGVyYm9s
dCBNYWlsaW5nIExpc3QgPHRodW5kZXJib2x0LXNvZnR3YXJlQGxpc3RzLjAxLm9yZz4NCj4gPiAr
ICogSW50ZWwgQ29ycG9yYXRpb24sIDUyMDAgTi5FLiBFbGFtIFlvdW5nIFBhcmt3YXksIEhpbGxz
Ym9ybywgT1INCj4gPiArOTcxMjQtNjQ5Nw0KPiA+ICsgKg0KPiA+ICsNCj4gPg0KPiArKioqKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqDQo+ICoq
KioqKioqKioqKg0KPiA+ICsqKioqKioqKiovDQo+ID4gKw0KPiA+ICsjaW5jbHVkZSA8bGludXgv
bW9kdWxlLmg+DQo+IA0KPiBJIGRpZCBub3Qgc2VlIGFueXRoaW5nIGxpa2UgbW9kdWxlX2luaXQg
aW4gdGhpcyBkcml2ZXI7ICBJIHRoaW5rIGl0IHNlZW1zIGxpa2UgeW91DQo+IHdhbnQgbGludXgv
bW9kdWxlcGFyYW0uaCBoZXJlLg0KPiANCg0KSGkgUGF1bCwNCkl0IGxvb2tzIGxpa2UgbGVmdG92
ZXIgZnJvbSB0aGUgZWFybHkgZGV2ZWxvcG1lbnQgc3RhZ2VzLg0KSSdsbCByZW1vdmUgaXQuDQpU
aGUgbW9kdWxlX2luaXQgaXMgaW4gaWNtX25oaS5jLg0KDQpUaGFua3MsDQpBbWlyDQo=
