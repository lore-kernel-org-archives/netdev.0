From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [Intel-wired-lan] [RFC PATCH] i40e: enable PCIe relax ordering
 for SPARC
Date: Thu, 8 Dec 2016 10:31:21 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB02382B2@AcuExch.aculab.com>
References: <1480957627-16825-1-git-send-email-tushar.n.dave@oracle.com>
 <CAKgT0UcyRSub0NCi7oHX2Vf+N4vQxzwdWmcc+V+jOX_J=RYgfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>
To: 'Alexander Duyck' <alexander.duyck@gmail.com>,
        Tushar Dave <tushar.n.dave@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.191]:51432 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753008AbcLHKb3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 05:31:29 -0500
In-Reply-To: <CAKgT0UcyRSub0NCi7oHX2Vf+N4vQxzwdWmcc+V+jOX_J=RYgfg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQWxleGFuZGVyIER1eWNrDQo+IFNlbnQ6IDA1IERlY2VtYmVyIDIwMTYgMjE6NTUNCi4u
Lg0KPiA+IEBAIC0xMDEwLDYgKzEwMTgsMTEgQEAgaW50IGk0MGVfc2V0dXBfdHhfZGVzY3JpcHRv
cnMoc3RydWN0IGk0MGVfcmluZyAqdHhfcmluZykNCj4gPiAgICAgICAgICAqLw0KPiA+ICAgICAg
ICAgdHhfcmluZy0+c2l6ZSArPSBzaXplb2YodTMyKTsNCj4gPiAgICAgICAgIHR4X3JpbmctPnNp
emUgPSBBTElHTih0eF9yaW5nLT5zaXplLCA0MDk2KTsNCj4gPiArI2lmZGVmIENPTkZJR19TUEFS
Qw0KPiA+ICsgICAgICAgdHhfcmluZy0+ZG1hX2F0dHJzID0gRE1BX0FUVFJfV0VBS19PUkRFUklO
RzsNCj4gPiArI2Vsc2UNCj4gPiArICAgICAgIHR4X3JpbmctPmRtYV9hdHRycyA9IDA7DQo+ID4g
KyNlbmRpZg0KPiA+ICAgICAgICAgdHhfcmluZy0+ZGVzYyA9IGRtYV9hbGxvY19jb2hlcmVudChk
ZXYsIHR4X3JpbmctPnNpemUsDQo+ID4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICZ0eF9yaW5nLT5kbWEsIEdGUF9LRVJORUwpOw0KPiA+ICAgICAgICAgaWYgKCF0
eF9yaW5nLT5kZXNjKSB7DQo+IA0KPiBBbHNvIG5vdCBhIGZhbiBvZiBhZGRpbmcgeWV0IHJpbmcg
YXR0cmlidXRlLiAgSXMgdGhlcmUgYW55IHJlYXNvbiB3aHkNCj4geW91IGNvdWxkbid0IHNpbXBs
eSBhZGQgYSBzZXQgb2YgaW5saW5lIGZ1bmN0aW9ucyBhdCB0aGUgc3RhcnQgb2YNCj4gaTQwZV90
eHJ4LmMgdGhhdCBjb3VsZCByZXBsYWNlIHRoZSBETUEgbWFwL3VubWFwIG9wZXJhdGlvbnMgaW4g
dGhpcw0KPiBjb2RlIGJ1dCBwYXNzIGVpdGhlciAwIG9yIERNQV9BVFRSX1dFQUtfT1JERVJJTkcg
YXMgbmVlZGVkIGZvciB0aGUNCj4gZHJpdmVycz8gIFRoZW4gdGhlIHg4NiBjb2RlIGRvZXNuJ3Qg
aGF2ZSB0byBjaGFuZ2Ugd2hpbGUgdGhlIFNQQVJDDQo+IGNvZGUgd2lsbCBiZSBhYmxlIHRvIGJl
IHBhc3NlZCB0aGUgYXR0cmlidXRlLg0KDQpPciB1c2Ugc29tZXRoaW5nIGxpa2U6DQojaWZkZWYg
Q09ORklHX1NQQVJDDQogICAgICAgI2RlZmluZSBSSU5HX0RNQV9BVFRSIERNQV9BVFRSX1dFQUtf
T1JERVJJTkcNCiNlbHNlDQogICAgICAgI2RlZmluZSBSSU5HX0RNQV9BVFRSIDANCiNlbmRpZg0K
YW5kIHBhc3MgdGhlIGNvbnN0YW50IHRvIHRoZSBmdW5jdGlvbiBjYWxscy4NCg0KSXMgdGhlcmUg
YWN0dWFsbHkgZXZlciBhIHByb2JsZW0gcGFzc2luZyBETUFfQVRUUl9XRUFLX09SREVSSU5HPw0K
SSdkIGd1ZXNzIHRoYXQgaXQgd2lsbCBiZSBpZ25vcmVkIGlmIGl0IGNhbid0IGJlIGltcGxlbWVu
dGVkIChvciBpc24ndCBuZWVkZWQpLg0KDQoJRGF2aWQNCg0K
