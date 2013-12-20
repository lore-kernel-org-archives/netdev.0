From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [net-next 05/15] i40e: add set settings and pauseparam
Date: Fri, 20 Dec 2013 18:19:53 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E416C6976D1@FMSMSX102.amr.corp.intel.com>
References: <1387434891-19719-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1387434891-19719-6-git-send-email-jeffrey.t.kirsher@intel.com>
 <1387485743.1876.51.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:60426 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751039Ab3LTSTz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Dec 2013 13:19:55 -0500
In-Reply-To: <1387485743.1876.51.camel@bwh-desktop.uk.level5networks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBCZW4gSHV0Y2hpbmdzIFttYWls
dG86Ymh1dGNoaW5nc0Bzb2xhcmZsYXJlLmNvbV0NCj4gU2VudDogVGh1cnNkYXksIERlY2VtYmVy
IDE5LCAyMDEzIDEyOjQyIFBNDQo+IFRvOiBLaXJzaGVyLCBKZWZmcmV5IFQNCj4gQ2M6IGRhdmVt
QGRhdmVtbG9mdC5uZXQ7IE5lbHNvbiwgU2hhbm5vbjsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsN
Cj4gZ29zcG9AcmVkaGF0LmNvbTsgc2Fzc21hbm5AcmVkaGF0LmNvbTsgQnJhbmRlYnVyZywgSmVz
c2UNCj4gU3ViamVjdDogUmU6IFtuZXQtbmV4dCAwNS8xNV0gaTQwZTogYWRkIHNldCBzZXR0aW5n
cyBhbmQgcGF1c2VwYXJhbQ0KPiANCj4gT24gV2VkLCAyMDEzLTEyLTE4IGF0IDIyOjM0IC0wODAw
LCBKZWZmIEtpcnNoZXIgd3JvdGU6DQo+ID4gRnJvbTogU2hhbm5vbiBOZWxzb24gPHNoYW5ub24u
bmVsc29uQGludGVsLmNvbT4NCj4gPg0KPiA+IFRoaXMgaW1wbGVtZW50cyB0aGUgc2V0X3NldHRp
bmdzIGFuZCBzZXRfcGF1c2VwYXJhbSBldGh0b29sDQo+ID4gZnVuY3Rpb25hbGl0eS4NCj4gPg0K
PiA+IENoYW5nZS1JZDogSTQ2MzRlZTJjOGJjZTAwMjA0ZWRhYzdkZjlmMGFmNGZiN2JmMzNiNzUN
Cj4gPiBTaWduZWQtb2ZmLWJ5OiBTaGFubm9uIE5lbHNvbiA8c2hhbm5vbi5uZWxzb25AaW50ZWwu
Y29tPg0KPiA+IFNpZ25lZC1vZmYtYnk6IEplc3NlIEJyYW5kZWJ1cmcgPGplc3NlLmJyYW5kZWJ1
cmdAaW50ZWwuY29tPg0KPiA+IFRlc3RlZC1ieTogS2F2aW5keWEgRGVlZ2FsYSA8a2F2aW5keWEu
cy5kZWVnYWxhQGludGVsLmNvbT4NCj4gPiBTaWduZWQtb2ZmLWJ5OiBKZWZmIEtpcnNoZXIgPGpl
ZmZyZXkudC5raXJzaGVyQGludGVsLmNvbT4NCj4gPiAtLS0NCj4gPiAgZHJpdmVycy9uZXQvZXRo
ZXJuZXQvaW50ZWwvaTQwZS9pNDBlX2V0aHRvb2wuYyB8IDk3DQo+ICsrKysrKysrKysrKysrKysr
KysrKysrKysrDQo+ID4gIDEgZmlsZSBjaGFuZ2VkLCA5NyBpbnNlcnRpb25zKCspDQo+ID4NCg0K
VGhhbmtzIEJlbi4gIEFzIGl0IHR1cm5zIG91dCB0aGVyZSBhcmUgYSBjb3VwbGUgb3RoZXIgaXNz
dWVzIHdpdGggdGhpcyBwYXRjaCwgc28gd2UncmUgZHJvcHBpbmcgaXQgZm9yIG5vdy4gIFdoZW4g
aXQgcmVhcHBlYXJzIHlvdXIgaXNzdWVzIHNob3VsZCBiZSByZXNvbHZlZC4NCg0KQ2hlZXJzLA0K
c2xuDQoNCg==
