From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] usbnet: Fix dma setup for fragmented packets that need
 a pad byte appended.
Date: Tue, 14 Jan 2014 17:28:27 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D45B744@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D45B28F@AcuExch.aculab.com>
	<1389710518.31367.259.camel@edumazet-glaptop2.roam.corp.google.com>
	<063D6719AE5E284EB5DD2968C1650D6D45B492@AcuExch.aculab.com>
 <87vbxm7eey.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: =?utf-8?B?J0Jqw7hybiBNb3JrJw==?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:48170 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751329AbaANRag (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 12:30:36 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22649-01 for <netdev@vger.kernel.org>;
 Tue, 14 Jan 2014 17:30:32 +0000 (GMT)
In-Reply-To: <87vbxm7eey.fsf@nemi.mork.no>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQmrDuHJuIE1vcmsgW21haWx0bzpiam9ybkBtb3JrLm5vXQ0KPiBEYXZpZCBMYWlnaHQg
PERhdmlkLkxhaWdodEBBQ1VMQUIuQ09NPiB3cml0ZXM6DQo+IA0KPiA+IEkgY291bGRuJ3QgZmlu
ZCB0aGUgb3JpZ2luYWwgcGF0Y2ggYW55d2hlcmUhDQo+ID4gSSBkaWQgZG8gcXVpdGUgYSBsb3Qg
b2YgbG9va2luZyBhcyB3ZWxsIC0gaWYgSSdkIGZvdW5kIGl0IEkndmUNCj4gPiBoYXZlIGRvbmUg
c29tZXRoaW5nIGVsc2UuDQo+IA0KPiBZb3Ugb2J2aW91c2x5IGhhdmVuJ3QgbG9va2VkIHRoZSBv
bmUgcGxhY2UgeW91IGFyZSBzdXBwb3NlZCB0byBhbHdheXMNCj4gbG9vayBiZWZvcmUgc3VibWl0
dGluZyAqYW55dGhpbmcqOg0KPiBodHRwczovL2dpdC5rZXJuZWwub3JnL2NnaXQvbGludXgva2Vy
bmVsL2dpdC9kYXZlbS9uZXQuZ2l0L2NvbW1pdC8/aWQ9ZmRjMzQ1MmNkMmM3YjJiZmUwZjM3OGY5
MjEyM2Y0ZjkNCj4gYTk4ZmEyYmQNCj4gDQo+IEkgYW0gbm90IGltcHJlc3NlZC4uLg0KDQpXaXRo
b3V0IHRoZSBjb21taXQgaWQgdGhhdCBpcyByYXRoZXIgaGFyZC4NCkRvZXMgYW55dGhpbmcgZXZl
biBnZXQgdGhlcmUgd2l0aG91dCBtYW51YWwgYWN0aW9ucy4NCnVzYiBwYXRjaGVzIHNpdCBpbiBh
IGhpZGRlbiBsaW1ibyBmb3IgYWdlcy4NCg0KSSBsb29rZWQgdGhyb3VnaCBteSBtYWlsYm94ZXMg
YW5kIHNlYXJjaGVkIGZvciB0aGUgdGhyZWFkIC0gYnV0IG9ubHkNCmZvdW5kIHRoZSBtZXNzYWdl
cyB0aGF0IGluY2x1ZGVkIHRoZSBvbmUgdGhhdCBzYWlkIHlvdSdkIHNlbmQgYSBwYXRjaA0Kc29v
bi4NCg0KV2hhdCBJIHN0aWxsIGRvbid0IHVuZGVyc3RhbmQgaXMgaG93IEkgZm91bmQgdGhlIHBh
dGNoIGJlZm9yZSENCg0KVGhlIGZhY3QgdGhhdCB3b3JrIG1ha2UgbWUgdXNlIG91dGx1Y2sgbWFr
ZXMgc2VhcmNoaW5nIG1haWwgbG9jYWxseQ0KYWxtb3N0IGltcG9zc2libGUuDQpJIG1pZ2h0IGhh
dmUgdG8gc3Vic2NyaWJlIGF0IGhvbWUgYXMgd2VsbC4NCg0KCURhdmlkDQoNCg==
