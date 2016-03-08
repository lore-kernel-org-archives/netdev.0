From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v5 net-next] net: Implement fast csum_partial for x86_64
Date: Tue, 8 Mar 2016 11:03:11 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D4111ACE2@AcuExch.aculab.com>
References: <1456957112-2702469-1-git-send-email-tom@herbertland.com>
	<063D6719AE5E284EB5DD2968C1650D6D41113AD4@AcuExch.aculab.com>
	<CA+55aFzz7xt+RwruV3GvWJzQ67925gkDYeOYqgbjMEAHxxztnQ@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D41114809@AcuExch.aculab.com>
	<CAKgT0UcQEkhbpBvT69tBKvmY1EVm91vMwVUHOdkE4RJ3hH+Q9g@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D41116831@AcuExch.aculab.com>
	<CALx6S35h+oSCKsaEotah30tspZPdp3GZThrN8=cLbE2O7nhU2g@mail.gmail.com>
 <CAKgT0UfKA=ugpxuUYmv_DaEErRvEDFbGkhHDaFCxDM9C5YzeCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>
To: 'Alexander Duyck' <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.182]:53665 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932920AbcCHLGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 06:06:42 -0500
In-Reply-To: <CAKgT0UfKA=ugpxuUYmv_DaEErRvEDFbGkhHDaFCxDM9C5YzeCQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQWxleGFuZGVyIER1eWNrIA0KLi4uDQo+IE9uZSB0aG91Z2h0IEkgaGFkIGlzIHRoYXQg
d2UgbWF5IHdhbnQgdG8gbG9vayBpbnRvIG1ha2luZyBhbiBpbmxpbmUNCj4gZnVuY3Rpb24gdGhh
dCB3ZSBjYW4gY2FsbCBmb3IgY29tcGlsZS10aW1lIGRlZmluZWQgbGVuZ3RocyBsZXNzIHRoYW4N
Cj4gNjQuICBNYXliZSBjYWxsIGl0IHNvbWV0aGluZyBsaWtlIF9fY3N1bV9wYXJ0aWFsIGFuZCB3
ZSBjb3VsZCB0aGVuIHVzZQ0KPiB0aGF0IGluIHBsYWNlIG9mIGNzdW1fcGFydGlhbCBmb3IgYWxs
IHRob3NlIGhlYWRlcnMgdGhhdCBhcmUgYSBmaXhlZA0KPiBsZW5ndGggdGhhdCB3ZSBwdWxsIHN1
Y2ggYXMgVURQLCBWWExBTiwgRXRoZXJuZXQsIGFuZCB0aGUgcmVzdC4gIFRoZW4NCj4gd2UgbWln
aHQgYmUgYWJsZSB0byBsb29rIGF0IHRha2luZyBjYXJlIG9mIGFsaWdubWVudCBmb3IgY3N1bV9w
YXJ0aWFsDQo+IHdoaWNoIHdpbGwgaW1wcm92ZSB0aGUgc2tiX2NoZWNrc3VtKCkgY2FzZSB3aXRo
b3V0IGltcGFjdGluZyB0aGUNCj4gaGVhZGVyIHB1bGxpbmcgY2FzZXMgYXMgbXVjaCBzaW5jZSB0
aGF0IGNvZGUgd291bGQgYmUgaW5saW5lZA0KPiBlbHNld2hlcmUuDQoNCkkgdGhpbmsgdGhlcmUg
YXJlIHNvbWUgcGF0Y2hlcyBnb2luZyB0aHJvdWdoIHRoZSBwcGMgdHJlZSB0byBkbw0KZXhhY3Rs
eSB0aGF0Lg0KDQoJRGF2aWQNCg0K
