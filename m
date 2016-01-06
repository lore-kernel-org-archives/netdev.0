From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 net-next] net: Implement fast csum_partial for x86_64
Date: Wed, 6 Jan 2016 10:16:00 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCBE431@AcuExch.aculab.com>
References: <1452019261-449449-1-git-send-email-tom@herbertland.com>
 <1452032313.8255.135.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.184]:50082 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbcAFKSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 05:18:41 -0500
In-Reply-To: <1452032313.8255.135.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IFNlbnQ6IDA1IEphbnVhcnkgMjAxNiAyMjoxOQ0KPiBUbzog
VG9tIEhlcmJlcnQNCj4gWW91IG1pZ2h0IGFkZCBhIGNvbW1lbnQgdGVsbGluZyB0aGUgJzQnIGNv
bWVzIGZyb20gbGVuZ3RoIG9mICdhZGNxDQo+IDYqOCglcmRpKSwlcmF4JyBpbnN0cnVjdGlvbiwg
YW5kIHRoYXQgdGhlICdub3AnIGlzIHRvIGNvbXBlbnNhdGUgdGhhdA0KPiAnYWRjcSAgICAwKjgo
JXJkaSksJXJheCcgaXMgdXNpbmcgMyBieXRlcyBpbnN0ZWFkLg0KPiANCj4gV2UgYWxzbyBjb3Vs
ZCB1c2UgLmJ5dGUgMHg0OCwgMHgxMywgMHg0NywgMHgwMCB0byBmb3JjZSBhIDQgYnl0ZXMNCj4g
aW5zdHJ1Y3Rpb24gYW5kIHJlbW92ZSB0aGUgbm9wLg0KPiANCj4gDQo+ICsgICAgICAgbGVhICAg
ICAyMGYoLCAlcmN4LCA0KSwgJXIxMQ0KPiArICAgICAgIGNsYw0KPiArICAgICAgIGptcCAgICAg
KiVyMTENCj4gKw0KPiArLmFsaWduIDgNCj4gKyAgICAgICBhZGNxICAgIDYqOCglcmRpKSwlcmF4
DQo+ICsgICAgICAgYWRjcSAgICA1KjgoJXJkaSksJXJheA0KPiArICAgICAgIGFkY3EgICAgNCo4
KCVyZGkpLCVyYXgNCj4gKyAgICAgICBhZGNxICAgIDMqOCglcmRpKSwlcmF4DQo+ICsgICAgICAg
YWRjcSAgICAyKjgoJXJkaSksJXJheA0KPiArICAgICAgIGFkY3EgICAgMSo4KCVyZGkpLCVyYXgN
Cj4gKyAgICAgICBhZGNxICAgIDAqOCglcmRpKSwlcmF4IC8vIGNvdWxkIGZvcmNlIGEgNCBieXRl
IGluc3RydWN0aW9uICguYnl0ZSAweDQ4LCAweDEzLCAweDQ3LCAweDAwKQ0KPiArICAgICAgIG5v
cA0KPiArMjA6ICAgIC8qICNxdWFkcyAlIDgganVtcCB0YWJsZSBiYXNlICovDQoNCk9yIG1vdmUg
bGFiZWwgYXQgdGhlIHRvcCAoYWZ0ZXIgdGhlIC5hbGlnbikgYW5kIGFkanVzdCB0aGUgbWF0aHMu
DQpZb3UgY291bGQgYWRkIGEgc2Vjb25kIGxhYmVsIGFmdGVyIHRoZSBmaXJzdCBhZGNxIGFuZCB1
c2UgdGhlDQpkaWZmZXJlbmNlIGJldHdlZW4gdGhlbSBmb3IgdGhlICc0Jy4NCg0KCURhdmlkDQoN
Cg==
