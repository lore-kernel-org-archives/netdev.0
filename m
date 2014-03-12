From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [net-next 12/13] ixgbe: fix some multiline hw_dbg prints
Date: Wed, 12 Mar 2014 20:21:07 +0000
Message-ID: <1394655666.3724.4.camel@jekeller-desk1.amr.corp.intel.com>
References: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>
		 <1394603618-1044-13-git-send-email-jeffrey.t.kirsher@intel.com>
		 <53207459.5010306@cogentembedded.com>
	 <1394649063.3030.3.camel@jekeller-desk1.amr.corp.intel.com>
	 <5320BF63.30403@cogentembedded.com> <5320C263.9000105@cogentembedded.com>
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
Received: from mga11.intel.com ([192.55.52.93]:18892 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752592AbaCLUVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 16:21:09 -0400
In-Reply-To: <5320C263.9000105@cogentembedded.com>
Content-Language: en-US
Content-ID: <6E290335DC88AF46B5866A1193D37FC6@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gV2VkLCAyMDE0LTAzLTEyIGF0IDIzOjI0ICswMzAwLCBTZXJnZWkgU2h0eWx5b3Ygd3JvdGU6
DQo+IE9uIDAzLzEyLzIwMTQgMTE6MTEgUE0sIFNlcmdlaSBTaHR5bHlvdiB3cm90ZToNCj4gDQo+
ID4+Pj4gRnJvbTogSmFjb2IgS2VsbGVyIDxqYWNvYi5lLmtlbGxlckBpbnRlbC5jb20+DQo+IA0K
PiA+Pj4+IFRoaXMgcGF0Y2ggZml4ZXMgc29tZSBmb3JtYXR0aW5nIG9uIG11bHRpbGluZWQgcHJp
bnQgbWVzc2FnZXMsIHNvIHRoYXQNCj4gPj4+PiB0aGUgdGV4dCBvZiB0aGUgcHJpbnQgYXBwZWFy
cyBvbiBhIHNpbmdsZSBsaW5lLCB3aGljaCBhaWRzIGluIGdyZXBwaW5nDQo+ID4+Pj4gdGhlIHNv
dXJjZWNvZGUgZm9yIHdoZXJlIHRoZSBlcnJvciBjYW1lIGZyb20uDQo+IA0KPiA+Pj4+IFNpZ25l
ZC1vZmYtYnk6IEphY29iIEtlbGxlciA8amFjb2IuZS5rZWxsZXJAaW50ZWwuY29tPg0KPiA+Pj4+
IFRlc3RlZC1ieTogUGhpbCBTY2htaXR0IDxwaGlsbGlwLmouc2NobWl0dEBpbnRlbC5jb20+DQo+
ID4+Pj4gU2lnbmVkLW9mZi1ieTogSmVmZiBLaXJzaGVyIDxqZWZmcmV5LnQua2lyc2hlckBpbnRl
bC5jb20+DQo+ID4+Pj4gLS0tDQo+ID4+Pj4gICAgZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwv
aXhnYmUvaXhnYmVfODI1OTkuYyB8IDggKysrLS0tLS0NCj4gPj4+PiAgICAxIGZpbGUgY2hhbmdl
ZCwgMyBpbnNlcnRpb25zKCspLCA1IGRlbGV0aW9ucygtKQ0KPiANCj4gPj4+PiBkaWZmIC0tZ2l0
IGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaXhnYmUvaXhnYmVfODI1OTkuYw0KPiA+Pj4+
IGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaXhnYmUvaXhnYmVfODI1OTkuYw0KPiA+Pj4+
IGluZGV4IDQ0NmRmM2MuLjNiYzliNjcgMTAwNjQ0DQo+ID4+Pj4gLS0tIGEvZHJpdmVycy9uZXQv
ZXRoZXJuZXQvaW50ZWwvaXhnYmUvaXhnYmVfODI1OTkuYw0KPiA+Pj4+ICsrKyBiL2RyaXZlcnMv
bmV0L2V0aGVybmV0L2ludGVsL2l4Z2JlL2l4Z2JlXzgyNTk5LmMNCj4gPj4+PiBAQCAtNTEyLDcg
KzUxMiw3IEBAIG91dDoNCj4gPj4+PiAgICAgKg0KPiA+Pj4+ICAgICAqIERpc2FibGVzIGxpbmss
IHNob3VsZCBiZSBjYWxsZWQgZHVyaW5nIEQzIHBvd2VyIGRvd24gc2VxdWVuY2UuDQo+ID4+Pj4g
ICAgICoNCj4gPj4+PiAtICovDQo+ID4+Pj4gKyAqKi8NCj4gDQo+ID4+PiAgICAgIEhtPyBXaGF0
J3MgdGhpcyBmb3I/DQo+IA0KPiA+PiBUaGUgZXh0cmEgKiovIGlzIHBhcnQgb2YgdGhlIHN0YW5k
YXJkIGRvYyBmb3JtYXQgZm9yIGZ1bmN0aW9uIGhlYWRlcnMsDQo+IA0KPiA+ICAgICBJdCBpcyBu
b3QuIFJlcmVhZCBEb2N1bWVudGF0aW9uL2tlcm5lbC1kb2MtbmFuby1IT1dUTy50eHQgcGxlYXNl
Lg0KPiANCj4gICAgIFNvcnJ5LCBJIG1lc3NlZCBpdCBteXNlbGYgLS0gaXQgc2VlbXMgdG8gYmUg
YW4gb3B0aW9uYWwgcGFydCBvZiB0aGUgZm9ybWF0IA0KPiB3aGljaCBJJ3ZlIG5ldmVyIHNlZW4g
YWN0dWFsbHkgdXNlZC4gQW55d2F5LCB5b3Ugc2hvdWxkbid0IGRvICJkcm92ZS1ieSIgDQo+IGNo
YW5nZXMgbGlrZSB0aGF0LCBtb3Jlb3ZlciB1bmRvY3VtZW50ZWQgaW4gdGhlIGNoYW5nZSBsb2cu
DQo+IA0KPiBXQlIsIFNlcmdlaQ0KPiANCg0KSXQncyB1c2VkIGFsbCBvdmVyIGluIG91ciBkcml2
ZXIgc291cmNlLCBhbmQgSSB3YXMgdHJ5aW5nIHRvIHN5bmMgc3R5bGUuDQpCdXQgSSBjYW4gcmUt
c3BpbiB0aGlzIHBhdGNoIHdpdGggdGhhdCBodW5rIGRyb3BwZWQuDQoNClRoYW5rcywNCkpha2UN
Cg==
