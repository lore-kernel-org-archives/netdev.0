From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 net] net: solve a NAPI race
Date: Tue, 28 Feb 2017 10:14:43 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFE71AA0@AcuExch.aculab.com>
References: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488166294.9415.172.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488226711.9415.204.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170227141403.714490f7@xeon-e3>
 <1488234917.9415.217.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.191]:55657 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751026AbdB1KVf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 05:21:35 -0500
In-Reply-To: <1488234917.9415.217.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IFNlbnQ6IDI3IEZlYnJ1YXJ5IDIwMTcgMjI6MzUNCj4gT24g
TW9uLCAyMDE3LTAyLTI3IGF0IDE0OjE0IC0wODAwLCBTdGVwaGVuIEhlbW1pbmdlciB3cm90ZToN
Cj4gDQo+ID4gVGhlIG9yaWdpbmFsIGRlc2lnbiAoYXMgRGF2ZW0gbWVudGlvbmVkKSB3YXMgdGhh
dCBJUlEncyBtdXN0IGJlIGRpc2FibGVkDQo+ID4gZHVyaW5nIGRldmljZSBwb2xsaW5nLiBJZiB0
aGF0IHdhcyB0cnVlLCB0aGVuIHRoZSByYWNlIGFib3ZlDQo+ID4gd291bGQgYmUgaW1wb3NzaWJs
ZS4NCj4gDQo+IEkgd291bGQgbG92ZSB0byBzZWUgYW4gYWx0ZXJuYXRpdmUgcGF0Y2guDQoNCkNh
biB5b3UgdGVzdCBmb3IgJ3JlY2VpdmUgZGF0YSBhdmFpbGFibGUnIGFmdGVyIHRlbGxpbmcgdGhl
IE5BUEkNCmxvZ2ljIHRoYXQgeW91J3ZlIGZpbmlzaGVkPw0KWW91J2QgdGhlbiBuZWVkIHRvIGZv
cmNlIGEgcmVzY2hlZHVsZS4NCg0KSSB0aGluayB5b3VyIHByb3Bvc2VkIHBhdGNoIHdpbGwgZG8g
YSByZXNjaGVkdWxlIGlmIGFueSBwYWNrZXQgYXJyaXZlcw0KZHVyaW5nIHRoZSByZWNlaXZlIHBy
b2Nlc3NpbmcsIG5vdCBqdXN0IHdoZW4gb25lIGFycml2ZXMgcmlnaHQgYXQgdGhlIGVuZC4NCllv
dSBtaWdodCB3YW50IHRvICd1bnNldCcgdGhlIHJlc2NoZWR1bGUgZmxhZyBiZWZvcmUgZWFjaCBj
aGVjayBvZiB0aGUNCnJlY2VpdmUgcmluZy4NCg0KSSBhbHNvIHdvbmRlciBhYm91dCB0aGUgY29z
dCBvZiBwcm9jZXNzaW5nIHRoZSBNU0ktWCAoSSBndWVzcykgaW50ZXJydXB0cw0KY29tcGFyZWQg
dG8gdGhlIGNvc3Qgb2YgcG9zdGVkIFBDSWUgd3JpdGVzIHRvIGRpc2FibGUgYW5kL29yIG1hc2sg
dGhlDQppbnRlcnJ1cHQgZ2VuZXJhdGlvbi4NCkNsZWFybHkgeW91IGRvbid0IHdhbnQgdG8gZG8g
UENJZSByZWFkcy4NCg0KCURhdmlkDQoNCg==
