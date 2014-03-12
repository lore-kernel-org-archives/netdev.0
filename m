From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [net-next 12/13] ixgbe: fix some multiline hw_dbg prints
Date: Wed, 12 Mar 2014 18:31:03 +0000
Message-ID: <1394649063.3030.3.camel@jekeller-desk1.amr.corp.intel.com>
References: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1394603618-1044-13-git-send-email-jeffrey.t.kirsher@intel.com>
	 <53207459.5010306@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:48128 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755848AbaCLSbi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 14:31:38 -0400
In-Reply-To: <53207459.5010306@cogentembedded.com>
Content-Language: en-US
Content-ID: <3D516CF397CFBE4FAE5F29EE991D682C@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gV2VkLCAyMDE0LTAzLTEyIGF0IDE4OjUxICswNDAwLCBTZXJnZWkgU2h0eWx5b3Ygd3JvdGU6
DQo+IEhlbGxvLg0KPiANCj4gT24gMTItMDMtMjAxNCA5OjUzLCBKZWZmIEtpcnNoZXIgd3JvdGU6
DQo+IA0KPiA+IEZyb206IEphY29iIEtlbGxlciA8amFjb2IuZS5rZWxsZXJAaW50ZWwuY29tPg0K
PiANCj4gPiBUaGlzIHBhdGNoIGZpeGVzIHNvbWUgZm9ybWF0dGluZyBvbiBtdWx0aWxpbmVkIHBy
aW50IG1lc3NhZ2VzLCBzbyB0aGF0DQo+ID4gdGhlIHRleHQgb2YgdGhlIHByaW50IGFwcGVhcnMg
b24gYSBzaW5nbGUgbGluZSwgd2hpY2ggYWlkcyBpbiBncmVwcGluZw0KPiA+IHRoZSBzb3VyY2Vj
b2RlIGZvciB3aGVyZSB0aGUgZXJyb3IgY2FtZSBmcm9tLg0KPiANCj4gPiBTaWduZWQtb2ZmLWJ5
OiBKYWNvYiBLZWxsZXIgPGphY29iLmUua2VsbGVyQGludGVsLmNvbT4NCj4gPiBUZXN0ZWQtYnk6
IFBoaWwgU2NobWl0dCA8cGhpbGxpcC5qLnNjaG1pdHRAaW50ZWwuY29tPg0KPiA+IFNpZ25lZC1v
ZmYtYnk6IEplZmYgS2lyc2hlciA8amVmZnJleS50LmtpcnNoZXJAaW50ZWwuY29tPg0KPiA+IC0t
LQ0KPiA+ICAgZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaXhnYmUvaXhnYmVfODI1OTkuYyB8
IDggKysrLS0tLS0NCj4gPiAgIDEgZmlsZSBjaGFuZ2VkLCAzIGluc2VydGlvbnMoKyksIDUgZGVs
ZXRpb25zKC0pDQo+IA0KPiA+IGRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRl
bC9peGdiZS9peGdiZV84MjU5OS5jIGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaXhnYmUv
aXhnYmVfODI1OTkuYw0KPiA+IGluZGV4IDQ0NmRmM2MuLjNiYzliNjcgMTAwNjQ0DQo+ID4gLS0t
IGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaXhnYmUvaXhnYmVfODI1OTkuYw0KPiA+ICsr
KyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2l4Z2JlL2l4Z2JlXzgyNTk5LmMNCj4gPiBA
QCAtNTEyLDcgKzUxMiw3IEBAIG91dDoNCj4gPiAgICAqDQo+ID4gICAgKiBEaXNhYmxlcyBsaW5r
LCBzaG91bGQgYmUgY2FsbGVkIGR1cmluZyBEMyBwb3dlciBkb3duIHNlcXVlbmNlLg0KPiA+ICAg
ICoNCj4gPiAtICovDQo+ID4gKyAqKi8NCj4gDQo+ICAgICBIbT8gV2hhdCdzIHRoaXMgZm9yPw0K
PiANCg0KVGhlIGV4dHJhICoqLyBpcyBwYXJ0IG9mIHRoZSBzdGFuZGFyZCBkb2MgZm9ybWF0IGZv
ciBmdW5jdGlvbiBoZWFkZXJzLA0KYW5kIHRoaXMgd2FzIGxpa2VseSBhIGZpeCB0byBjb252ZXJ0
IGl0IHRvIHRoZSBzdGFuZGFyZCBmb3JtYXQsIHRob3VnaA0KcHJvYmFibHkgd2FzIG1lYW50IHRv
IGVuZCB1cCBpbiBhIHNlcGFyYXRlIHBhdGNoLi4uIEkgZG9uJ3QgZnVsbHkNCnJlY2FsbC4NCg0K
VGhhbmtzLA0KSmFrZQ0KDQo+IFdCUiwgU2VyZ2VpDQo+IA0KDQoNCg==
