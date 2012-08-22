From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 16:27:56 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6FC1@saturn3.aculab.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>  <503437D4.8090706@zytor.com>  <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>  <20120821.193446.1534561579811962053.davem@davemloft.net>  <503450E2.2040504@zytor.com>  <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>  <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk>  <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com>  <1345645499.15245.8.camel@deadeye.wl.decadent.org.uk>  <20120822143054.GD9803@kvack.org> <1345647537.2709.0.camel@bwh-desktop.uk.solarflarecom.com> <5034F725.2090802@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Benjamin LaHaise" <bcrl@kvack.org>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"David Miller" <davem@davemloft.net>, <tglx@linutronix.de>,
	<mingo@redhat.com>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>, <x86@kernel.org>
To: "H. Peter Anvin" <hpa@zytor.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:47198 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932913Ab2HVPaO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2012 11:30:14 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 00955-04 for <netdev@vger.kernel.org>;
 Wed, 22 Aug 2012 16:30:12 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <5034F725.2090802@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBZb3VyIGFyY2hpdGVjdHVyZSBzb3VuZHMgc2ltaWxhciB0byBvbmUgSSBvbmNlIHdvcmtlZCBv
biAoT3Jpb24NCj4gTWljcm9zeXN0ZW1zIENOSUMvT1BBLTIpLiAgVGhhdCBhcmNoaXRlY3R1cmUg
aGFkIGEgZGVzY3JpcHRvciByaW5nIGluDQo+IGRldmljZSBtZW1vcnksIGFuZCBhIHNpbmdsZSB0
cmlnZ2VyIGJpdCB3b3VsZCBtb3ZlIHRoZSBoZWFkIHBvaW50ZXIuDQo+IA0KPiBXZSB1c2VkIHdy
aXRlIGNvbWJpbmluZyB0byB3cml0ZSBvdXQgYSBzZXQgb2YgZGVzY3JpcHRvcnMsIGFuZCB0aGVu
DQo+IHVzZWQNCj4gYSBub24td3JpdGUtY29tYmluaW5nIHdyaXRlIHRvIGRvIHRoZSBmaW5hbCB3
cml0ZSB3aGljaCBidW1wcyB0aGUgaGVhZA0KPiBwb2ludGVyLiAgVGhlIFVDIHdyaXRlIGZsdXNo
ZXMgdGhlIHdyaXRlIGNvbWJpbmVycyBhaGVhZCBvZiBpdCwgc28gaXQNCj4gZW5kcyB1cCB3aXRo
IHR3byB0cmFuc2FjdGlvbnMgKG9uZSBmb3IgdGhlIFdDIGRhdGEgYW5kIG9uZSBmb3IgdGhlIFVD
DQo+IHRyaWdnZXIpIGJ1dCBpdCBjb3VsZCBmcmVxdWVudGx5IHB1c2ggcXVpdGUgYSBmZXcgZGVz
Y3JpcHRvcnMgaW4gdGhhdA0KPiBvcGVyYXRpb24uDQoNClRoZSBjb2RlIGFjdHVhbGx5IGxvb2tz
IG1vcmUgbGlrZSBhIG5vcm1hbCBldGhlcm5ldCByaW5nIGludGVyZmFjZQ0Kd2l0aCBhbiAnb3du
ZXInIGJpdCBpbiBlYWNoIGVudHJ5Lg0KU28gaXQgaXMgaW1wb3J0YW50IHRvIHdyaXRlIHRoZSBv
d25lciBiaXQgbGFzdC4NCg0KSXQgbWlnaHQgYmUgcG9zc2libHkgdG8gc2V0IG11bHRpcGxlIHJp
bmcgZW50cmllcyBpbiB0d28gVExQcw0KYnkgZmlyc3Qgd3JpdGluZyBhbGwgb2YgdGhlbSAobWF5
YmUgd2l0aCB3cml0ZSBjb21iaW5pbmcpDQpidXQgd2l0aG91dCBjaGFuZ2luZyB0aGUgb3duZXJz
aGlwIG9mIHRoZSBmaXJzdCBlbnRyeS4NClRoZW4gZG9pbmcgYSBzZWNvbmQgdHJhbnNmZXIgdG8g
dXBkYXRlIHRoZSBvd25lciBiaXQgaXQNCnRoZSBmaXJzdCBlbnRyeS4NClRoZSBvcmRlciBvZiB0
aGUgd3JpdGVzIGluIHRoZSBmaXJzdCB0cmFuc2ZlciB3b3VsZCB0aGVuIG5vdA0KbWF0dGVyLg0K
DQpGV0lXIGNhbiB5b3UgZXZlbiBndWFyYW50ZWUgdG8gZG8gYW4gYXRvbWljIDY0Yml0IFBDSWUg
dHJhbnNmZXINCm9uIG1hbnkgc3lzdGVtcyAod2l0aG91dCByZXNvcnRpbmcgdG8gYSBkbWEgdW5p
dCkuDQoNCglEYXZpZA0KDQo=
