From: "Coelho, Luciano" <luciano.coelho@intel.com>
Subject: Re: [PATCH V5 1/2] firmware: add more flexible
 request_firmware_async function
Date: Thu, 3 Aug 2017 05:55:18 +0000
Message-ID: <1501739717.15969.26.camel@intel.com>
References: <20170731150945.8925-1-zajec5@gmail.com>
         <20170802213010.GM18884@wotan.suse.de>
         <878tj1ql6z.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "pieter-paul.giesberts@broadcom.com"
        <pieter-paul.giesberts@broadcom.com>,
        "bjorn.andersson@linaro.org" <bjorn.andersson@linaro.org>,
        "arend.vanspriel@broadcom.com" <arend.vanspriel@broadcom.com>,
        "hante.meuleman@broadcom.com" <hante.meuleman@broadcom.com>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "keescook@chromium.org" <keescook@chromium.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "alan@linux.intel.com" <alan@linux.intel.com>,
        "moritz.fischer@ettus.com" <moritz.fischer@ettus.com>,
        "pjones@redhat.com" <pjones@redhat.com>,
        "wagi@monom.org" <wagi@monom.org>,
        "pmladek@suse.com" <pmladek@suse.com>,
        "atull@kernel.org" <atull@kernel.org>,
        "yi1.li@linux.intel.com" <yi1.li@linux.intel.com>,
        "wright.feng@cypress.com" <wright.f
To: "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
        "mcgrof@kernel.org" <mcgrof@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:15643 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751079AbdHCFz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Aug 2017 01:55:26 -0400
