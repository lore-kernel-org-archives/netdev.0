From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 5/6] drivers: net: xgene-v2: Add transmit and
 receive
Date: Wed, 1 Feb 2017 11:09:44 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0277BB0@AcuExch.aculab.com>
References: <1485889401-13909-1-git-send-email-isubramanian@apm.com>
 <1485889401-13909-6-git-send-email-isubramanian@apm.com>
 <fb8fcd33-4b5b-5999-7662-4165aeb179e1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "patches@apm.com" <patches@apm.com>,
        "kchudgar@apm.com" <kchudgar@apm.com>
To: 'Florian Fainelli' <f.fainelli@gmail.com>,
        Iyappan Subramanian <isubramanian@apm.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.186]:59229 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751222AbdBALJ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 06:09:58 -0500
In-Reply-To: <fb8fcd33-4b5b-5999-7662-4165aeb179e1@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbSBGbG9yaWFuIEZhaW5lbGxpDQo+IFNlbnQ6IDMxIEphbnVhcnkgMjAxNyAyMDozMw0KPiBP
biAwMS8zMS8yMDE3IDExOjAzIEFNLCBJeWFwcGFuIFN1YnJhbWFuaWFuIHdyb3RlOg0KPiA+IFRo
aXMgcGF0Y2ggYWRkcywNCj4gPiAgICAgLSBUcmFuc21pdA0KPiA+ICAgICAtIFRyYW5zbWl0IGNv
bXBsZXRpb24gcG9sbA0KPiA+ICAgICAtIFJlY2VpdmUgcG9sbA0KPiA+ICAgICAtIE5BUEkgaGFu
ZGxlcg0KPiA+DQo+ID4gYW5kIGVuYWJsZXMgdGhlIGRyaXZlci4NCj4gPg0KPiA+IFNpZ25lZC1v
ZmYtYnk6IEl5YXBwYW4gU3VicmFtYW5pYW4gPGlzdWJyYW1hbmlhbkBhcG0uY29tPg0KPiA+IFNp
Z25lZC1vZmYtYnk6IEtleXVyIENodWRnYXIgPGtjaHVkZ2FyQGFwbS5jb20+DQo+ID4gLS0tDQo+
IA0KPiA+ICsNCj4gPiArCXR4X3JpbmcgPSBwZGF0YS0+dHhfcmluZzsNCj4gPiArCXRhaWwgPSB0
eF9yaW5nLT50YWlsOw0KPiA+ICsJbGVuID0gc2tiX2hlYWRsZW4oc2tiKTsNCj4gPiArCXJhd19k
ZXNjID0gJnR4X3JpbmctPnJhd19kZXNjW3RhaWxdOw0KPiA+ICsNCj4gPiArCS8qIFR4IGRlc2Ny
aXB0b3Igbm90IGF2YWlsYWJsZSAqLw0KPiA+ICsJaWYgKCFHRVRfQklUUyhFLCBsZTY0X3RvX2Nw
dShyYXdfZGVzYy0+bTApKSB8fA0KPiA+ICsJICAgIEdFVF9CSVRTKFBLVF9TSVpFLCBsZTY0X3Rv
X2NwdShyYXdfZGVzYy0+bTApKSkNCj4gPiArCQlyZXR1cm4gTkVUREVWX1RYX0JVU1k7DQoNCkFy
ZW4ndCB5b3Ugc3VwcG9zZWQgdG8gZGV0ZWN0ICdyaW5nIGZ1bGwnIGFuZCBzdG9wIHRoZSBjb2Rl
DQpnaXZpbmcgeW91IHBhY2tldHMgdG8gdHJhbnNtaXQuDQoNCj4gPiArDQo+ID4gKwkvKiBQYWNr
ZXQgYnVmZmVycyBzaG91bGQgYmUgNjRCIGFsaWduZWQgKi8NCg0KSXMgdGhhdCByZWFsbHkgYSBy
ZXF1aXJlbWVudCBvZiB0aGUgaGFyZHdhcmU/DQpBbG1vc3QgYWxsIGV0aGVybmV0IGZyYW1lcyBh
cmUgNG4rMiBhbGlnbmVkLg0KDQo+ID4gKwlwa3RfYnVmID0gZG1hX2FsbG9jX2NvaGVyZW50KGRl
diwgWEdFTkVfRU5FVF9TVERfTVRVLCAmZG1hX2FkZHIsDQo+ID4gKwkJCQkgICAgIEdGUF9BVE9N
SUMpOw0KPiA+ICsJaWYgKHVubGlrZWx5KCFwa3RfYnVmKSkNCj4gPiArCQlnb3RvIG91dDsNCj4g
DQo+IENhbid0IHlvdSBvYnRhaW4gYSBETUEtQVBJIG1hcHBpbmcgZm9yIHNrYi0+ZGF0YSBhbmQg
cGFzcyBpdCBkb3duIHRvIHRoZQ0KPiBoYXJkd2FyZT8gVGhpcyBjb3B5IGhlcmUgaXMgaW5lZmZp
Y2llbnQuDQo+IA0KPiA+ICsNCj4gPiArCW1lbWNweShwa3RfYnVmLCBza2ItPmRhdGEsIGxlbik7
DQoNCllvdSByZWFsbHkgbmVlZCB0byB2ZXJpZnkgdGhhdCB0aGUgbGVuIDw9IFhHRU5FX0VORVRf
U1REX01UVS4NCg0KSXNuJ3QgdGhpcyBjb2RlIG9ubHkgdHJhbnNtaXR0aW5nIHRoZSAnaGVhZCcg
b2YgdGhlIHBhY2tldD8NCldoYXQgYWJvdXQgdGhlIGZyYWdtZW50cz8/DQouLi4NCglEYXZpZA0K
DQo=
