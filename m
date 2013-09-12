From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [ethtool 1/3] ethtool: fix ixgbe 82598EB only registers
Date: Thu, 12 Sep 2013 16:33:26 +0000
Message-ID: <1379003606.9217.0.camel@jekeller-desk1.amr.corp.intel.com>
References: <1377648529-8297-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1377809470.5372.16.camel@bwh-desktop.uk.level5networks.com>
	 <1379000729.1531.12.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7472 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754632Ab3ILQd1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 12:33:27 -0400
In-Reply-To: <1379000729.1531.12.camel@bwh-desktop.uk.level5networks.com>
Content-Language: en-US
Content-ID: <05CE293D19BF4544A6FCAC34B0620236@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVGh1LCAyMDEzLTA5LTEyIGF0IDE2OjQ1ICswMTAwLCBCZW4gSHV0Y2hpbmdzIHdyb3RlOg0K
PiBPbiBUaHUsIDIwMTMtMDgtMjkgYXQgMjE6NTEgKzAxMDAsIEJlbiBIdXRjaGluZ3Mgd3JvdGU6
DQo+ID4gT24gVHVlLCAyMDEzLTA4LTI3IGF0IDE3OjA4IC0wNzAwLCBKZWZmIEtpcnNoZXIgd3Jv
dGU6DQo+ID4gPiBGcm9tOiBKYWNvYiBLZWxsZXIgPGphY29iLmUua2VsbGVyQGludGVsLmNvbT4N
Cj4gPiA+IA0KPiA+ID4gVGhpcyBwYXRjaCBmaXhlcyBpeGdiZV9yZWdfZHVtcCB0byBvbmx5IGRp
c3BsYXkgcmVnaXN0ZXJzIHNwZWNpZmljIHRvIHRoZQ0KPiA+ID4gODI1OThFQiBwYXJ0LCBhcyB0
aGVzZSByZWdpc3RlcnMgZGlzcGxheSAweERFQURCRUVGIG90aGVyd2lzZSwgYW5kIGNsdXR0ZXIg
dXANCj4gPiA+IHRoZSByZWdpc3RlciBkdW1wLg0KPiA+ID4gDQo+ID4gPiBTaWduZWQtb2ZmLWJ5
OiBKYWNvYiBLZWxsZXIgPGphY29iLmUua2VsbGVyQGludGVsLmNvbT4NCj4gPiA+IFRlc3RlZC1i
eTogUGhpbCBTY2htaXR0IDxwaGlsbGlwLmouc2NobWl0dEBpbnRlbC5jb20+DQo+ID4gPiBTaWdu
ZWQtb2ZmLWJ5OiBKZWZmIEtpcnNoZXIgPGplZmZyZXkudC5raXJzaGVyQGludGVsLmNvbT4NCj4g
PiA+IC0tLQ0KPiA+ID4gIGl4Z2JlLmMgfCAxNDQgKysrKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KPiA+ID4gIDEgZmlsZSBjaGFu
Z2VkLCA3NSBpbnNlcnRpb25zKCspLCA2OSBkZWxldGlvbnMoLSkNCj4gPiA+IA0KPiA+ID4gZGlm
ZiAtLWdpdCBhL2l4Z2JlLmMgYi9peGdiZS5jDQo+ID4gPiBpbmRleCA5YjAwNWYyLi44OWNiNmJl
IDEwMDY0NA0KPiA+ID4gLS0tIGEvaXhnYmUuYw0KPiA+ID4gKysrIGIvaXhnYmUuYw0KPiA+IFsu
Li5dDQo+ID4gPiAtCWZwcmludGYoc3Rkb3V0LA0KPiA+ID4gLQkJIjB4MDJGMjA6IFJEUFJPQkUg
ICAgIChSeCBQcm9iZSBNb2RlIFN0YXR1cykgICAgICAgICAgIDB4JTA4WFxuIiwNCj4gPiA+IC0J
CXJlZ3NfYnVmZlsxMDg1XSk7DQo+ID4gWy4uLl0NCj4gPiANCj4gPiBJdCBsb29rcyBsaWtlIHRo
aXMgcmVtb3ZhbCByZWFsbHkgYmVsb25ncyB0byB0aGUgbmV4dCBwYXRjaCwgd2hpY2ggYWRkcw0K
PiA+IGl0IGJhY2sgd2l0aCB0aGUgbWFjX3R5cGUgPCBpeGdiZV9tYWNfWDU0MCBjb25kaXRpb24u
DQo+IA0KPiBXZWxsLCBJJ3ZlIGFwcGxpZWQgdGhlIHR3byBwYXRjaGVzIHdpdGggdGhpcyBiaXQg
Zml4ZWQgdXAuDQo+IA0KPiBCZW4uDQo+IA0KDQpUaGFua3MsIEJlbi4NCg0KUmVnYXJkcywNCkph
a2UNCg==
