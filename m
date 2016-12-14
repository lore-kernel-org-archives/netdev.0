From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/3] netns: fix net_generic() "id - 1" bloat
Date: Wed, 14 Dec 2016 14:41:51 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB023F798@AcuExch.aculab.com>
References: <20161202012132.GD31170@avx2>
 <063D6719AE5E284EB5DD2968C1650D6DB0234CCB@AcuExch.aculab.com>
 <CACVxJT8axg6i0Lvem=fvKqrjTuOzwg63BDbAuR6bzTPrtLuP+g@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0236F41@AcuExch.aculab.com>
 <CACVxJT8fT0Lbe_ojNjU9DYYO=PO+QzA=jpQb7V6_US8W9D-KTQ@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB023DBE9@AcuExch.aculab.com>
 <CACVxJT9HAMex1Pa+VbTVJwDPuY_dnfgfQgAZFSjMuUmgCiZD1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xemul@openvz.org" <xemul@openvz.org>
To: 'Alexey Dobriyan' <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.194]:52501 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755099AbcLNOmA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 09:42:00 -0500
In-Reply-To: <CACVxJT9HAMex1Pa+VbTVJwDPuY_dnfgfQgAZFSjMuUmgCiZD1w@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQWxleGV5IERvYnJpeWFuIA0KPiBTZW50OiAxNCBEZWNlbWJlciAyMDE2IDEzOjIwDQou
Li4NCj4gPiBJZiB5b3UgaGF2ZSBmb28tPmJhcltpZCAtIGNvbnN0XSB0aGVuIHRoZSBjb21waWxl
ciBoYXMgdG8gYWRkIHRoZQ0KPiA+IG9mZnNldCBvZiAnYmFyJyBhbmQgc3VidHJhY3QgZm9yICdj
b25zdCcuDQo+ID4gSWYgdGhlIG51bWJlcnMgbWF0Y2ggbm8gYWRkIG9yIHN1YnRyYWN0IGlzIG5l
ZWRlZC4NCj4gPg0KPiA+IEl0IGlzIG11Y2ggY2xlYW5lciB0byBkbyB0aGlzIGJ5IGV4cGxpY2l0
bHkgcmVtb3ZpbmcgdGhlIG9mZnNldCBvbiB0aGUNCj4gPiBhY2Nlc3NlcyB0aGFuIHVzaW5nIGEg
dW5pb24uDQo+IA0KPiBTdXJwcmlzaW5nbHksIHRoZSB0cmljayBvbmx5IHdvcmtzIGlmIGFycmF5
IGluZGV4IGlzIGNhc3QgdG8gInVuc2lnbmVkIGxvbmciDQo+IGJlZm9yZSBzdWJ0cmFjdGluZy4N
Cj4gDQo+IENvZGUgYmVjb21lcw0KPiANCj4gICAgIC4uLg0KPiAgICAgcHRyID0gbmctPnB0clso
dW5zaWduZWQgbG9uZylpZCAtIDNdOw0KPiAgICAgLi4uDQoNClRoZSBjb21waWxlciBtYXkgYWxz
byBiZSBhYmxlIHRvIG9wdGltaXNlIGl0IGF3YXkgaWYgJ2lkJyBpcyAnaW50Jw0KcmF0aGVyIHRo
YW4gJ3Vuc2lnbmVkIGludCcuDQoNCk9oLCBpZiB5b3UgbmVlZCBjYXN0cyBsaWtlIHRoYXQgdXNl
IGFuIGFjY2Vzc29yIGZ1bmN0aW9uLg0KDQoJRGF2aWQNCg0KDQo=
