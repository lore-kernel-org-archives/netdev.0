From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 21/28] net/hyperv: avoid uninitialized variable
Date: Tue, 18 Oct 2016 14:21:10 -0400 (EDT)
Message-ID: <20161018.142110.10381887028686813.davem@davemloft.net>
References: <20161017220342.1627073-1-arnd@arndb.de>
        <20161017221650.1902729-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: kys@microsoft.com, haiyangz@microsoft.com,
        torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
        vkuznets@redhat.com, stephen@networkplumber.org,
        sixiao@microsoft.com, devel@linuxdriverproject.org,
        netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161017221650.1902729-2-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogQXJuZCBCZXJnbWFubiA8YXJuZEBhcm5kYi5kZT4NCkRhdGU6IFR1ZSwgMTggT2N0IDIw
MTYgMDA6MTY6MDkgKzAyMDANCg0KPiBUaGUgaGRyX29mZnNldCB2YXJpYWJsZSBpcyBvbmx5IGlm
IHdlIGRlYWwgd2l0aCBhIFRDUCBvciBVRFAgcGFja2V0LA0KPiBidXQgYXMgdGhlIGNoZWNrIHN1
cnJvdW5kaW5nIGl0cyB1c2FnZSB0ZXN0cyBmb3Igc2tiX2lzX2dzbygpDQo+IGluc3RlYWQsIHRo
ZSBjb21waWxlciBoYXMgbm8gaWRlYSBpZiB0aGUgdmFyaWFibGUgaXMgaW5pdGlhbGl6ZWQNCj4g
b3Igbm90IGF0IHRoYXQgcG9pbnQ6DQo+IA0KPiBkcml2ZXJzL25ldC9oeXBlcnYvbmV0dnNjX2Ry
di5jOiBJbiBmdW5jdGlvbiChbmV0dnNjX3N0YXJ0X3htaXSiOg0KPiBkcml2ZXJzL25ldC9oeXBl
cnYvbmV0dnNjX2Rydi5jOjQ5NDo0MjogZXJyb3I6IKFoZHJfb2Zmc2V0oiBtYXkgYmUgdXNlZCB1
bmluaXRpYWxpemVkIGluIHRoaXMgZnVuY3Rpb24gWy1XZXJyb3I9bWF5YmUtdW5pbml0aWFsaXpl
ZF0NCj4gDQo+IFRoaXMgYWRkcyBhbiBhZGRpdGlvbmFsIGNoZWNrIGZvciB0aGUgdHJhbnNwb3J0
IHR5cGUsIHdoaWNoDQo+IHRlbGxzIHRoZSBjb21waWxlciB0aGF0IHRoaXMgcGF0aCBjYW5ub3Qg
aGFwcGVuLiBTaW5jZSB0aGUNCj4gZ2V0X25ldF90cmFuc3BvcnRfaW5mbygpIGZ1bmN0aW9uIHNo
b3VsZCBhbHdheXMgYmUgaW5saW5lZA0KPiBoZXJlLCBJIGRvbid0IGV4cGVjdCB0aGlzIHRvIHJl
c3VsdCBpbiBhZGRpdGlvbmFsIHJ1bnRpbWUNCj4gY2hlY2tzLg0KPiANCj4gU2lnbmVkLW9mZi1i
eTogQXJuZCBCZXJnbWFubiA8YXJuZEBhcm5kYi5kZT4NCg0KQXBwbGllZC4NCg==
