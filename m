From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v6 1/5] skbuff: return -EMSGSIZE in skb_to_sgvec to
 prevent overflow
Date: Thu, 27 Apr 2017 14:54:14 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFE0675@AcuExch.aculab.com>
References: <20170425155215.4835-1-Jason@zx2c4.com>
 <20170425184734.26563-1-Jason@zx2c4.com>
 <CAHmME9qDmcvzF_xeaxegC2RpBOs8PziJOaKEqv6Z_X1pUFbR0w@mail.gmail.com>
 <20170427113016.GA12448@bistromath.localdomain>
 <CAHmME9oa3LYsnBgguxFqbJwps1ai=cuHHEgSpfY36AQHAN5r1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        David Miller <davem@davemloft.net>
To: "'Jason A. Donenfeld'" <Jason@zx2c4.com>,
        Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.183]:65151 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753979AbdD0Oya (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 10:54:30 -0400
In-Reply-To: <CAHmME9oa3LYsnBgguxFqbJwps1ai=cuHHEgSpfY36AQHAN5r1Q@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSmFzb24gQS4gRG9uZW5mZWxkDQo+IE9uIFRodSwgQXByIDI3LCAyMDE3IGF0IDE6MzAg
UE0sIFNhYnJpbmEgRHVicm9jYSA8c2RAcXVlYXN5c25haWwubmV0PiB3cm90ZToNCj4gPiBIbW0s
IEkgdGhpbmsgdGhpcyBjYW4gYWN0dWFsbHkgaGFwcGVuOg0KPiANCj4gQWxyaWdodCwgcGVyaGFw
cyBiZXR0ZXIgdG8gZXJyIG9uIHRoZSBzaWRlIG9mIGNhdXRpb24sIHRoZW4uDQoNCllvdSBvbmx5
IG5lZWQgdG8gcmVjdXJzZSBpZiBib3RoIHBvaW50ZXJzIGFyZSBzZXQuDQoNCglEYXZpZA0KDQo=
