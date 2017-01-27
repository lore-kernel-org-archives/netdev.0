From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] net: adjust skb->truesize in pskb_expand_head()
Date: Fri, 27 Jan 2017 17:24:49 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0270F3E@AcuExch.aculab.com>
References: <1485476480.5145.194.camel@edumazet-glaptop3.roam.corp.google.com>
         <063D6719AE5E284EB5DD2968C1650D6DB0270970@AcuExch.aculab.com>
 <1485528261.6360.38.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "Slava Shwartsman" <slavash@mellanox.com>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.187]:50827 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933253AbdA0RyN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 12:54:13 -0500
In-Reply-To: <1485528261.6360.38.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IFNlbnQ6IDI3IEphbnVhcnkgMjAxNyAxNDo0NA0KLi4uDQo+
ID4gSSdtIGFsc28gZ3Vlc3NpbmcgdGhhdCBleHRyYSBoZWFkcm9vbSBjYW4gYmUgZ2VuZXJhdGVk
IGJ5IHN0ZWFsaW5nIHVudXNlZCB0YWlscm9vbS4NCj4gDQo+IFRoaXMgaXMgYWxyZWFkeSBkb25l
Lg0KPiANCj4gUXVvdGluZw0KPiBodHRwczovL2dpdC5rZXJuZWwub3JnL2NnaXQvbGludXgva2Vy
bmVsL2dpdC90b3J2YWxkcy9saW51eC5naXQvY29tbWl0Lz9pZD04N2ZiNGI3YjUzMzA3M2VlZWFl
ZDBiNmJmN2MNCj4gMjMyODk5NWY2YzA3NQ0KPiANCj4gICAgIEF0IHNrYiBhbGxvYyBwaGFzZSwg
d2UgcHV0IHNrYl9zaGFyZWRfaW5mbyBzdHJ1Y3QgYXQgdGhlIGV4YWN0IGVuZCBvZg0KPiAgICAg
c2tiIGhlYWQsIHRvIGFsbG93IGEgYmV0dGVyIHVzZSBvZiBtZW1vcnkgKGxvd2VyaW5nIG51bWJl
ciBvZg0KPiAgICAgcmVhbGxvY2F0aW9ucyksIHNpbmNlIGttYWxsb2MoKSBnaXZlcyB1cyBwb3dl
ci1vZi10d28gbWVtb3J5IGJsb2Nrcy4NCg0KRG9lcyB0aGF0IGFjdHVhbGx5IGhhdmUgdGhlIGV4
cGVjdGVkIGVmZmVjdD8NCg0KQWxsb2NhdGUgYW4gc2tiIGZvciA1MTIgYnl0ZXMsIGNvcHkgaW4g
c29tZSBkYXRhIHdpdGggNjQgYnl0ZXMgb2YgaGVhZHJvb20uDQpUaGlzIGlzIChwcm9iYWJseSkg
YSAxayBtZW1vcnkgYmxvY2sgd2l0aCBza2Jfc2hhcmVkX2luZm8gYXQgdGhlIGVuZC4NCg0KU29t
ZSBjb2RlIG5lZWRzIHRvIGFkZCBhIGhlYWRlciB0aGF0IGRvZXNuJ3QgZml0LCBjYWxscyBwc2ti
X2V4cGFuZF9oZWFkKCkNCnRvIGdldCBhbm90aGVyIDQgYnl0ZXMuDQpTaW5jZSB0aGUgZXhpc3Rp
bmcgYW1vdW50IG9mICd0YWlscm9vbScgbXVzdCBiZSBrZXB0IGttYWxsb2MoMTAyNCs0KSBpcyBj
YWxsZWQuDQpUaGlzIGFsbG9jYXRlcyBhIDJrIG1lbW9yeSBibG9jaywgYWdhaW4gc2tiX3NoYXJl
ZF9pbmZvIGlzIHB1dCBhdCB0aGUgZW5kLg0KU28gdGhlIGhlYWRyb29tIGhhcyBiZWVuIGluY3Jl
YXNlZCBieSA0IGJ5dGVzIGFuZCB0aGUgdGFpbHJvb20gYnkgMTAyMC4NCg0KQW5vdGhlciBsYXll
ciBuZWVkcyB0byBhZGQgYW5vdGhlciBoZWFkZXIuDQpUaGUgbWVtb3J5IGJsb2NrIGJlY29tZXMg
NGsgbGFyZ2UuDQoNCldoYXQgaGF2ZSBJIG1pc3NlZD8NCg0KCURhdmlkDQoNCg==
