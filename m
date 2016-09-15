From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] tcp: fix overflow in __tcp_retransmit_skb()
Date: Thu, 15 Sep 2016 15:52:06 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB00FDAFC@AcuExch.aculab.com>
References: <1473952353.22679.25.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.195]:51632 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752083AbcIOPyW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 11:54:22 -0400
In-Reply-To: <1473952353.22679.25.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IFNlbnQ6IDE1IFNlcHRlbWJlciAyMDE2IDE2OjEzDQo+IElm
IGEgVENQIHNvY2tldCBnZXRzIGEgbGFyZ2Ugd3JpdGUgcXVldWUsIGFuIG92ZXJmbG93IGNhbiBo
YXBwZW4NCj4gaW4gYSB0ZXN0IGluIF9fdGNwX3JldHJhbnNtaXRfc2tiKCkgcHJldmVudGluZyBh
bGwgcmV0cmFuc21pdHMuDQouLi4NCj4gIAlpZiAoYXRvbWljX3JlYWQoJnNrLT5za193bWVtX2Fs
bG9jKSA+DQo+IC0JICAgIG1pbihzay0+c2tfd21lbV9xdWV1ZWQgKyAoc2stPnNrX3dtZW1fcXVl
dWVkID4+IDIpLCBzay0+c2tfc25kYnVmKSkNCj4gKwkgICAgbWluX3QodTMyLCBzay0+c2tfd21l
bV9xdWV1ZWQgKyAoc2stPnNrX3dtZW1fcXVldWVkID4+IDIpLA0KPiArCQkgIHNrLT5za19zbmRi
dWYpKQ0KPiAgCQlyZXR1cm4gLUVBR0FJTjsNCg0KTWlnaHQgaXQgYWxzbyBiZSBiZXR0ZXIgdG8g
c3BsaXQgdGhhdCB0ZXN0IHRvIChzYXkpOg0KDQoJdTMyIHdtZW1fYWxsb2MgPSBhdG9taWNfcmVh
ZCgmc2stPnNrX3dtZW1fYWxsb2MpOw0KCWlmICh1bmxpa2VseSgod21lbV9hbGxvYyA+IHNrLT5z
a19zbmRidWYpKQ0KCQlyZXR1cm4gLUVBR0FJTjsNCglpZiAodW5saWtlbHkod21lbV9hbGxvYyA+
IHNrLT5za193bWVtX3F1ZXVlZCArIChzay0+c2tfd21lbV9xdWV1ZWQgPj4gMikpKQ0KCQlyZXR1
cm4gLUVBR0FJTjsNCg0KSXQgbWlnaHQgZXZlbiBiZSB3b3J0aCBzcGxpdHRpbmcgdGhlIHNlY29u
ZCB0ZXN0IGFzOg0KDQoJaWYgKHVubGlrZWx5KHdtZW1fYWxsb2MgPiBzay0+c2tfd21lbV9xdWV1
ZWQpDQoJICAgICYmIHdtZW1fYWxsb2MgPiBzay0+c2tfd21lbV9xdWV1ZWQgKyAoc2stPnNrX3dt
ZW1fcXVldWVkID4+IDIpKQ0KCQlyZXR1cm4gLUVBR0FJTjsNCg0KCURhdmlkDQoNCg==
