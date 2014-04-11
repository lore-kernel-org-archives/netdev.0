From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] ipv6: Limit mtu to 65572 bytes
Date: Fri, 11 Apr 2014 08:34:38 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6F5D88@AcuExch.aculab.com>
References: <5345A2B3.7040602@gmail.com>
 <1397079665.16584.17.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140409223546.GH27255@order.stressinduktion.org>
 <1397090170.16584.21.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140410235459.GK27255@order.stressinduktion.org>
 <1397176824.16584.52.camel@edumazet-glaptop2.roam.corp.google.com>
 <1397180530.16584.69.camel@edumazet-glaptop2.roam.corp.google.com>
 <534753D4.6070600@linux-ipv6.org>
 <20140411025707.GM27255@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Francois WELLENREITER <f.wellenreiter@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Hannes Frederic Sowa' <hannes@stressinduktion.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55374 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755753AbaDKIg1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2014 04:36:27 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 20076-04 for <netdev@vger.kernel.org>;
 Fri, 11 Apr 2014 09:36:17 +0100 (BST)
In-Reply-To: <20140411025707.GM27255@order.stressinduktion.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSGFubmVzIEZyZWRlcmljIFNvd2ENCj4gT24gRnJpLCBBcHIgMTEsIDIwMTQgYXQgMTE6
MzA6NDRBTSArMDkwMCwgWU9TSElGVUpJIEhpZGVha2kgd3JvdGU6DQo+ID4gRXJpYyBEdW1hemV0
IHdyb3RlOg0KPiA+DQo+ID4gPiBXZSBtdXN0IGxpbWl0IHRoZSBJUHY2IE1UVSB0byAoNjU1MzUg
KyA0MCkgYnl0ZXMgaW4gdGhlb3J5Lg0KPiA+ID4NCj4gPiA+IEluIHByYWN0aWNlLCBpdHMgYmV0
dGVyIHRvIGFsaWduIHRvIGEgbXVsdGlwbGUgb2YgNCBmb3Igb3B0aW1hbCBUQ1ANCj4gPiA+IHBl
cmZvcm1hbmNlLg0KPiA+DQo+ID4gSXQgaXMgYSBUQ1AgaXNzdWUuICBXZSBzaG91bGQgbm90IGxp
bWl0IHRoZSBtdHUgdG8gNjU1MzIrNDAuDQo+ID4gSSBhbSBmb3IgNjU1MzUrNDAuIE90aGVyd2lz
ZSwgb3RoZXIgcHJvdG9jb2wgc3VjaCBhcyBVRFAgY2Fubm90DQo+ID4gdXNlIGZ1bGwgbXR1IGFz
IGJlZm9yZS4NCj4gDQo+IEkgaGF2ZSBub3Qgc2VlbiBwcm9ibGVtcyB3aXRoIG1heCBpcHY2IG10
dSBsaW1pdCBvZiA2NTUzNSs0MCBhbmQgdGNwLg0KPiANCj4gSSBhZ3JlZSB0aGlzIHdvdWxkIGJl
IGEgYmV0dGVyIGFwcHJvYWNoLCBhbmQgbWF5YmUgJiB+MyB0aGUgbXR1L21zcw0KPiBpbiB0Y3Ag
Y29kZT8gSSBhc3N1bWUgcGVvcGxlIGV4cGVjdCBtYXhpbXVtIHVkcCBwYWNrZXQgc2l6ZXMgd29y
a2luZw0KPiBvdmVyIGxvb3BiYWNrPw0KDQpUaGUgJ3RyaWNrJyB3b3VsZCBiZSB0byBnZW5lcmF0
ZSBzbGlnaHRseSBzaG9ydCBtZXNzYWdlcyBpbiB0aGUgdGNwDQp0cmFuc21pdCBjb2RlIHdoZW4g
ZG9pbmcgc28gd291bGRuJ3QgZ2VuZXJhdGUgYW4gZXh0cmEgcGFja2V0Lg0KU28gKHVzaW5nIHZl
cnkgc21hbGwgbnVtYmVycykgaWYgdGhlIG1heCB1c2VyZGF0YSB3YXMgNjMgYnl0ZXMgYSAxMjAN
CmJ5dGUgdHJhbnNtaXQgd291bGQgZ2VuZXJhdGUgdHdvIDYwIGJ5dGUgcGFja2V0cywgYnV0IDEy
MSB0byAxMjYgYnl0ZQ0KdHJhbnNtaXRzIHdvdWxkIHN0aWxsIGdlbmVyYXRlIHR3byBwYWNrZXRz
Lg0KDQoJRGF2aWQNCg0K
