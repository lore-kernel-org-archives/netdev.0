From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH 1/1] net/hyperv: Fix the code handling tx busy
Date: Mon, 19 Mar 2012 19:17:27 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DCEA930@TK5EX14MBXC223.redmond.corp.microsoft.com>
References: <1332176549-30960-1-git-send-email-haiyangz@microsoft.com>
	 <1332176549-30960-2-git-send-email-haiyangz@microsoft.com>
	 <1332177118.9397.32.camel@edumazet-glaptop>
	 <20120319104847.3a4c5fc0@nehalam.linuxnetplumber.net>
	 <A1F3067C9B68744AA19F6802BAB8FFDC0DCEA873@TK5EX14MBXC223.redmond.corp.microsoft.com>
 <1332181858.9397.49.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	KY Srinivasan <kys@microsoft.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332181858.9397.49.camel@edumazet-glaptop>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogRXJpYyBEdW1hemV0IFtt
YWlsdG86ZXJpYy5kdW1hemV0QGdtYWlsLmNvbV0NCj4gU2VudDogTW9uZGF5LCBNYXJjaCAxOSwg
MjAxMiAyOjMxIFBNDQo+IFRvOiBIYWl5YW5nIFpoYW5nDQo+IENjOiBTdGVwaGVuIEhlbW1pbmdl
cjsgS1kgU3Jpbml2YXNhbjsgZGF2ZW1AZGF2ZW1sb2Z0Lm5ldDsNCj4gbmV0ZGV2QHZnZXIua2Vy
bmVsLm9yZzsgbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZzsNCj4gZGV2ZWxAbGludXhkcml2
ZXJwcm9qZWN0Lm9yZw0KPiBTdWJqZWN0OiBSRTogW1BBVENIIDEvMV0gbmV0L2h5cGVydjogRml4
IHRoZSBjb2RlIGhhbmRsaW5nIHR4IGJ1c3kNCj4gDQo+IE9uIE1vbiwgMjAxMi0wMy0xOSBhdCAx
Nzo1MCArMDAwMCwgSGFpeWFuZyBaaGFuZyB3cm90ZToNCj4gDQo+ID4gQXMgaW4gbXkgcHJldmlv
dXMgcmVwbHkgdG8gRXJpYyAtLQ0KPiA+IFdlIGFjdHVhbGx5IHN0b3AgcXVldWUgd2hlbiB0aGUg
cmluZyBidWZmZXIgaXMgYnVzeSwgc2VlIHRoZSBjb2RlIGluDQo+ID4gbmV0dnNjLmMNCj4gPg0K
PiA+IEkgaGF2ZSB0ZXN0ZWQgd2l0aCBvbmUgQ1BVLiBBZnRlciBORVRERVZfVFhfQlVTWSBpcyBy
ZXR1cm5lZCwgdGhlDQo+ID4gTGludXggZ3Vlc3QgT1MgY29udGludWVzIHRvIHJlc3BvbmQgd2l0
aG91dCBhbnkgcHJvYmxlbS4NCj4gDQo+IFRoZW4gc29tZXRoaW5nIGlzIHdyb25nIHNvbWV3aGVy
ZS4NCj4gDQo+IERvbnQgaGlkZSBhIGJ1ZyBhZGRpbmcgYSB0cmljay4NCj4gDQo+IElmIHlvdSBl
dmVyIHJldHVybiBORVRERVZfVFhfQlVTWSBmcm9tIHN0YXJ0X3htaXQoKSwgdGhlbiB5b3UgTVVT
VCBjYWxsDQo+IG5ldGlmX3R4X3N0b3BfcXVldWUoKSBhcyB3ZWxsIHJpZ2h0IGJlZm9yZS4NCg0K
WWVzLCB3ZSBjYWxsZWQgdGhlIHN0b3BfcXVldWUgYmVmb3JlIHJldHVybmluZyBORVRERVZfVFhf
QlVTWS4NCg0KVGhlIHN0b3BfcXVldWUgd2FzIGNhbGxlZCBpbiB0aGUgZnVuY3Rpb24gbmV0dnNj
X3NlbmQoKSBpbiBmaWxlIG5ldHZzYy5jLCB0aGVuIGl0IHJldHVybnMgdG8gcm5kaXNfZmlsdGVy
X3NlbmQoKSwgd2hpY2ggcmV0dXJucyB0byBuZXR2c2Nfc3RhcnRfeG1pdCgpIGluIGZpbGUgbmV0
dnNjX2Rydi5jLiBTbyB0aGUgTkVUREVWX1RYX0JVU1kgaXMgaW5kZWVkIHJldHVybmVkIEFGVEVS
IHF1ZXVlIGlzIHN0b3BwZWQuDQoNClRoYW5rcywNCi0gSGFpeWFuZw0KDQo=
