From: "Machani, Yaniv" <yanivma@ti.com>
Subject: RE: [PATCH] wlcore: time sync : add support for 64 bit clock
Date: Thu, 23 Jun 2016 11:32:37 +0000
Message-ID: <AE1C82FB3D0EC64DB1F752C81CBD1101391CF584@DFRE01.ent.ti.com>
References: <20160623111332.23326-1-yanivma@ti.com>
	 (sfid-20160623_131215_419855_E4550AFE)
 <1466680680.11061.2.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Kalle Valo <kvalo@codeaurora.org>, "Mishol, Guy" <guym@ti.com>,
	"Eliad Peller" <eliad@wizery.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:37709 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751491AbcFWLco (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2016 07:32:44 -0400
In-Reply-To: <1466680680.11061.2.camel@sipsolutions.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVGh1LCBKdW4gMjMsIDIwMTYgYXQgMTQ6MTg6MDAsIEpvaGFubmVzIEJlcmcgd3JvdGU6DQo+
IGxpbnV4LXdpcmVsZXNzQHZnZXIua2VybmVsLm9yZzsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZw0K
PiBTdWJqZWN0OiBSZTogW1BBVENIXSB3bGNvcmU6IHRpbWUgc3luYyA6IGFkZCBzdXBwb3J0IGZv
ciA2NCBiaXQgY2xvY2sNCj4gDQo+IE9uIFRodSwgMjAxNi0wNi0yMyBhdCAxNDoxMiArMDMwMCwg
WWFuaXYgTWFjaGFuaSB3cm90ZToNCj4gPiBDaGFuZ2VkIHRoZSBjb25maWd1cmF0aW9uIHRvIHN1
cHBvcnQgNjRiaXQgaW5zdGVhZCBvZiAzMmJpdCB0aGlzIGluIA0KPiA+IG9yZGVyIHRvIG9mZmxv
YWQgdGhlIGRyaXZlciBmcm9tIGhhbmRsaW5nIGEgd3JhcGFyb3VuZC4NCj4gDQo+IFsuLi5dDQo+
IA0KPiBTaW5jZSB5b3UgQ2MnZWQgbWUsIGFuZCBwcmVzdW1hYmx5IHdhbnQgbWUgdG8gcmV2aWV3
IGl0LCBJJ2xsIHNheSB0aGF0IA0KPiB0aGlzIGxvb2tzIGxpa2UgYSB0ZXJyaWJsZSBpZGVhOg0K
PiANCj4gPiBAQCAtNzQsMTAgKzc0LDE2IEBAIHN0cnVjdCB3bDE4eHhfZXZlbnRfbWFpbGJveCB7
DQo+IA0KPiBUaGlzIHN0cnVjdCBpcyBldmlkZW50bHkgdXNlZCBmb3IgZmlybXdhcmUvaG9zdCBj
b21tdW5pY2F0aW9uLg0KPiANCj4gPiDCoAlfX2xlMTYgYnNzX2xvc3NfYml0bWFwOw0KPiA+DQo+
ID4gwqAJLyogYml0bWFwIG9mIHN0YXRpb25zIChieSBITElEKSB3aGljaCBleGNlZWRlZCBtYXgg
dHggcmV0cmllcyAqLw0KPiA+IC0JX19sZTMyIHR4X3JldHJ5X2V4Y2VlZGVkX2JpdG1hcDsNCj4g
PiArCV9fbGUxNiB0eF9yZXRyeV9leGNlZWRlZF9iaXRtYXA7DQo+ID4gKw0KPiA+ICsJLyogdGlt
ZSBzeW5jIGhpZ2ggbXNiKi8NCj4gPiArCXUxNiB0aW1lX3N5bmNfdHNmX2hpZ2hfbXNiOw0KPiAN
Cj4gU28gZmlyc3Qgb2YgYWxsLCBqdXN0IHVzaW5nIHUxNiBpbnN0ZWFkIG9mIF9fbGUxNiBzZWVt
cyB3cm9uZy4NCg0KQWdyZWUsIHNob3VsZCBiZSBjaGFuZ2VkLg0KDQo+IA0KPiBBZGRpdGlvbmFs
bHksIHRoaXMgbG9va3MgbGlrZSBpdCBjaGFuZ2VzIHRoZSBmaXJtd2FyZSBBUEksIHNvIHRoYXQg
DQo+IG9sZGVyIGZpcm13YXJlIGltYWdlcyB3aWxsIG5vIGxvbmdlciB3b3JrPw0KDQpJdCBpcyBi
YWNrd2FyZHMgY29tcGF0aWJsZSwgDQphbHRob3VnaCBpdCBjaGFuZ2VzIGEgQVBJIHN0cnVjdHVy
ZSwgb2xkZXIgZmlybXdhcmUgYXJlIHVzaW5nIG9ubHkgdTE2IGZvciB0aGUgZmllbGQgc28gdGhl
cmUgaXMgbm8gaW1wYWN0IG9uIHRoYXQuDQpPZiBjb3Vyc2UgdGhhdCBmb3IgYWN0dWFsbHkgdXNp
bmcgdGhlIDY0Yml0IGluZm9ybWF0aW9uLCB5b3Ugd2lsbCBoYXZlIHRvIHVwZ3JhZGUgdGhlIGZp
cm13YXJlLg0KDQpZYW5pdg0KDQo=