In-Reply-To: <878tj1ql6z.fsf@kamboji.qca.qualcomm.com>
Content-Language: en-US
Content-ID: <4AB7B851FAA7AE4099970A3B579A0A7A@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVGh1LCAyMDE3LTA4LTAzIGF0IDA4OjIzICswMzAwLCBLYWxsZSBWYWxvIHdyb3RlOg0KPiAi
THVpcyBSLiBSb2RyaWd1ZXoiIDxtY2dyb2ZAa2VybmVsLm9yZz4gd3JpdGVzOg0KPiANCj4gPiA+
ICtpbnQgcmVxdWVzdF9maXJtd2FyZV9ub3dhaXQoc3RydWN0IG1vZHVsZSAqbW9kdWxlLCBib29s
IHVldmVudCwNCj4gPiA+ICsJCQkgICAgY29uc3QgY2hhciAqbmFtZSwgc3RydWN0IGRldmljZSAq
ZGV2aWNlLCBnZnBfdCBnZnAsDQo+ID4gPiArCQkJICAgIHZvaWQgKmNvbnRleHQsDQo+ID4gPiAr
CQkJICAgIHZvaWQgKCpjb250KShjb25zdCBzdHJ1Y3QgZmlybXdhcmUgKmZ3LCB2b2lkICpjb250
ZXh0KSkNCj4gPiA+ICt7DQo+ID4gPiArCXVuc2lnbmVkIGludCBvcHRfZmxhZ3MgPSBGV19PUFRf
RkFMTEJBQ0sgfA0KPiA+ID4gKwkJKHVldmVudCA/IEZXX09QVF9VRVZFTlQgOiBGV19PUFRfVVNF
UkhFTFBFUik7DQo+ID4gPiArDQo+ID4gPiArCXJldHVybiBfX3JlcXVlc3RfZmlybXdhcmVfbm93
YWl0KG1vZHVsZSwgb3B0X2ZsYWdzLCBuYW1lLCBkZXZpY2UsIGdmcCwNCj4gPiA+ICsJCQkJCSBj
b250ZXh0LCBjb250KTsNCj4gPiA+ICt9DQo+ID4gPiAgRVhQT1JUX1NZTUJPTChyZXF1ZXN0X2Zp
cm13YXJlX25vd2FpdCk7DQo+ID4gPiAgDQo+ID4gPiAraW50IF9fcmVxdWVzdF9maXJtd2FyZV9h
c3luYyhzdHJ1Y3QgbW9kdWxlICptb2R1bGUsIGNvbnN0IGNoYXIgKm5hbWUsDQo+ID4gPiArCQkJ
ICAgICBzdHJ1Y3QgZmlybXdhcmVfb3B0cyAqZndfb3B0cywgc3RydWN0IGRldmljZSAqZGV2LA0K
PiA+ID4gKwkJCSAgICAgdm9pZCAqY29udGV4dCwNCj4gPiA+ICsJCQkgICAgIHZvaWQgKCpjb250
KShjb25zdCBzdHJ1Y3QgZmlybXdhcmUgKmZ3LCB2b2lkICpjb250ZXh0KSkNCj4gPiA+ICt7DQo+
ID4gPiArCXVuc2lnbmVkIGludCBvcHRfZmxhZ3MgPSBGV19PUFRfVUVWRU5UOw0KPiA+IA0KPiA+
IFRoaXMgZXhwb3NlcyBhIGxvbmcgaXNzdWUuIFRoaW5rIC0tIHdoeSBkbyB3ZSB3YW50IHRoaXMg
ZW5hYmxlZCBieSBkZWZhdWx0PyBJdHMNCj4gPiBhY3R1YWxseSBiZWNhdXNlIGV2ZW4gdGhvdWdo
IHRoZSBmYWxsYmFjayBzdHVmZiBpcyBvcHRpb25hbCBhbmQgY2FuIGJlLCB0aGUgdWV2ZW50DQo+
ID4gaW50ZXJuYWwgZmxhZyAqYWxzbyogcHJvdmlkZXMgY2FjaGluZyBzdXBwb3J0IGFzIGEgc2lk
ZSBjb25zZXF1ZW5jZSBvbmx5LiBXZQ0KPiA+IGRvbid0IHdhbnQgdG8gYWRkIGEgbmV3IEFQSSB3
aXRob3V0IGZpcnN0IGNsZWFuaW5nIHVwIHRoYXQgbWVzcy4NCj4gPiANCj4gPiBUaGlzIGlzIGEg
c2xpcGVyeSBzbG9wZSBhbmQgYmVzdCB0byBjbGVhbiB0aGF0IHVwIGJlZm9yZSBhZGRpbmcgYW55
IG5ldyBBUEkuDQo+ID4gDQo+ID4gVGhhdCBhbmQgYWxzbyBHcmVnIHJlY2VudGx5IHN0YXRlZCBo
ZSB3b3VsZCBsaWtlIHRvIHNlZSBhdCBsZWFzdCAzIHVzZXJzIG9mDQo+ID4gYSBmZWF0dXJlIGJl
Zm9yZSBhZGRpbmcgaXQuIEFsdGhvdWdoIEkgdGhpbmsgdGhhdCdzIHByZXR0eSBhcmJpdHJhcnks
IGFuZA0KPiA+IGNvbnNpZGVyaW5nIHRoYXQgcmVxdWVzdF9maXJtd2FyZV9pbnRvX2J1ZigpIG9u
bHkgaGFzICpvbmUqIHVzZXIgLS0gaXRzIHdoYXQNCj4gPiBoZSB3aXNoZXMuDQo+IA0KPiBhdGgx
MGsgYXQgbGVhc3QgbmVlZHMgYSB3YXkgdG8gc2lsZW5jZSB0aGUgd2FybmluZyBmb3IgbWlzc2lu
ZyBmaXJtd2FyZQ0KPiBhbmQgSSB0aGluayBpd2x3aWZpIGFsc28uDQoNClllcywgaXdsd2lmaSBu
ZWVkcyB0byBzaWxlbmNlIHRoZSB3YXJuaW5nLiAgSXQgdGhlIGZlYXR1cmUgKG9ubHkgb25lLA0K
cmVhbGx5KSB0aGF0IEkndmUgYmVlbiB3YWl0aW5nIGZvci4NCg0KLS0NCkx1Y2Eu
