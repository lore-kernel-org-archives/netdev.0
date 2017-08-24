From: Stephen Hemminger <sthemmin@microsoft.com>
Subject: RE: [PATCH net-next v3 2/7] netvsc: fix warnings reported by lockdep
Date: Thu, 24 Aug 2017 22:50:52 +0000
Message-ID: <DM2PR21MB0074A0E7FD8628A478DCBE23CC9A0@DM2PR21MB0074.namprd21.prod.outlook.com>
References: <20170728155947.10062-1-sthemmin@microsoft.com>
         <20170728155947.10062-3-sthemmin@microsoft.com>
 <1503563809.7572.90.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Woodhouse <dwmw2@infradead.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        KY Srinivasan <kys@microsoft.com>,
        "Haiyang Zhang" <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0117.outbound.protection.outlook.com ([104.47.40.117]:28549
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753335AbdHXWv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 18:51:29 -0400
In-Reply-To: <1503563809.7572.90.camel@infradead.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VGhlc2UgYXJlIGZhbHNlIHBvc2l0aXZlczsgbG9ja2RlcCBpcyBjb21wbGFpbmluZyBhYm91dCB0
aGluZ3MgdGhhdCBhcmUgc2FmZQ0KSXQgaXMganVzdCB0aGF0IGFubm90YXRpb25zIHdlcmUgbWlz
c2luZyBvciBpbmNvcnJlY3QuDQoNCi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQpGcm9tOiBE
YXZpZCBXb29kaG91c2UgW21haWx0bzpkd213MkBpbmZyYWRlYWQub3JnXSANClNlbnQ6IFRodXJz
ZGF5LCBBdWd1c3QgMjQsIDIwMTcgMTozNyBBTQ0KVG86IFN0ZXBoZW4gSGVtbWluZ2VyIDxzdGVw
aGVuQG5ldHdvcmtwbHVtYmVyLm9yZz47IEtZIFNyaW5pdmFzYW4gPGt5c0BtaWNyb3NvZnQuY29t
PjsgSGFpeWFuZyBaaGFuZyA8aGFpeWFuZ3pAbWljcm9zb2Z0LmNvbT47IFN0ZXBoZW4gSGVtbWlu
Z2VyIDxzdGhlbW1pbkBtaWNyb3NvZnQuY29tPg0KQ2M6IGRldmVsQGxpbnV4ZHJpdmVycHJvamVj
dC5vcmc7IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmcNClN1YmplY3Q6IFJlOiBbUEFUQ0ggbmV0LW5l
eHQgdjMgMi83XSBuZXR2c2M6IGZpeCB3YXJuaW5ncyByZXBvcnRlZCBieSBsb2NrZGVwDQoNCk9u
IEZyaSwgMjAxNy0wNy0yOCBhdCAwODo1OSAtMDcwMCwgU3RlcGhlbiBIZW1taW5nZXIgd3JvdGU6
DQo+IFRoaXMgaW5jbHVkZXMgYSBidW5jaCBvZiBmaXh1cHMgZm9yIGlzc3VlcyByZXBvcnRlZCBi
eQ0KPiBsb2NrZGVwLg0KPiDCoMKgwqAqIGV0aHRvb2wgcm91dGluZXMgY2FuIGFzc3VtZSBSVE5M
DQo+IMKgwqDCoCogc2VuZCBpcyBkb25lIHdpdGggUkNVIGxvY2sgKGFuZCBCSCBkaXNhYmxlKQ0K
PiDCoMKgwqAqIGF2b2lkIHJlZmV0Y2hpbmcgaW50ZXJuYWwgZGV2aWNlIHN0cnVjdCAobmV0dnNj
KQ0KPiDCoMKgwqDCoMKgaW5zdGVhZCBwYXNzIGl0IGFzIGEgcGFyYW1ldGVyLg0KPiANCj4gU2ln
bmVkLW9mZi1ieTogU3RlcGhlbiBIZW1taW5nZXIgPHN0aGVtbWluQG1pY3Jvc29mdC5jb20+DQoN
ClRoZSBzdWJqZWN0IGFuZCB0aGUgY29tbWl0IG1lc3NhZ2UgYXJlIGluY29uc2lzdGVudCDigJQg
aXMgdGhpcyBmaXhpbmcNCip3YXJuaW5ncyogKGkuZS4gc2h1dCB1cCBhIGZhbHNlIHBvc2l0aXZl
KSwgb3IgaXMgaXQgZml4aW5nICppc3N1ZXMqPw0KSXQgbG9va3MgbGlrZSBpdCdzIGFjdHVhbGx5
IGZpeGluZyBpc3N1ZXMsIG5vdCBqdXN0IHdhcm5pbmdzPw0KDQpJdCdzIHJlYWxseSB1c2VmdWwg
dG8gZ2V0IHRoYXQgcmlnaHQuDQoNCkZXSVcgdGhlIHJlYXNvbiBJJ20gbG9va2luZyBpbiBteSBu
ZXRkZXZAIGZvbGRlciBmb3IgbG9ja2RlcCB3YXJuaW5nDQpmaXhlcyBpcyBiZWNhdXNlIEkgd2Fz
IHRyeWluZyB0byBjb25maXJtIHdoZXRoZXIgdGhlIGNvbW1pdCBtZXNzYWdlIGluDQpodHRwczov
L3BhdGNod29yay5rZXJuZWwub3JnL3BhdGNoLzQzNzIzOTEvwqBpcyBhY3R1YWxseSB0ZWxsaW5n
IHRoZQ0KdHJ1dGggb3Igbm90IOKAlCBpbiB0aGF0IGNhc2UgSSB0aGluayBpdCAqaXMqIGp1c3Qg
YSBmYWxzZSBwb3NpdGl2ZSBiZWluZw0Kc2h1dCB1cCAoYW5kIHRodXMgaXQncyBPSyB0byBzYXkg
ImZpeCB3YXJuaW5nIiksIG5vdCByZWFsbHkgZml4aW5nIGENCnRydWUgaXNzdWUuDQo=
