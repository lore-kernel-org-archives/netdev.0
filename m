From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 05/12] net: dsa: b53: Use a macro to define I/O
 operations
Date: Tue, 19 Sep 2017 16:14:23 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD007A2E6@AcuExch.aculab.com>
References: <20170918214128.27896-1-f.fainelli@gmail.com>
 <20170918214128.27896-6-f.fainelli@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DD007A003@AcuExch.aculab.com>
 <87tvzy93ew.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <12153E6A-CB96-4EED-91CE-05604B640927@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "andrew@lunn.ch" <andrew@lunn.ch>
To: 'Florian Fainelli' <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.194]:56029 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750972AbdISQOd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 12:14:33 -0400
In-Reply-To: <12153E6A-CB96-4EED-91CE-05604B640927@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+Pj4gKyNkZWZpbmUgYjUzX2J1aWxkX29wKHR5cGUsIG9wX3NpemUsIHZhbF90eXBlKQlcDQo+
ID4+PiArc3RhdGljIGlubGluZSBpbnQgYjUzXyMjdHlwZSMjb3Bfc2l6ZShzdHJ1Y3QgYjUzX2Rl
dmljZSAqZGV2LCB1OA0KPiA+cGFnZSwJCVwNCj4gPj4+ICsJCQkJICAgICAgdTggcmVnLCB2YWxf
dHlwZSB2YWwpCQkJXA0KPiA+Pj4gK3sJCQkJCQkJCQkJXA0KPiA+Pj4gKwlpbnQgcmV0OwkJCQkJ
CQkJXA0KPiA+Pj4gKwkJCQkJCQkJCQlcDQo+ID4+PiArCW11dGV4X2xvY2soJmRldi0+cmVnX211
dGV4KTsJCQkJCQlcDQo+ID4+PiArCXJldCA9IGRldi0+b3BzLT50eXBlIyNvcF9zaXplKGRldiwg
cGFnZSwgcmVnLCB2YWwpOwkJCVwNCj4gPj4+ICsJbXV0ZXhfdW5sb2NrKCZkZXYtPnJlZ19tdXRl
eCk7CQkJCQkJXA0KPiA+Pj4gKwkJCQkJCQkJCQlcDQo+ID4+PiArCXJldHVybiByZXQ7CQkJCQkJ
CQlcDQo+ID4+PiAgfQ0KPiA+Pg0KPiA+PiBXaHkgc2VwYXJhdGUgdGhlICd0eXBlJyBhbmQgJ29w
X3NpemUnIGFyZ3VtZW50cyBzaW5jZSB0aGV5DQo+ID4+IGFyZSBhbHdheXMgcGFzdGVkIHRvZ2V0
aGVyPw0KPiA+DQo+ID5Gb3IgcmVhZC93cml0ZTQ4LCB0aGUgdmFsdWUgdHlwZSBpcyB1NjQuDQo+
IA0KPiBUaGUgd2F5IEkgcmVhZCBEYXZpZCdzIGNvbW1lbnQgaXMgdGhhdCBpbnN0ZWFkIG9mIGNh
bGxpbmcgdGhlIG1hY3JvIHdpdGggcmVhZCwgNDgsIGp1c3QgY29tYmluZSB0aGF0DQo+IGluIGEg
c2luZ2xlIGFyZ3VtZW50OiByZWFkNDguIEkgZG9uJ3QgaGF2ZSBhIHByZWZlcmVuY2UgYWJvdXQg
dGhhdCBhbmQgY2FuIHJlc3BpbiBldmVudHVhbGx5Lg0KDQpJbmRlZWQsIGZhY3RvcmluZyBpbiB0
aGUgdHlwZSBpcyBoYXJkZXIgYmVjYXVzZSByZWFkcyB3YW50ICd1NjQgKicgbm90ICd1NjQnLg0K
V2hpbGUgdGhhdCBjb3VsZCBiZSBmYWN0b3JlZCwgaXQgd291bGQgdGFrZSBtb3JlIHNvdXJjZSBs
aW5lcyBhbmQgbWFrZQ0KdGhpbmdzIHZlcnkgb2JmdXNjYXRlZC4NCg0KCURhdmlkDQoNCg==
