From: =?utf-8?B?U8O4cmVuc2VuLCBTdGVmYW4=?=
        <Stefan.Sorensen@spectralink.com>
Subject: Re: [PATCH] dp83640: don't recieve time stamps twice
Date: Wed, 19 Apr 2017 09:16:56 +0000
Message-ID: <1492593414.3108.1.camel@spectralink.com>
References: <20170418191426.GA17838@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
        "richardcochran@gmail.com" <richardcochran@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170418191426.GA17838@mwanda>
Content-Language: en-US
Content-ID: <1D97270CA8024B4BBC935FF471BF1724@namprd07.prod.outlook.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T24gVHVlLCAyMDE3LTA0LTE4IGF0IDIyOjE0ICswMzAwLCBEYW4gQ2FycGVudGVyIHdyb3RlOg0K
PiBUaGlzIHBhdGNoIGlzIHByb21wdGVkIGJ5IGEgc3RhdGljIGNoZWNrZXIgd2FybmluZyBhYm91
dCBhIHBvdGVudGlhbA0KPiB1c2UgYWZ0ZXIgZnJlZS7CoMKgVGhlIGNvbmNlcm4gaXMgdGhhdCBu
ZXRpZl9yeF9uaSgpIGNhbiBmcmVlICJza2IiIGFuZA0KPiB3ZQ0KPiBjYWxsIGl0IHR3aWNlLg0K
PiANCj4gV2hlbiBJIGxvb2sgYXQgdGhlIGNvbW1pdCB0aGF0IGFkZGVkIHRoaXMsIGl0IGxvb2tz
IGxpa2Ugc29tZSBzdHJheQ0KPiBsaW5lcyB3ZXJlIGFkZGVkIGFjY2lkZW50YWxseS7CoMKgSXQg
ZG9lc24ndCBtYWtlIHNlbnNlIHRvIG1lIHRoYXQgd2UNCj4gd291bGQgcmVjaWV2ZSB0aGUgc2Ft
ZSBkYXRhIHR3byB0aW1lcy7CoMKgSSBhc2tlZCB0aGUgYXV0aG9yIGJ1dCBuZXZlcg0KPiByZWNp
ZXZlZCBhIHJlc3BvbnNlLg0KPiANCj4gSSBjYW4ndCB0ZXN0IHRoaXMgY29kZSwgYnV0IEknbSBw
cmV0dHkgc3VyZSBteSBwYXRjaCBpcyBjb3JyZWN0Lg0KDQpTb3JyeSBmb3Igbm90IGdldHRpbmcg
YmFjayBlYXJsaWVyLCBJIGhhdmUgc3dhbXBlZCB3aXRoIG90aGVyIHN0dWZmLg0KDQpZb3UgYXJl
IGNvcnJlY3QgdGhhdCB0aGVzZSBsaW5lcyB3YXMgYWRkZWQgYWNjaWRlbnRhbGx5Lg0KDQpBY2tl
ZC1ieTogU3RlZmFuIFPDuHJlbnNlbiA8c3RlZmFuLnNvcmVuc2VuQHNwZWN0cmFsaW5rLmNvbT4N
Cg0KPiANCj4gRml4ZXM6IDRiMDYzMjU4YWI5MyAoImRwODM2NDA6IERlbGF5IHNjaGVkdWxlZCB3
b3JrLiIpDQo+IFNpZ25lZC1vZmYtYnk6IERhbiBDYXJwZW50ZXIgPGRhbi5jYXJwZW50ZXJAb3Jh
Y2xlLmNvbT4NCj4gDQo+IGRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9waHkvZHA4MzY0MC5jIGIv
ZHJpdmVycy9uZXQvcGh5L2RwODM2NDAuYw0KPiBpbmRleCBlMjQ2MGE1N2U0YjEuLmVkMGQxMGY1
NGYyNiAxMDA2NDQNCj4gLS0tIGEvZHJpdmVycy9uZXQvcGh5L2RwODM2NDAuYw0KPiArKysgYi9k
cml2ZXJzL25ldC9waHkvZHA4MzY0MC5jDQo+IEBAIC0xNDM4LDggKzE0MzgsNiBAQCBzdGF0aWMg
Ym9vbCBkcDgzNjQwX3J4dHN0YW1wKHN0cnVjdCBwaHlfZGV2aWNlDQo+ICpwaHlkZXYsDQo+IMKg
CQlza2JfaW5mby0+dG1vID0gamlmZmllcyArIFNLQl9USU1FU1RBTVBfVElNRU9VVDsNCj4gwqAJ
CXNrYl9xdWV1ZV90YWlsKCZkcDgzNjQwLT5yeF9xdWV1ZSwgc2tiKTsNCj4gwqAJCXNjaGVkdWxl
X2RlbGF5ZWRfd29yaygmZHA4MzY0MC0+dHNfd29yaywNCj4gU0tCX1RJTUVTVEFNUF9USU1FT1VU
KTsNCj4gLQl9IGVsc2Ugew0KPiAtCQluZXRpZl9yeF9uaShza2IpOw0KPiDCoAl9DQo+IMKgDQo+
IMKgCXJldHVybiB0cnVlOw==
