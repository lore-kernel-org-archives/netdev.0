From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 net] net: solve a NAPI race
Date: Thu, 2 Mar 2017 10:24:42 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFE733A0@AcuExch.aculab.com>
References: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488166294.9415.172.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAKgT0UeSpxzgePoidJumQFvM5a2mOC5+rL8gCHqvX-HBvrn74A@mail.gmail.com>
         <063D6719AE5E284EB5DD2968C1650D6DCFE727EB@AcuExch.aculab.com>
         <CAKgT0Ud7dPwyj4Ze4HRJOXTpywBF8VZrELQAay-Sxsv+7+Pozw@mail.gmail.com>
 <1488389559.9415.300.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "Tariq Toukan" <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.184]:51896 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750743AbdCBKZG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 05:25:06 -0500
In-Reply-To: <1488389559.9415.300.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IFNlbnQ6IDAxIE1hcmNoIDIwMTcgMTc6MzMNCj4gT24gV2Vk
LCAyMDE3LTAzLTAxIGF0IDA4OjE0IC0wODAwLCBBbGV4YW5kZXIgRHV5Y2sgd3JvdGU6DQo+IA0K
PiA+IFdoYXQgYnVpbGQgZmxhZ3MgYXJlIHlvdSB1c2luZz8gIFdpdGggLU9zIG9yIC1PMiBJIGhh
dmUgc2VlbiBpdA0KPiA+IGNvbnZlcnQgdGhlIC9iICogYyBpbnRvIGEgc2luZ2xlIHNoaWZ0Lg0K
PiA+DQo+IA0KPiANCj4gQmVjYXVzZSBiICYgYyBhcmUgdW5zaWduZWQgaW4gb3VyIGNhc2UuDQo+
IA0KPiBJIHByZXN1bWUgRGF2aWQgdHJpZWQgc2lnbmVkIGludGVnZXJzLCB0aGlzIGlzIHdoeSBn
Y2MgZG9lcyB0aGF0Lg0KDQpJIHdhcyB1c2luZyBpbnRlZ2VyIGNvbnN0YW50cyBidXQgYW4gdW5z
aWduZWQgdmFyaWFibGUuDQpDaGFuZ2luZyB0aGUgY29uc3RhbnRzIHRvIHVuc2lnbmVkIG1ha2Vz
IG5vIGRpZmZlcmVuY2UgKHRoZXkgd291bGQgZ2V0DQpwcm9tb3RlZCBhbnl3YXkpLg0KDQpBZnRl
ciBzb21lIGV4cGVyaW1lbnRzIEkgY2FuIGdldCBnY2MgdG8gZ2VuZXJhdGUgYSBzaW5nbGUgc2hp
ZnQgaWYgdGhlDQp2YXJpYWJsZSBiZWluZyB0ZXN0ZWQgaXMgMzJiaXRzLCB0aGUgY29uc3RhbnRz
IGFyZSA2NGJpdHMgYW5kIGEgNjRiaXQNCnJlc3VsdCBpcyByZXF1aXJlZC4NCkluIGV2ZXJ5IG90
aGVyIGNhc2UgaXQgZG9lcyBlaXRoZXIgYW5kLXNoci1zaGwgb3Igc2hyLWFuZC1zaGwgKGFsbCB0
aGUNCnNociBhcmUgbG9naWNhbCkuDQoNCglEYXZpZA0K
