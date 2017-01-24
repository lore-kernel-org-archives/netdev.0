From: "Valo, Kalle" <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH 2/3] ath10k: use dma_zalloc_coherent()
Date: Tue, 24 Jan 2017 12:13:32 +0000
Message-ID: <87r33s8xli.fsf@kamboji.qca.qualcomm.com>
References: <1485183876-27080-1-git-send-email-srinivas.kandagatla@linaro.org>
        <1485183876-27080-2-git-send-email-srinivas.kandagatla@linaro.org>
        <1485213569.12563.32.camel@perches.com> <8737g9ox1k.fsf@qca.qualcomm.com>
        <1485235529.12563.39.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>,
        "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485235529.12563.39.camel@perches.com> (Joe Perches's message of
        "Mon, 23 Jan 2017 21:25:29 -0800")
Content-Language: en-US
Content-ID: <D2CB9CBD79516E498B2F4D65B2F8C6ED@qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sm9lIFBlcmNoZXMgPGpvZUBwZXJjaGVzLmNvbT4gd3JpdGVzOg0KDQo+IE9uIFR1ZSwgMjAxNy0w
MS0yNCBhdCAwNToxOCArMDAwMCwgVmFsbywgS2FsbGUgd3JvdGU6DQo+PiBKb2UgUGVyY2hlcyA8
am9lQHBlcmNoZXMuY29tPiB3cml0ZXM6DQo+PiANCj4+ID4gT24gTW9uLCAyMDE3LTAxLTIzIGF0
IDE1OjA0ICswMDAwLCBTcmluaXZhcyBLYW5kYWdhdGxhIHdyb3RlOg0KPj4gPiA+IHVzZSBkbWFf
emFsbG9jX2NvaGVyZW50KCkgaW5zdGVhZCBvZiBkbWFfYWxsb2NfY29oZXJlbnQgYW5kIG1lbXNl
dCgpLg0KPj4gPiANCj4+ID4gW10NCj4+ID4gPiBkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvd2ly
ZWxlc3MvYXRoL2F0aDEway9wY2kuYw0KPj4gPiA+IGIvZHJpdmVycy9uZXQvd2lyZWxlc3MvYXRo
L2F0aDEway9wY2kuYw0KPj4gPiANCj4+ID4gW10NCj4+ID4gPiBAQCAtODk2LDcgKzg5Niw3IEBA
IHN0YXRpYyBpbnQgYXRoMTBrX3BjaV9kaWFnX3JlYWRfbWVtKHN0cnVjdCBhdGgxMGsgKmFyLCB1
MzIgYWRkcmVzcywgdm9pZCAqZGF0YSwNCj4+ID4gPiAgCSAqLw0KPj4gPiA+ICAJYWxsb2NfbmJ5
dGVzID0gbWluX3QodW5zaWduZWQgaW50LCBuYnl0ZXMsIERJQUdfVFJBTlNGRVJfTElNSVQpOw0K
Pj4gPiA+ICANCj4+ID4gPiAtCWRhdGFfYnVmID0gKHVuc2lnbmVkIGNoYXIgKilkbWFfYWxsb2Nf
Y29oZXJlbnQoYXItPmRldiwNCj4+ID4gPiArCWRhdGFfYnVmID0gKHVuc2lnbmVkIGNoYXIgKilk
bWFfemFsbG9jX2NvaGVyZW50KGFyLT5kZXYsDQo+PiA+ID4gIAkJCQkJCSAgICAgICBhbGxvY19u
Ynl0ZXMsDQo+PiA+ID4gIAkJCQkJCSAgICAgICAmY2VfZGF0YV9iYXNlLA0KPj4gPiA+ICAJCQkJ
CQkgICAgICAgR0ZQX0FUT01JQyk7DQo+PiA+IA0KPj4gPiB0cml2aWE6DQo+PiA+IA0KPj4gPiBO
aWNlciB0byByZWFsaWduIGFyZ3VtZW50cyBhbmQgcmVtb3ZlIHRoZSB1bm5lY2Vzc2FyeSBjYXN0
Lg0KPj4gPiANCj4+ID4gUGVyaGFwczoNCj4+ID4gDQo+PiA+IAlkYXRhX2J1ZiA9IGRtYV96YWxs
b2NfY29oZXJlbnQoYXItPmRldizCoGFsbG9jX25ieXRlcywgJmNlX2RhdGFfYmFzZSwNCj4+ID4g
CQkJCSAgICAgIMKgR0ZQX0FUT01JQyk7DQo+PiANCj4+IFN1cmUsIGJ1dCB0aGF0IHNob3VsZCBi
ZSBpbiBhIHNlcGFyYXRlIHBhdGNoLg0KPg0KPiBJIGRvbid0IHRoaW5rIHNvLCB0cml2aWFsIHBh
dGNoZXMgY2FuIGJlIGNvbWJpbmVkLg0KPg0KPiBJdCdzIGFsc28gbmljZXIgdG8gcmVhbGlnbiBh
bGwgbW9kaWZpZWQgbXVsdGlsaW5lDQo+IGFyZ3VtZW50cyB3aGVuIHBlcmZvcm1pbmcgdGhlc2Ug
Y2hhbmdlcy4NCj4NCj4gQ29jY2luZWxsZSBnZW5lcmFsbHkgZG9lcyBpdCBhdXRvbWF0aWNhbGx5
Lg0KDQpBIG1hdHRlciBvZiBwcmVmZXJlbmNlIHJlYWxseS4gSSBwcmVmZXIga2VlcGluZyBzdHls
ZSBhbmQgZnVuY3Rpb25hbA0KY2hhbmdlcyBpbiBzZXBhcmF0ZSBwYXRjaGVzLCBrZWVwcyB0aGUg
cmV2aWV3IHNpbXBsZS4gQW5kIHN0eWxlIGNoYW5nZXMNCmNhbiBoaWRlIGJ1Z3MuDQoNCi0tIA0K
S2FsbGUgVmFsbw==
