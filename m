From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH net-next 00/11] remove open coded ns_to_timespec64 and
 reverse
Date: Tue, 31 Mar 2015 21:11:30 +0000
Message-ID: <1427836290.16312.29.camel@intel.com>
References: <cover.1427835485.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"baolin.wang@linaro.org" <baolin.wang@linaro.org>,
	"b45643@freescale.com" <b45643@freescale.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
	"sonic.zhang@analog.com" <sonic.zhang@analog.com>,
	"rayagond@vayavyalabs.com" <rayagond@vayavyalabs.com>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"sony.chacko@qlogic.com" <sony.chacko@qlogic.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"arnd@linaro.org" <arnd@linaro.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"prashant@broadcom.com" <prashant@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>
To: "richardcochran@gmail.com" <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43952 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754215AbbCaVLl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2015 17:11:41 -0400
In-Reply-To: <cover.1427835485.git.richardcochran@gmail.com>
Content-Language: en-US
Content-ID: <CAFF357F8DF75D48820C2110630252F2@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCAyMDE1LTAzLTMxIGF0IDIzOjA4ICswMjAwLCBSaWNoYXJkIENvY2hyYW4gd3JvdGU6
DQo+IFRoaXMgcGF0Y2ggc2VyaWVzIGlzIGEgZm9sbG93IHVwIHRvIHRoZSByZWNlbnQgdGltZXNw
ZWM2NCB3b3JrIGZvciB0aGUNCj4gUFRQIEhhcmR3YXJlIENsb2NrIGRyaXZlcnMuICBBcm5kIG5v
dGljZWQgdGhhdCBkcml2ZXJzIGFyZSB1c2luZyBvcGVuDQo+IGNvZGVkIGltcGxlbWVudGF0aW9u
cyBvZiBuc190b190aW1lc3BlYzY0IGFuZCB0aW1lc3BlYzY0X3RvX25zLiAgVGhpcw0KPiBzZXJp
ZXMgcmVwbGFjZXMgdGhlIG9wZW4gY29kZWQgbG9naWMgd2l0aCB0aGUgaGVscGVyIGZ1bmN0aW9u
cy4NCj4gDQo+IFRoYW5rcywNCj4gUmljaGFyZA0KPiANCj4gUmljaGFyZCBDb2NocmFuICgxMSk6
DQo+ICAgcHRwOiBibGFja2ZpbjogdXNlIGhlbHBlcnMgZm9yIGNvbnZlcnRpbmcgbnMgdG8gdGlt
ZXNwZWMuDQo+ICAgcHRwOiBibngyeDogdXNlIGhlbHBlcnMgZm9yIGNvbnZlcnRpbmcgbnMgdG8g
dGltZXNwZWMuDQo+ICAgcHRwOiB0ZzM6IHVzZSBoZWxwZXJzIGZvciBjb252ZXJ0aW5nIG5zIHRv
IHRpbWVzcGVjLg0KPiAgIHB0cDogZmVjOiB1c2UgaGVscGVycyBmb3IgY29udmVydGluZyBucyB0
byB0aW1lc3BlYy4NCj4gICBwdHA6IGdpYW5mYXI6IHVzZSBoZWxwZXJzIGZvciBjb252ZXJ0aW5n
IG5zIHRvIHRpbWVzcGVjLg0KPiAgIHB0cDogZTEwMDBlOiB1c2UgaGVscGVycyBmb3IgY29udmVy
dGluZyBucyB0byB0aW1lc3BlYy4NCj4gICBwdHA6IGlnYjogdXNlIGhlbHBlcnMgZm9yIGNvbnZl
cnRpbmcgbnMgdG8gdGltZXNwZWMuDQo+ICAgcHRwOiBpeGdiZTogdXNlIGhlbHBlcnMgZm9yIGNv
bnZlcnRpbmcgbnMgdG8gdGltZXNwZWMuDQo+ICAgcHRwOiBtbHg0OiB1c2UgaGVscGVycyBmb3Ig
Y29udmVydGluZyBucyB0byB0aW1lc3BlYy4NCj4gICBwdHA6IHN0bW1hYzogdXNlIGhlbHBlcnMg
Zm9yIGNvbnZlcnRpbmcgbnMgdG8gdGltZXNwZWMuDQo+ICAgcHRwOiBjcHRzOiB1c2UgaGVscGVy
cyBmb3IgY29udmVydGluZyBucyB0byB0aW1lc3BlYy4NCj4gDQo+ICBkcml2ZXJzL25ldC9ldGhl
cm5ldC9hZGkvYmZpbl9tYWMuYyAgICAgICAgICAgICAgfCAgICA4ICsrKy0tLS0tDQo+ICBkcml2
ZXJzL25ldC9ldGhlcm5ldC9icm9hZGNvbS9ibngyeC9ibngyeF9tYWluLmMgfCAgICA3ICsrLS0t
LS0NCj4gIGRyaXZlcnMvbmV0L2V0aGVybmV0L2Jyb2FkY29tL3RnMy5jICAgICAgICAgICAgICB8
ICAgIDQgKy0tLQ0KPiAgZHJpdmVycy9uZXQvZXRoZXJuZXQvZnJlZXNjYWxlL2ZlY19wdHAuYyAg
ICAgICAgIHwgICAgNyArKy0tLS0tDQo+ICBkcml2ZXJzL25ldC9ldGhlcm5ldC9mcmVlc2NhbGUv
Z2lhbmZhcl9wdHAuYyAgICAgfCAgICA4ICsrKy0tLS0tDQo+ICBkcml2ZXJzL25ldC9ldGhlcm5l
dC9pbnRlbC9lMTAwMGUvcHRwLmMgICAgICAgICAgfCAgICA0ICstLS0NCj4gIGRyaXZlcnMvbmV0
L2V0aGVybmV0L2ludGVsL2lnYi9pZ2JfcHRwLmMgICAgICAgICB8ICAgIDcgKystLS0tLQ0KPiAg
ZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaXhnYmUvaXhnYmVfcHRwLmMgICAgIHwgICAgNyAr
Ky0tLS0tDQo+ICBkcml2ZXJzL25ldC9ldGhlcm5ldC9tZWxsYW5veC9tbHg0L2VuX2Nsb2NrLmMg
ICAgfCAgICA0ICstLS0NCj4gIGRyaXZlcnMvbmV0L2V0aGVybmV0L3N0bWljcm8vc3RtbWFjL3N0
bW1hY19wdHAuYyB8ICAgIDQgKy0tLQ0KPiAgZHJpdmVycy9uZXQvZXRoZXJuZXQvdGkvY3B0cy5j
ICAgICAgICAgICAgICAgICAgIHwgICAgNyArKy0tLS0tDQo+ICAxMSBmaWxlcyBjaGFuZ2VkLCAy
MCBpbnNlcnRpb25zKCspLCA0NyBkZWxldGlvbnMoLSkNCj4gDQoNCkZvciBhbGwgdGhlIEludGVs
IGRyaXZlcnMsIHRoaXMgbG9va3MgZmluZS4gSSdtIHN1cnByaXNlZCBJIG5ldmVyDQpub3RpY2Vk
IGJlZm9yZS4NCg0KQWNrZWQtYnk6IEphY29iIEtlbGxlciA8amFjb2IuZS5rZWxsZXJAaW50ZWwu
Y29tPg0K
