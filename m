From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH] net: don't forget to free sk_filter
Date: Fri, 8 Nov 2013 00:56:09 +0000
Message-ID: <1383872168.9330.23.camel@jekeller-desk1.amr.corp.intel.com>
References: <1383753106-26978-1-git-send-email-avagin@openvz.org>
	 <527A9638.4020404@redhat.com>
	 <1383766098.21999.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Andrey Vagin <avagin@openvz.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Alexei Starovoitov" <ast@plumgrid.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"stable@vger.kernel.org.#.3.12" <stable@vger.kernel.org.#.3.12>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383766098.21999.2.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Content-ID: <606FFAAEF723A84EA3CA2B3D92D8AEB5@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T24gV2VkLCAyMDEzLTExLTA2IGF0IDExOjI4IC0wODAwLCBFcmljIER1bWF6ZXQgd3JvdGU6DQo+
IE9uIFdlZCwgMjAxMy0xMS0wNiBhdCAyMDoxOSArMDEwMCwgRGFuaWVsIEJvcmttYW5uIHdyb3Rl
Og0KPiANCj4gPiBXaGVuIHlvdSBzZW5kIHYyIHdpdGggQWxleGVpJ3MgZmVlZGJhY2ssIHBsZWFz
ZSBhbHNvIGJlIG1vcmUgc3BlY2lmaWMNCj4gPiBpbiB5b3VyIHN1YmplY3QgbGlrZSAibmV0OiB4
ODY6IGJwZjogZG9uJ3QgZm9yZ2V0IHRvIGZyZWUgc2tfZmlsdGVyIg0KPiA+IG9yIHRoZSBsaWtl
LiBBbHNvIGl0J3MgZW5vdWdoIHRvIHNheSAnVGhpcyBtZW1vcnkgbGVhayB3YXMgaW50cm9kdWNl
ZA0KPiA+IGJ5IGNvbW1pdCBkNDVlZDRhNGUzICgibmV0OiBmaXggdW5zYWZlIHNldF9tZW1vcnlf
cncgZnJvbSBzb2Z0aXJxIiknDQo+ID4gaW5zdGVhZCBvZiBjb3B5aW5nIHRoZSB3aG9sZSBsb2cu
IEFueXdheXMsIGZvciB2MiB3aXRoIGZlZWRiYWNrIGluY2x1ZGVkDQo+ID4gdGhlbjoNCj4gDQo+
IEFjdHVhbGx5LCB0aGUgbmV3IHdheSBbMV0gb2YgZG9pbmcgdGhpcyB3b3VsZCBiZSB0byB1c2Ug
dGhlICdGaXhlczonIHRhZw0KPiBhcyBpbiA6DQo+IA0KPiBGaXhlczogPDEyIGRpZ2l0cyBTSEEx
PiAoIm5ldDogZml4IHVuc2FmZSBzZXRfbWVtb3J5X3J3IGZyb20gc29mdGlycSIpDQo+IA0KPiBb
MV0gQXMgZGlzY3Vzc2VkIGF0IGxhc3QgS2VybmVsIFN1bW1pdA0KPiANCj4gRXhhbXBsZSBpbiAN
Cj4gDQo+IGh0dHA6Ly9naXQua2VybmVsLm9yZy9jZ2l0L2xpbnV4L2tlcm5lbC9naXQvdG9ydmFs
ZHMvbGludXguZ2l0L2NvbW1pdC8/aWQ9NjkyMGExYmQwMzczNzRhNjMyZDU4NWRlMTI3YjZmOTQ1
MTk5ZGNiOA0KPiANCj4gDQo+IC0tDQo+IFRvIHVuc3Vic2NyaWJlIGZyb20gdGhpcyBsaXN0OiBz
ZW5kIHRoZSBsaW5lICJ1bnN1YnNjcmliZSBuZXRkZXYiIGluDQo+IHRoZSBib2R5IG9mIGEgbWVz
c2FnZSB0byBtYWpvcmRvbW9Admdlci5rZXJuZWwub3JnDQo+IE1vcmUgbWFqb3Jkb21vIGluZm8g
YXQgIGh0dHA6Ly92Z2VyLmtlcm5lbC5vcmcvbWFqb3Jkb21vLWluZm8uaHRtbA0KDQpIYXMgdGhl
cmUgYmVlbiBhbnkgbWVudGlvbiBvZiBhIGZvcnRoY29taW5nIHBhdGNoDQp0byAuL0RvY3VtZW50
YXRpb24vU3VibWl0dGluZ1BhdGNoZXMgd2hpY2ggZG9jdW1lbnRzIHRoaXM/DQoNClRoYW5rcywN
Ckpha2UNCg==
