From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/6] net: Add a struct net parameter to sock_create_kern
Date: Tue, 12 May 2015 11:48:54 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB33707@AcuExch.aculab.com>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
 <87wq0kcqlm.fsf@x220.int.ebiederm.org>
 <20150508140733.GA13325@gondor.apana.org.au>
 <87sib76kef.fsf@x220.int.ebiederm.org>
 <20150509011339.GA19116@gondor.apana.org.au>
 <87383633pu.fsf_-_@x220.int.ebiederm.org>
 <87oalu1p16.fsf_-_@x220.int.ebiederm.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CB33641@AcuExch.aculab.com>
 <110296A8-1CC9-456C-B126-50C90D4E3E17@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Ying Xue <ying.xue@windriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"cwang@twopensource.com" <cwang@twopensource.com>,
	"xemul@openvz.org" <xemul@openvz.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"maxk@qti.qualcomm.com" <maxk@qti.qualcomm.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"nicolas.dichtel@6wind.com" <nicolas.dichtel@6wind.com>,
	"tom@herbertland.com" <tom@herbertland.com>,
	"jchapman@katalix.com" <jchapman@katalix.com>,
	"erik.hugne@ericsson.com" <erik.hugne@ericsson.com>,
	"jon.maloy@ericsson.com" <jon.maloy@ericsson.com>,
	"horms@verge.net.au" <horms@verge.net.au>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "'Eric W. Biederman'" <ebiederm@xmission.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.191]:52449 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932665AbbELLug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 07:50:36 -0400
In-Reply-To: <110296A8-1CC9-456C-B126-50C90D4E3E17@xmission.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBXLiBCaWVkZXJtYW4NCj4gU2VudDogMTIgTWF5IDIwMTUgMDk6NTUNCj4gDQo+
IE9uIE1heSAxMiwgMjAxNSAzOjI0OjExIEFNIENEVCwgRGF2aWQgTGFpZ2h0IDxEYXZpZC5MYWln
aHRAQUNVTEFCLkNPTT4gd3JvdGU6DQouLi4NCj4gPldvdWxkbid0IGl0IGludm9sdmUgZmFyIGxl
c3MgY2h1cm4gdG8gYWRkIGEgbmV3IGZ1bmN0aW9uIHRoYXQgdXNlcyBhDQo+ID5ub24tZGVmYXVs
dCBuYW1lc3BhY2U/DQo+IA0KPiBUaGUgZ29hbCBpcyBjb21wcmVoZW5zaWJsZSBhbmQgbWFpbnRh
aW5hYmxlIGtlcm5lbCBjb2RlLg0KPiANCj4gV2hpY2ggbmV0d29yayBuYW1lc3BhY2UgeW91ciBz
b2NrZXQgaXMgaW4sIGlzIGFuIGltcG9ydGFudCBwcm9wZXJ0eSBhbmQgc29tZXRoaW5nIHlvdSBw
cm9iYWJseSBjYXJlDQo+IGFib3V0IGlmIHlvdSBhcmUgY3JlYXRpbmcga2VybmVsIHNvY2tldHMu
DQoNClRoYXQgcmF0aGVyIGRlcGVuZHMgb24gd2hldGhlciB5b3UndmUgYW55d2hlcmUgdG8gZ2V0
IGEgbmFtZXNwYWNlIGZyb20uDQplZyBzb21ldGhpbmcgbGlrZSBjZXBoL21lc3Nlbmdlci5jDQoN
Cj4gSGF2aW5nIGEgc2Vjb25kIGZ1bmN0aW9uIGlzIG1vcmUgbWFpbnRlbmFuY2UgYW5kIHJlc3Vs
dHMgaW4gaGFyZGVyIHRvIHVuZGVyc3RhbmQgY29kZS4gIEEgbWFqb3INCj4gZnJhY3Rpb24gb2Yg
dGhlIGNhbGxlcnMgZXZlbiBiZWZvcmUgdGhpcyBjaGFuZ2Ugd2FudGVkIHRvIGJlIG91dHNpZGUg
dGhlIGluaXRpYWwgbmV0d29yayBuYW1lc3BhY2UuDQoNCkEgc3RhdGljIGlubGluZSBpbiB0aGUg
aGVhZGVyIGZpbGUgd291bGRuJ3QgY2F1c2UgYW55IG1haW50ZW5hbmNlIGlzc3Vlcy4NCg0KCURh
dmlkDQoNCg==
