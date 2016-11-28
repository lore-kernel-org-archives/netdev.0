From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] driver: ipvlan: Add the sanity check for
 ipvlan mode
Date: Mon, 28 Nov 2016 15:08:08 -0500 (EST)
Message-ID: <20161128.150808.1499148970176655699.davem@davemloft.net>
References: <1480339435-15551-1-git-send-email-fgao@ikuai8.com>
        <CAF2d9ji2_JhiNv9P9aUt7wV2Vfjv+z_q-MWSKKH8tzO_1THobg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: fgao@ikuai8.com, edumazet@google.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40214 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755314AbcK1UIL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 15:08:11 -0500
In-Reply-To: <CAF2d9ji2_JhiNv9P9aUt7wV2Vfjv+z_q-MWSKKH8tzO_1THobg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogTWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSw
KSA8bWFoZXNoYkBnb29nbGUuY29tPg0KRGF0ZTogTW9uLCAyOCBOb3YgMjAxNiAxMTowMjo0NSAt
MDgwMA0KDQo+IE9uIE1vbiwgTm92IDI4LCAyMDE2IGF0IDU6MjMgQU0sIDxmZ2FvQGlrdWFpOC5j
b20+IHdyb3RlOg0KPiANCj4+IEZyb206IEdhbyBGZW5nIDxmZ2FvQGlrdWFpOC5jb20+DQo+Pg0K
Pj4gVGhlIGlwdmxhbiBtb2RlIHZhcmlhYmxlICJudmFsIiBpcyBmcm9tIHVzZXJzcGFjZSwgc28g
dGhlIGlwdmxhbiBjb2Rlcw0KPj4gc2hvdWxkIGNoZWNrIGlmIHRoZSBtb2RlIHZhcmlhYmxlICJu
dmFsIiBpcyB2YWxpZC4NCj4+DQo+PiBTaWduZWQtb2ZmLWJ5OiBHYW8gRmVuZyA8Zmdhb0Bpa3Vh
aTguY29tPg0KPj4gLS0tDQo+PiAgZHJpdmVycy9uZXQvaXB2bGFuL2lwdmxhbl9tYWluLmMgfCAz
ICsrKw0KPj4gIDEgZmlsZSBjaGFuZ2VkLCAzIGluc2VydGlvbnMoKykNCj4+DQo+PiBkaWZmIC0t
Z2l0IGEvZHJpdmVycy9uZXQvaXB2bGFuL2lwdmxhbl9tYWluLmMgYi9kcml2ZXJzL25ldC9pcHZs
YW4vaXB2bGFuXw0KPj4gbWFpbi5jDQo+PiBpbmRleCBhYjkwYjIyLi41MzdiNWE5IDEwMDY0NA0K
Pj4gLS0tIGEvZHJpdmVycy9uZXQvaXB2bGFuL2lwdmxhbl9tYWluLmMNCj4+ICsrKyBiL2RyaXZl
cnMvbmV0L2lwdmxhbi9pcHZsYW5fbWFpbi5jDQo+PiBAQCAtNjUsNiArNjUsOSBAQCBzdGF0aWMg
aW50IGlwdmxhbl9zZXRfcG9ydF9tb2RlKHN0cnVjdCBpcHZsX3BvcnQgKnBvcnQsDQo+PiB1MTYg
bnZhbCkNCj4+ICAgICAgICAgc3RydWN0IG5ldF9kZXZpY2UgKm1kZXYgPSBwb3J0LT5kZXY7DQo+
PiAgICAgICAgIGludCBlcnIgPSAwOw0KPj4NCj4+ICsgICAgICAgaWYgKG52YWwgPj0gSVBWTEFO
X01PREVfTUFYKQ0KPj4gKyAgICAgICAgICAgICAgIHJldHVybiAtRUlOVkFMOw0KPj4gKw0KPj4N
Cj4gSSdtIGN1cmlvdXMgdG8ga25vdyBob3cgeW91IGVuY291bnRlcmVkIHRoaXMgaXNzdWU/IFRo
ZSB2YWx1ZXMgYXJlDQo+IHZhbGlkYXRlZCBpbiBpcHZsYW5fbmxfdmFsaWRhdGUoKSBhbmQgaXQg
c2hvdWxkIGZhaWwgYXQgdGhhdCB0aW1lIGl0c2VsZi4NCg0KSSdtIG5vdCBhcHBseWluZyB0aGlz
IHdpdGhvdXQgYXQgbGVhc3QgYSBiZXR0ZXIgZXhwbGFuYXRpb24uDQo=
