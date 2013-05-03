From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] af_unix: fix a fatal race with bit fields
Date: Fri, 3 May 2013 15:29:50 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7226@saturn3.aculab.com>
References: <1367370761.11020.22.camel@edumazet-glaptop> <1367372393.22115.6.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David Miller" <davem@davemloft.net>,
	"netdev" <netdev@vger.kernel.org>,
	"Paul Mackerras" <paulus@samba.org>,
	"Ambrose Feinstein" <ambrose@google.com>,
	<linuxppc-dev@lists.ozlabs.org>
To: "Benjamin Herrenschmidt" <benh@kernel.crashing.org>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:56903 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932505Ab3ECObi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 May 2013 10:31:38 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 10253-05 for <netdev@vger.kernel.org>;
 Fri,  3 May 2013 15:31:32 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1367372393.22115.6.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IENvdWxkIHBwYzY0IGV4cGVydHMgY29uZmlybSB1c2luZyBieXRlIGlzIHNhZmUsIG9yIHNo
b3VsZCB3ZSByZWFsbHkgYWRkDQo+ID4gYSAzMmJpdCBob2xlIGFmdGVyIHRoZSBzcGlubG9jayA/
IElmIHNvLCBJIHdvbmRlciBob3cgbWFueSBvdGhlciBwbGFjZXMNCj4gPiBuZWVkIGEgY2hhbmdl
Li4uDQouLi4NCj4gQWxzbyBJJ2QgYmUgc3VycHJpc2VkIGlmIHBwYzY0IGlzIHRoZSBvbmx5IG9u
ZSB3aXRoIHRoYXQgcHJvYmxlbS4uLiB3aGF0DQo+IGFib3V0IHNwYXJjNjQgYW5kIGFybTY0ID8N
Cg0KRXZlbiB4ODYgY291bGQgYmUgYWZmZWN0ZWQuDQpUaGUgd2lkdGggb2YgdGhlIG1lbW9yeSBj
eWNsZXMgdXNlZCBieSB0aGUgJ2JpdCBzZXQgYW5kIGJpdCBjbGVhcicNCmluc3RydWN0aW9ucyBp
c24ndCBkb2N1bWVudGVkLiBUaGV5IGFyZSBjZXJ0YWlubHkgYWxsb3dlZCB0byBkbw0KUk1XIG9u
IGFkamFjZW50IGJ5dGVzLg0KSSBkb24ndCByZW1lbWJlciB3aGV0aGVyIHRoZXkgYXJlIGNvbnN0
cmFpbmVkIHRvIG9ubHkgZG8NCjMyYml0IGFjY2Vzc2VzLCBidXQgbm90aGluZyB1c2VkIHRvIHNh
eSB0aGF0IHRoZXkgd291bGRuJ3QNCmRvIDMyYml0IG1pc2FsaWduZWQgb25lcyEgKGFsdGhvdWdo
IEkgc3VzcGVjdCB0aGV5IG5ldmVyIGhhdmUpLg0KDQoJRGF2aWQNCg0K
