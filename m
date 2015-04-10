From: "Schmitt, Phillip J" <phillip.j.schmitt@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH net-next v10 1/7] if_link: Add an
 additional parameter to ifla_vf_info for RSS querying
Date: Fri, 10 Apr 2015 23:12:51 +0000
Message-ID: <305E19FFAC908240AB6DEBD1E2D8C1E17F813045@ORSMSX108.amr.corp.intel.com>
References: <1427740529-9605-1-git-send-email-vladz@cloudius-systems.com>
 <1427740529-9605-2-git-send-email-vladz@cloudius-systems.com>
 <1427787296.2497.109.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"avi@cloudius-systems.com" <avi@cloudius-systems.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"gleb@cloudius-systems.com" <gleb@cloudius-systems.com>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10097 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756592AbbDJXMy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 19:12:54 -0400
In-Reply-To: <1427787296.2497.109.camel@jtkirshe-mobl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogSW50ZWwtd2lyZWQtbGFu
IFttYWlsdG86aW50ZWwtd2lyZWQtbGFuLWJvdW5jZXNAbGlzdHMub3N1b3NsLm9yZ10gT24NCj4g
QmVoYWxmIE9mIEplZmYgS2lyc2hlcg0KPiBTZW50OiBUdWVzZGF5LCBNYXJjaCAzMSwgMjAxNSAx
MjozNSBBTQ0KPiBUbzogVmxhZCBab2xvdGFyb3YNCj4gQ2M6IG5ldGRldkB2Z2VyLmtlcm5lbC5v
cmc7IGF2aUBjbG91ZGl1cy1zeXN0ZW1zLmNvbTsgaW50ZWwtd2lyZWQtDQo+IGxhbkBsaXN0cy5v
c3Vvc2wub3JnOyBnbGViQGNsb3VkaXVzLXN5c3RlbXMuY29tDQo+IFN1YmplY3Q6IFJlOiBbSW50
ZWwtd2lyZWQtbGFuXSBbUEFUQ0ggbmV0LW5leHQgdjEwIDEvN10gaWZfbGluazogQWRkIGFuIGFk
ZGl0aW9uYWwNCj4gcGFyYW1ldGVyIHRvIGlmbGFfdmZfaW5mbyBmb3IgUlNTIHF1ZXJ5aW5nDQo+
IA0KPiBPbiBNb24sIDIwMTUtMDMtMzAgYXQgMjE6MzUgKzAzMDAsIFZsYWQgWm9sb3Rhcm92IHdy
b3RlOg0KPiA+IEFkZCBjb25maWd1cmF0aW9uIHNldHRpbmcgZm9yIGRyaXZlcnMgdG8gYWxsb3cv
YmxvY2sgYW4gUlNTDQo+ID4gUmVkaXJlY3Rpb24gVGFibGUgYW5kIGEgSGFzaCBLZXkgcXVlcnlp
bmcgZm9yIGRpc2NyZXRlIFZGcy4NCj4gPg0KPiA+IE9uIHNvbWUgZGV2aWNlcyBWRiBzaGFyZSB0
aGUgbWVudGlvbmVkIGFib3ZlIGluZm9ybWF0aW9uIHdpdGggUEYgYW5kDQo+ID4gcXVlcnlpbmcg
aXQgbWF5IGFkZHVjZSBhIHRoZW9yZXRpY2FsIHNlY3VyaXR5IHJpc2suIFdlIHdhbnQgdG8gbGV0
IGENCj4gPiBzeXN0ZW0gYWRtaW5pc3RyYXRvciB0byBkZWNpZGUgaWYgaGUvc2hlIHdhbnRzIHRv
IHRha2UgdGhpcyByaXNrIG9yDQo+ID4gbm90Lg0KPiA+DQo+ID4gU2lnbmVkLW9mZi1ieTogVmxh
ZCBab2xvdGFyb3YgPHZsYWR6QGNsb3VkaXVzLXN5c3RlbXMuY29tPg0KPiA+IC0tLQ0KPiA+ICBp
bmNsdWRlL2xpbnV4L2lmX2xpbmsuaCAgICAgIHwgIDEgKw0KPiA+ICBpbmNsdWRlL2xpbnV4L25l
dGRldmljZS5oICAgIHwgIDggKysrKysrKysNCj4gPiAgaW5jbHVkZS91YXBpL2xpbnV4L2lmX2xp
bmsuaCB8ICA4ICsrKysrKysrDQo+ID4gIG5ldC9jb3JlL3J0bmV0bGluay5jICAgICAgICAgfCAz
MiArKysrKysrKysrKysrKysrKysrKysrKysrKy0tLS0tLQ0KPiA+ICA0IGZpbGVzIGNoYW5nZWQs
IDQzIGluc2VydGlvbnMoKyksIDYgZGVsZXRpb25zKC0pDQo+IA0KPiBUaGFua3MgVmxhZCwgYXBw
bGllZCB0byBteSBxdWV1ZS4NCj4gLS0NCj4gZ2l0Oi8vZ2l0Lmtlcm5lbC5vcmcvcHViL3NjbS9s
aW51eC9rZXJuZWwvZ2l0L2praXJzaGVyL25leHQtcXVldWUuZ2l0DQo+IGRldi1xdWV1ZQ0KDQpU
ZXN0ZWQtYnk6IFBoaWwgU2NobWl0dCA8cGhpbGxpcC5qLnNjaG1pdHRAaW50ZWwuY29tPg0K
