From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH net-next 3/4] igb: enable internal PPS for the i210.
Date: Wed, 19 Nov 2014 21:06:19 +0000
Message-ID: <1416431178.15933.38.camel@jekeller-desk1.amr.corp.intel.com>
References: <cover.1416265321.git.richardcochran@gmail.com>
	 <e5b4ef7c56119e2d86e42f5680b1b82c9ec1a38e.1416265321.git.richardcochran@gmail.com>
	 <20141119063724.GB4109@localhost.localdomain>
	 <1416425553.15933.32.camel@jekeller-desk1.amr.corp.intel.com>
	 <20141119202604.GA22213@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>
To: "richardcochran@gmail.com" <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:11520 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932517AbaKSVGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 16:06:24 -0500
In-Reply-To: <20141119202604.GA22213@localhost.localdomain>
Content-Language: en-US
Content-ID: <BB66AA4C398D1A40B092ED3F7BAA50CB@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gV2VkLCAyMDE0LTExLTE5IGF0IDIxOjI2ICswMTAwLCBSaWNoYXJkIENvY2hyYW4gd3JvdGU6
DQo+IE9uIFdlZCwgTm92IDE5LCAyMDE0IGF0IDA3OjMyOjMzUE0gKzAwMDAsIEtlbGxlciwgSmFj
b2IgRSB3cm90ZToNCj4gPiBHb29kIGNhdGNoIDopDQo+IA0KPiAoV2VsbCwgbXkgWCBzZXNzaW9u
IHN1ZGRlbmx5IGRpc2FwcGVhcmVkLCBhbmQgYSBrZXJuZWwgb29wcyBhcHBlYXJlZCBpbg0KPiB0
aGUgY29uc29sZS4uLiBoYXJkIHRvIG92ZXJsb29rIDteKQ0KPiAgDQo+ID4gRGlkIHlvdSBzZWUg
bXkgY29uY2VybiBhYm91dCB0aGUgcmVzZXQgcGF0aCBuZWVkaW5nIHRvIGZ1bGx5IHJlc3RvcmUg
dGhlDQo+ID4gc3RhdGUgc2luY2UgaXQgaXMgY2FsbGVkIGFmdGVyIGEgaGFyZHdhcmUgTUFDIHJl
c2V0IHdoaWNoIGhhcyBjbGVhcmVkDQo+ID4gYWxsIHRoZXNlIHJlZ2lzdGVycz8NCj4gDQo+IFll
cywgYW5kIHRoYXQgYml0IEkgY29waWVkIGZyb20gdGhlIGZpcnN0IHNlcmllcyBhIHllYXIgYWdv
LiBJIGRvbid0DQo+IHJlbWVtYmVyIHdoeSwgYnV0IElJUkMgdGhhdCB3YXMgbmVjZXNzYXJ5IHRv
IGxldCB0aGUgU0RQIHN0dWZmIHdvcmsgYXQNCj4gYWxsLiBNYXliZSB0aGUgcmVzZXQgZnVuY3Rp
b24gd2FzIGNhbGxlZCB1bmRlciBkaWZmZXJlbnQgY2lyY3Vtc3RhbmNlcw0KPiBiYWNrIHRoZW4u
IEknbGwgdGFrZSBhbm90aGVyIGxvb2suDQo+IA0KPiBJIGZpbmQgaXQgYSBiaXQgd2VpcmQgdGhh
dCB0aGUgYXV4aWxpYXJ5IGZ1bmN0aW9ucyBkb24ndCB3b3JrIHdoZW4gdGhlDQo+IGludGVyZmFj
ZSBvciB0aGUgbGluayBpcyBkb3duLg0KPiANCj4gVGhhbmtzLA0KPiBSaWNoYXJkDQoNCkkgdGhp
bmsgeW91IG5lZWQgc29tZXRoaW5nIGhlcmUsIGJ1dCBpdCBzaG91bGQgYmUgY2xlYXJpbmcgdGhh
dCByZWdpc3Rlcg0KYWZ0ZXIgYSBNQUMgcmVzZXQsIHNvIGl0IG5lZWRzIHRvIGJlIHJlLWluaXRp
YWxpemVkLiBJJ20gbm90IHN1cmUgaWYNCnRoYXQgcmVzZXQgcGF0aCB3YXMgdXNlZCBpbiB0aGUg
c2FtZSBwbGFjZSBpbiB0aGUgcGFzdC4NCg0KV2VsbCwgSSB0aGluayBpZ2IgYW5kIGl4Z2JlIGRl
c3Ryb3kgdGhlIHB0cCBkZXZpY2Ugd2hlbiB0aGUgaW50ZXJmYWNlDQpnb2VzIGRvd24sIGFuZCBy
ZXN0b3JlIGl0IHdoZW4gaXQgY29tZXMgdXAuIFByb2JhYmx5IHdlIHNob3VsZCBpbnN0ZWFkDQpo
YW5kbGUgc29tZSB0aGluZ3MgaW4gcmVzZXQgcGF0aCBhbmQgYWxsb3cgdGhlIHB0cCBkZXZpY2Ug
dG8gcmVtYWluLg0KDQpJdCdzIHBhcnRseSBkdWUgdG8gdGhlIGNsb2NrIHNwZWVkIGNoYW5naW5n
IGJhc2VkIG9uIGxpbmsgc3BlZWQuDQoNClJlZ2FyZHMsDQpKYWtlDQo=
