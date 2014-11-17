From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 03/12] i40e: Handle a single mss packet with more
 than 8 frags
Date: Mon, 17 Nov 2014 14:15:40 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9F1E54@AcuExch.aculab.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416031715-32498-4-git-send-email-jeffrey.t.kirsher@intel.com>
 <1416075695.17262.86.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Serey Kong <serey.kong@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	"Shannon Nelson" <shannon.nelson@intel.com>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49772 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751886AbaKQOQU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2014 09:16:20 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 03761-01 for <netdev@vger.kernel.org>;
 Mon, 17 Nov 2014 14:16:06 +0000 (GMT)
In-Reply-To: <1416075695.17262.86.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+ID4gVGhpcyBoYW5kbGVzIHRoZSBjYXNlIHdoZXJlIGEgc2lu
Z2xlIHBhY2tldCB3aXRoIG1vcmUgdGhhbiA4IGRhdGENCj4gPiBkZXNjcmlwdG9ycyB0cmlnZ2Vy
cyBhIE1hbGljaW91cyBEcml2ZXIgRGV0ZWN0IGV2ZW50IGluIHRoZSBkZXZpY2UuDQoNCldob3Nl
IGJyaWdodCBpZGVhIHdhcyB0aGF0Pw0KDQo+ID4gQEAgLTIxMjksMTAgKzIxMjksMTYgQEAgc3Rh
dGljIHZvaWQgaTQwZV90eF9tYXAoc3RydWN0IGk0MGVfcmluZyAqdHhfcmluZywgc3RydWN0IHNr
X2J1ZmYgKnNrYiwNCj4gPiAgCQkJIEk0MEVfVFhfRkxBR1NfVkxBTl9TSElGVDsNCj4gPiAgCX0N
Cj4gPg0KPiA+IC0JaWYgKHR4X2ZsYWdzICYgKEk0MEVfVFhfRkxBR1NfVFNPIHwgSTQwRV9UWF9G
TEFHU19GU08pKQ0KPiA+ICsJaWYgKHR4X2ZsYWdzICYgKEk0MEVfVFhfRkxBR1NfVFNPIHwgSTQw
RV9UWF9GTEFHU19GU08pKSB7DQo+ID4gIAkJZ3NvX3NlZ3MgPSBza2Jfc2hpbmZvKHNrYiktPmdz
b19zZWdzOw0KPiA+IC0JZWxzZQ0KPiA+ICsJfSBlbHNlIHsNCj4gPiAgCQlnc29fc2VncyA9IDE7
DQo+ID4gKwkJaWYgKHNrYl9zaGluZm8oc2tiKS0+bnJfZnJhZ3MgPj0gSTQwRV9NQVhfQlVGRkVS
X1RYRCkNCj4gPiArCQkJc2tiX2xpbmVhcml6ZShza2IpOw0KPiANCj4gV2hhdCBleGFjdGx5IGhh
cHBlbnMgaWYgc2tiX2xpbmVhcml6ZSgpIGZhaWxzID8NCg0KRGlkbid0IHNvbWVvbmUgd3JpdGUg
YSBmdW5jdGlvbiB0aGF0IHNpZ25pZmljYW50bHkgcmVkdWNlcyB0aGUNCm51bWJlciBvZiBmcmFn
bWVudHMgd2l0aG91dCBhY3R1YWxseSByZXF1aXJpbmcgYSBzaW5nbGUgbGluZWFyIGJsb2NrPw0K
DQoJRGF2aWQNCg0K
