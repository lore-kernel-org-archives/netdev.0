From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net-next-2.6 PATCH 0/8 RFC v2] macvlan: MAC Address filtering
	support for passthru mode
Date: Wed, 19 Oct 2011 14:06:40 -0700
Message-ID: <43F901BD926A4E43B106BF17856F075501A177719C@orsmsx508.amr.corp.intel.com>
References: <20111019062543.7242.3969.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "sri@us.ibm.com" <sri@us.ibm.com>,
	"dragos.tatulea@gmail.com" <dragos.tatulea@gmail.com>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"dwang2@cisco.com" <dwang2@cisco.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"benve@cisco.com" <benve@cisco.com>
To: Roopa Prabhu <roprabhu@cisco.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:18231 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753559Ab1JSVGm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Oct 2011 17:06:42 -0400
In-Reply-To: <20111019062543.7242.3969.stgit@savbu-pc100.cisco.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBuZXRkZXYtb3duZXJAdmdlci5r
ZXJuZWwub3JnIFttYWlsdG86bmV0ZGV2LW93bmVyQHZnZXIua2VybmVsLm9yZ10NCj4gT24gQmVo
YWxmIE9mIFJvb3BhIFByYWJodQ0KPiBTZW50OiBUdWVzZGF5LCBPY3RvYmVyIDE4LCAyMDExIDEx
OjI2IFBNDQo+IFRvOiBuZXRkZXZAdmdlci5rZXJuZWwub3JnDQo+IENjOiBzcmlAdXMuaWJtLmNv
bTsgZHJhZ29zLnRhdHVsZWFAZ21haWwuY29tOyBhcm5kQGFybmRiLmRlOw0KPiBrdm1Admdlci5r
ZXJuZWwub3JnOyBtc3RAcmVkaGF0LmNvbTsgZGF2ZW1AZGF2ZW1sb2Z0Lm5ldDsNCj4gbWNoYW5A
YnJvYWRjb20uY29tOyBkd2FuZzJAY2lzY28uY29tOyBzaGVtbWluZ2VyQHZ5YXR0YS5jb207DQo+
IGVyaWMuZHVtYXpldEBnbWFpbC5jb207IGthYmVyQHRyYXNoLm5ldDsgYmVudmVAY2lzY28uY29t
DQo+IFN1YmplY3Q6IFtuZXQtbmV4dC0yLjYgUEFUQ0ggMC84IFJGQyB2Ml0gbWFjdmxhbjogTUFD
IEFkZHJlc3MgZmlsdGVyaW5nDQo+IHN1cHBvcnQgZm9yIHBhc3N0aHJ1IG1vZGUNCj4gIA0KDQpb
c25pcC4uLl0NCg0KPiANCj4gDQo+IAlOb3RlOiBUaGUgY2hvaWNlIG9mIHJ0bmxfbGlua19vcHMg
d2FzIGJlY2F1c2UgSSBzYXcgdGhlIHVzZSBjYXNlIGZvcg0KPiAJdGhpcyBpbiB2aXJ0dWFsIGRl
dmljZXMgdGhhdCBuZWVkICB0byBkbyBmaWx0ZXJpbmcgaW4gc3cgbGlrZSBtYWN2bGFuDQo+IAlh
bmQgdHVuLiBIdyBkZXZpY2VzIHVzdWFsbHkgaGF2ZSBmaWx0ZXJpbmcgaW4gaHcgd2l0aCBuZXRk
ZXYtPnVjIGFuZA0KPiAJbWMgbGlzdHMgdG8gaW5kaWNhdGUgYWN0aXZlIGZpbHRlcnMuIEJ1dCBJ
IGNhbiBtb3ZlIGZyb20gcnRubF9saW5rX29wcw0KPiAJdG8gbmV0ZGV2X29wcyBpZiB0aGF0IGlz
IHRoZSBwcmVmZXJyZWQgd2F5IHRvIGdvIGFuZCBpZiB0aGVyZSBpcyBhDQo+IAluZWVkIHRvIHN1
cHBvcnQgdGhpcyBpbnRlcmZhY2Ugb24gYWxsIGtpbmRzIG9mIGludGVyZmFjZXMuDQo+IAlQbGVh
c2Ugc3VnZ2VzdC4NCg0KSSdtIHN0aWxsIGRpZ2VzdGluZyB0aGUgcmVzdCBvZiB0aGUgUkZDIHBh
dGNoZXMgYnV0IEkgZGlkIHdhbnQgdG8gcXVpY2tseSBqdW1wDQppbiBhbmQgcHVzaCBmb3IgYWRk
aW5nIHRoaXMgc3VwcG9ydCBpbiBuZXRkZXZfb3BzLiAgSSB3b3VsZCBsaWtlIHRvIHNlZSB0aGVz
ZQ0KZmVhdHVyZXMgYXZhaWxhYmxlIGluIG1vcmUgZGV2aWNlcyB0aGFuIGp1c3QgbWFjdnRhcCBh
bmQgbWFjdmxhbi4gIEkgY2FuIGNvbmNlaXZlDQpvZiB1c2UgY2FzZXMgZm9yIG11bHRpcGxlIEhX
IE1BQyBhbmQgVkxBTiBmaWx0ZXJzIGZvciBhIFZGIGRldmljZSB0aGF0IGlzbid0DQpvd25lZCBi
eSBhIG1hY3ZsYW4vbWFjdnRhcCBpbnRlcmZhY2UgYW5kIG9ubHkgaGFzIG5ldGRldl9vcHMgc3Vw
cG9ydC4gIEluIHRoaXMNCmNhc2UgaXQgd291bGQgYmUgbmVjZXNzYXJ5IHRvIHByb2dyYW0gdGhl
IGZpbHRlcnMgZGlyZWN0bHkgdG8gdGhlIFZGIGRldmljZQ0KaW50ZXJmYWNlIG9yIFBGIGludGVy
ZmFjZSAob3IgbG93ZXJkZXYgYXMgeW91IHJlZmVyIHRvIGl0KSBpbnN0ZWFkIG9mIGdvaW5nDQp0
aHJvdWdoIG1hY3ZsYW4vbWFjdnRhcC4NCg0KVGhpcyB3b3JrIGRvdmV0YWlscyBuaWNlbHkgd2l0
aCBzb21lIHdvcmsgSSd2ZSBiZWVuIGRvaW5nIGFuZCBJJ2QgYmUgdmVyeSBpbnRlcmVzdGVkDQpp
biBoZWxwaW5nIG1vdmUgdGhpcyBmb3J3YXJkIGlmIHdlIGNvdWxkIHdvcmsgb3V0IHRoZSBkZXRh
aWxzIHRoYXQgd291bGQgYWxsb3cgc3VwcG9ydA0Kb2YgdGhlIGZlYXR1cmVzIHdlIChhbmQgdGhl
IGNvbW11bml0eSkgcmVxdWlyZS4NCg0KLSBHcmVnIFJvc2UNCkxBTiBBY2Nlc3MgRGl2aXNpb24N
CkludGVsIENvcnAuDQoNCg0K
