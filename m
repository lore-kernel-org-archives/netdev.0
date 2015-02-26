From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Thu, 26 Feb 2015 14:18:20 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAEEB34@AcuExch.aculab.com>
References: <cover.1424877322.git.daniel@iogearbox.net>
	 <cd3e70163920753c7f1a492e6df253cff9b1b080.1424877322.git.daniel@iogearbox.net>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAED36D@AcuExch.aculab.com>
	 <54EDEE55.8050605@iogearbox.net>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAED3A1@AcuExch.aculab.com>
	 <54EDF4DD.1060709@iogearbox.net>
 <1424886096.5565.104.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.183]:63148 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932150AbbBZOT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 09:19:29 -0500
In-Reply-To: <1424886096.5565.104.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAxKSBBdXRvbWF0aWMgc2hyaW5raW5nIGlzIGEgbm9uIGlzc3VlLiBUaGlzIHdpbGwgZnJlZSB2
ZXJ5IGxpdHRsZQ0KPiBtZW1vcnksIGNvbXBhcmVkIHRvIHByZXZpb3VzIHBlYWsgdXNhZ2UgKGlu
Y2x1ZGluZyBvYmplY3RzIHB1dCBpbg0KPiByaGFzaHRhYmxlKS4gSWYgaGFzaCBncm93biB0byBh
IGNlcnRhaW4gcG9pbnQsIGl0J3MgbGlrZWx5IGl0IHdpbGwgZ3Jvdw0KPiBhZ2FpbiBsYXRlci4N
Cg0KU2hyaW5rIGNvdWxkIGJlIGRvbmUgJ29uIGRlbWFuZCcgZnJvbSB0aGUgJ3VzZXInIHdoZW4g
dGhlIG51bWJlciBvZg0KZWxlbWVudHMgaXMga25vd24gdG8gaGF2ZSBzaWduaWZpY2FudGx5IHJl
ZHVjZWQuDQoNCj4gMikgR3Jvd2luZyBjYW4gYmUgdHJpZ2dlcmVkIHdoZW4gYW55IGJ1Y2tldCBo
YXMgbW9yZSB0aGFuIFggZWxlbXMsIGFuZA0KPiB0aGF0IGlzIGdpdmVuIGZvciBmcmVlIGF0IGlu
c2VydCB0aW1lLg0KPiBYIGNvdWxkIGJlIGxvZzIoYnVja2V0cykvMiBJIGd1ZXNzLiAoYWthIHNo
aWZ0LzIpDQoNCklmIGdyb3dpbmcgaXMgdHJpZ2dlcmVkIHdoZW4gYSBidWNrZXQgaGFzIG1vcmUg
dGhhbiBYIGVsZW1zLCB0aGVuIHNldHRpbmcNClggdmVyeSBoaWdoIHdpbGwgc3RvcCBhdXRvbWF0
aWMgZ3Jvd2luZy4NCkdyb3dpbmcgd291bGQgdGhlbiBvbmx5IGJlIGRvbmUgaW4gcmVzcG9uc2Ug
dG8gdXNlciByZXF1ZXN0cy4NCg0KV2hldGhlciBYIHNob3VsZCBiZSBjb25zdGFudCwgb3IgbG9n
MihidWNrZXRzKS9uIGlzIGFub3RoZXIgbWF0dGVyLg0KT3Igc29tZXRoaW5nIGxpa2UgTjEgKyAo
TjIgKiBsb2cyKGJ1Y2tldHMpKS82NCBpbiBhbnkgY2FzZSBpdA0Kb25seSBuZWVkcyByZWNhbGN1
bGF0aW5nIGFmdGVyIGFuIGF1dG8tZ3Jvdy4NCg0KCURhdmlkDQoNCg==
