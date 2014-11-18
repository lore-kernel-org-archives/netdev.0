From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 03/12] i40e: Handle a single mss packet with more
 than 8 frags
Date: Tue, 18 Nov 2014 09:46:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9F290B@AcuExch.aculab.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416031715-32498-4-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416075695.17262.86.camel@edumazet-glaptop2.roam.corp.google.com>
	 <FC41C24E35F18A40888AACA1A36F3E418AD8F543@fmsmsx115.amr.corp.intel.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1C9F1F9F@AcuExch.aculab.com>
 <1416243484.5102.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "'Nelson, Shannon'" <shannon.nelson@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kong, Serey" <serey.kong@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:44841 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752432AbaKRJrl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2014 04:47:41 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 01393-07 for <netdev@vger.kernel.org>;
 Tue, 18 Nov 2014 09:47:30 +0000 (GMT)
In-Reply-To: <1416243484.5102.21.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IE9uIE1vbiwgMjAxNC0xMS0xNyBhdCAxNjoxNiArMDAwMCwg
RGF2aWQgTGFpZ2h0IHdyb3RlOg0KPiANCj4gPiBFeGNlcHQgdGhhdCBhIFRTTyBwYWNrZXQgaXMg
bGlrZWx5IHRvIGJlIGp1c3QgdW5kZXIgNjRrIGFuZCBjb21wcmlzZSBvZg0KPiA+IGEgc21hbGwg
aGVhZGVyIGFuZCAxNiBvdGhlciBmcmFnbWVudHMgLSBtb3N0IG9mIHdoaWNoIHdpbGwgYmUgYSBj
b21wbGV0ZSA0ayBwYWdlLg0KPiA+DQo+IA0KPiBUaGlzIGlzIHRoZSBzZWN0aW9uIG9mIHRoZSBj
b2RlIHNlbmRpbmcgYSBfbm9uXyBUU08gcGFja2V0Lg0KDQpUaGF0IGlzbid0IGVudGlyZWx5IGNs
ZWFyIGZyb20gdGhlIHBhdGNoIGNvbnRleHQuDQoNCkZvciBhIG5vbi1UU08gcGFja2V0IHRoZSBz
a2Jfc2VyaWFsaXplKCkgaXMgbGVzcyBsaWtlbHkgdG8gZmFpbA0Kc2luY2UgaXQgZG9lc24ndCBu
ZWVkIGNvbnRpZ3VvdXMgcGFnZXMuDQooVW5sZXNzIHlvdSBhcmUgc2VuZGluZyA5ayBqdW1ibyBm
cmFtZXMpLg0KDQpBY3R1YWxseSBtYW55IG9mIHRoZSBvbGRlciBldGhlcm5ldCBkZXZpY2VzIHdp
bGwgc3VmZmVyIGJ1ZmZlciB1bmRlcnJ1bg0KaWYgZ2l2ZW4gdG9vIG1hbnkgc21hbGwgZnJhZ21l
bnRzIGR1ZSB0byBsYWNrIG9mIGJ1cyBiYW5kd2lkdGguDQpUaGUgaGlnaCBsYXRlbmNpZXMgb2Yg
UENJZSB3aWxsIG1ha2UgdGhhdCB3b3JzZSAtIGVzcGVjaWFsbHkgYXQgaGlnaCBzcGVlZHMuDQoN
ClByZXN1bWFibHkgdGhlc2UgZGV2aWNlcyB1c2UgJ3N0b3JlIGFuZCBmb3J3YXJkJyB3aGVuIGRv
aW5nIFRTTyAob3INCm1heWJlIGV2ZW4gd2hlbiBqdXN0IGFkZGluZyBhIGNoZWNrc3VtKSByZW1v
dmluZyBhbnkgcmVhbCBwcm9ibGVtcw0KY2F1c2VkIGJ5IFBDSWUgbGF0ZW5jeT8NCg0KCURhdmlk
DQoNCg==
