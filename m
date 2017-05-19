From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC V1 1/1] net: cdc_ncm: Reduce memory use when kernel memory
 low
Date: Fri, 19 May 2017 14:46:34 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFFAC2B@AcuExch.aculab.com>
References: <1494956480-6127-1-git-send-email-jim_baxter@mentor.com>
        <1494956480-6127-2-git-send-email-jim_baxter@mentor.com>
        <063D6719AE5E284EB5DD2968C1650D6DCFFFAA5C@AcuExch.aculab.com>
 <87pof5rlw4.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: 'Jim Baxter' <jim_baxter@mentor.com>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Oliver Neukum <oliver@neukum.org>
To: =?utf-8?B?J0Jqw7hybiBNb3JrJw==?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87pof5rlw4.fsf@miraculix.mork.no>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogQmrDuHJuIE1vcmsNCj4gU2VudDogMTkgTWF5IDIwMTcgMTQ6NTYNCi4uLg0KPiBVbmxl
c3Mgc29tZW9uZSBoYXMgYSBuaWNlIHdheSB0byBqdXN0IGNvbGxlY3QgYSBsaXN0IG9mIHNrYnMg
YW5kIGhhdmUNCj4gdGhlbSBjb252ZXJ0ZWQgdG8gcHJvcGVyIGZyYW1pbmcgb24gdGhlIGZseSB3
aGVuIHRyYW5zbWl0dGluZywgd2l0aG91dA0KPiBoYXZpbmcgdG8gY2FyZSBhYm91dCBVU0IgcGFj
a2V0IGJvdW5kYXJpZXMuDQoNCnNrYiBjYW4gYmUgbGlua2VkIGludG8gYXJiaXRyYXJ5IGNoYWlu
cyAob3IgZXZlbiB0cmVlcyksIGJ1dCBJIHN1c3BlY3QNCnRoZSB1c2JuZXQgY29kZSB3b3VsZCBu
ZWVkIHRvIGJlIHRhdWdodCBhYm91dCB0aGVtLg0KDQpGb3IgWEhDSSBpdCBpc24ndCB0b28gYmFk
IGJlY2F1c2UgaXQgd2lsbCBkbyBhcmJpdHJhcnkgc2NhdHRlci1nYXRoZXINCihhcGFydCBmcm9t
IHRoZSByaW5nIGVuZCkuDQpCdXQgSSBiZWxpZXZlIHRoZSBlYXJsaWVyIGNvbnRyb2xsZXJzIG9u
bHkgc3VwcG9ydCBmcmFnbWVudHMgdGhhdA0KZW5kIG9uIHVzYiBwYWNrZXQgYm91bmRhcmllcy4N
Cg0KSSBsb29rZWQgYXQgdGhlIHVzYm5ldCBjb2RlIGEgZmV3IHllYXJzIGFnbywgSSdtIHN1cmUg
aXQgb3VnaHQgdG8NCmJlIHBvc3NpYmxlIHRvIHNob3J0Y3V0IG1vc3Qgb2YgdGhlIGNvZGUgdGhh
dCB1c2VzIFVSQiBhbmQgZGlyZWN0bHkNCndyaXRlIHRvIHRoZSB4aGNpIChpbiBwYXJ0aWN1bGFy
KSByaW5nIGRlc2NyaXB0b3JzLg0KDQpGb3IgcmVjZWl2ZSB5b3UgcHJvYmFibHkgd2FudCB0byBm
ZWVkIHRoZSBVU0Igc3RhY2sgbXVsdGlwbGUgKHByb2JhYmx5KQ0KMmsgYnVmZmVycywgYW5kIGhh
bmRsZSB0aGUgZGViYXRjaGluZyBpbnRvIGV0aGVybmV0IGZyYW1lcyB5b3Vyc2VsZi4NCg0KT25l
IG9mIHRoZSBBU0lYIGRyaXZlcnMgdXNlZCB0byBiZSBwYXJ0aWN1bGFybHkgYmFkLCBpdCBhbGxv
Y2F0ZWQgNjRrDQpza2IgZm9yIHJlY2VpdmUgKHRoZSBoYXJkd2FyZSBjYW4gbWVyZ2UgSVAgcGFj
a2V0cykgYW5kIHRoZW4gaGFja2VkDQp0aGUgdHJ1ZV9zaXplIGJlZm9yZSBwYXNzaW5nIHVwc3Ry
ZWFtLg0KDQoJRGF2aWQNCg0K
