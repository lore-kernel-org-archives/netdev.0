From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Wed, 25 Feb 2015 17:49:35 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAED645@AcuExch.aculab.com>
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
Received: from smtp-out4.electric.net ([192.162.216.181]:54545 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305AbbBYRuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 12:50:46 -0500
In-Reply-To: <1424886096.5565.104.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQouLi4NCj4gMSkgQXV0b21hdGljIHNocmlua2luZyBpcyBhIG5v
biBpc3N1ZS4gVGhpcyB3aWxsIGZyZWUgdmVyeSBsaXR0bGUNCj4gbWVtb3J5LCBjb21wYXJlZCB0
byBwcmV2aW91cyBwZWFrIHVzYWdlIChpbmNsdWRpbmcgb2JqZWN0cyBwdXQgaW4NCj4gcmhhc2h0
YWJsZSkuIElmIGhhc2ggZ3Jvd24gdG8gYSBjZXJ0YWluIHBvaW50LCBpdCdzIGxpa2VseSBpdCB3
aWxsIGdyb3cNCj4gYWdhaW4gbGF0ZXIuDQoNCkZXSVcgSSB0ZW5kIHRvIGFncmVlLg0KDQo+IDIp
IEdyb3dpbmcgY2FuIGJlIHRyaWdnZXJlZCB3aGVuIGFueSBidWNrZXQgaGFzIG1vcmUgdGhhbiBY
IGVsZW1zLCBhbmQNCj4gdGhhdCBpcyBnaXZlbiBmb3IgZnJlZSBhdCBpbnNlcnQgdGltZS4NCj4g
WCBjb3VsZCBiZSBsb2cyKGJ1Y2tldHMpLzIgSSBndWVzcy4gKGFrYSBzaGlmdC8yKQ0KDQpUaGF0
IHdvbid0IHdvcmsgaWYgc29tZW9uZSBpcyBtYW5hZ2luZyB0byBicmVhayB0aGUgaGFzaCBmdW5j
dGlvbi4NCllvdSBuZWVkIHNvbWUgYXBwcm94aW1hdGlvbiB0byB0aGUgdG90YWwgY291bnQgYXMg
d2VsbC4NCk9UT0ggdGhlcmUgaXMgbm8gcG9pbnQgZ3Jvd2luZyB0aGUgdGFibGUgaWYgdGhlIGN1
cnJlbnQgbGlzdCBpc24ndCAnZnVsbCcuDQoNCj4gQSBnbG9iYWwgbGltaXQgb24gbnVtYmVyIG9m
IGVsZW1lbnRzIHNob3VsZCBiZSBjb250cm9sbGVkIGJ5IHJoYXNodGFibGUNCj4gdXNlcnMgLSBp
ZiBuZWVkZWQgLSwgbm90IGluIHRoZSByaGFzaHRhYmxlIGl0c2VsZi4NCg0KUG9zc2libHkgeW91
IGNvdWxkIHJlcXVpcmUgdGhlIHVzZXIgdG8gZ2l2ZSBhbiBhcHByb3hpbWF0aW9uIG9mIHRoZQ0K
bnVtYmVyIG9mIGVsZW1lbnRzLg0KDQoJRGF2aWQNCg0K
