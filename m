From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] net_sched: add 64bit rate estimators
Date: Thu, 6 Jun 2013 09:39:59 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7272@saturn3.aculab.com>
References: <1370408447.24311.241.camel@edumazet-glaptop> <1370458531.1918.3.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David Miller" <davem@davemloft.net>,
	"netdev" <netdev@vger.kernel.org>
To: "Ben Hutchings" <bhutchings@solarflare.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:46942 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754911Ab3FFIrw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jun 2013 04:47:52 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24827-06 for <netdev@vger.kernel.org>;
 Thu,  6 Jun 2013 09:47:50 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1370458531.1918.3.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IHN0cnVjdCBnbmV0X3N0YXRzX3JhdGVfZXN0IGNvbnRhaW5zIHUzMiBmaWVsZHMsIHNvIHRo
ZSBieXRlIHBlciBzZWNvbmQNCj4gPiBmaWVsZCBjYW4gd3JhcCBhdCAzNDM2ME1iaXQuDQo+ID4N
Cj4gPiBBZGQgYSBuZXcgZ25ldF9zdGF0c19yYXRlX2VzdDY0IHN0cnVjdHVyZSB0byBnZXQgNjRi
aXQgYnBzIGZpZWxkLCBhbmQNCj4gPiBzd2l0Y2ggdGhlIGtlcm5lbCB0byB1c2UgdGhpcyBzdHJ1
Y3R1cmUgbmF0aXZlbHkuDQo+IFsuLi5dDQo+ID4gIC8qKg0KPiA+ICsgKiBzdHJ1Y3QgZ25ldF9z
dGF0c19yYXRlX2VzdDY0IC0gcmF0ZSBlc3RpbWF0b3INCj4gPiArICogQGJwczogY3VycmVudCBi
eXRlIHJhdGUNCj4gPiArICogQHBwczogY3VycmVudCBwYWNrZXQgcmF0ZQ0KPiA+ICsgKi8NCj4g
PiArc3RydWN0IGduZXRfc3RhdHNfcmF0ZV9lc3Q2NCB7DQo+ID4gKwlfX3U2NAlicHM7DQo+ID4g
KwlfX3UzMglwcHM7DQo+ID4gK30gX19hdHRyaWJ1dGVfXyAoKHBhY2tlZCkpOw0KPiBbLi4uXQ0K
PiANCj4gVXNpbmcgYXR0cmlidXRlIHBhY2tlZCAod2hpY2ggc2hvdWxkIGJlIHdyaXR0ZW4gYXMg
X19wYWNrZWQpIGZvcmNlcyB0aGUNCj4gYWxpZ25tZW50IG9mIGVhY2ggbWVtYmVyIGFuZCB0aGUg
c3RydWN0dXJlIGFzIGEgd2hvbGUgdG8gYmUgMS4gIEZvciBhbg0KPiBhcmNoaXRlY3R1cmUgd2hl
cmUgdW5hbGlnbmVkIGFjY2VzcyBpcyBleHBlbnNpdmUsIGdjYyB3aWxsIG1ha2UgYWxsDQo+IHJl
YWRzIGFuZCB3cml0ZXMgdXNlIGJ5dGUgb3BlcmF0aW9ucy4NCj4gDQo+IEkgdGhpbmsgeW91IGhh
dmUgdG8gYWRkIGEgZHVtbXkgX191MzIgbWVtYmVyIGluc3RlYWQuDQoNCk9yIG1hcmsgdGhlIF9f
dTY0IHdpdGggKElJUkMpIF9fYXR0cmlidXRlX18oKGFsaWduZWQsNCkpDQpzbyB0aGF0IGdjYyB3
aWxsIGdlbmVyYXRlIHR3byAzMmJpdCBhY2Nlc3NlcyByYXRoZXIgdGhhbg0KdGhlIGVpZ2h0IGJ5
dGUgYWNjZXNzZXMgaXMgdGhlIHN0cnVjdHVyZSBpcyBwYWNrZWQuDQoNCglEYXZpZA0KDQo=
