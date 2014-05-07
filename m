From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Is 3.18 patch "The tcp: TSO packets automatic sizing" will
 cause to Troughput drop when enable NO_HZ_IDEL or HIGH_RES_TIMERS ?
Date: Wed, 7 May 2014 14:33:49 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F70EB65@AcuExch.aculab.com>
References: <CANHbGWs=oQBDVVZc8h5wX0WY+PRbQfCqiv5FrF1tH29QGiRndA@mail.gmail.com>
	<1399393821.15399.12.camel@edumazet-glaptop2.roam.corp.google.com>
	<1399394474.15399.22.camel@edumazet-glaptop2.roam.corp.google.com>
 <CANHbGWttbfApi_K3HHFAFSa1=76fDmx2PP5bon1gzB1wOZXtAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'V JobNickname' <workofv@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49640 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750859AbaEGOfL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2014 10:35:11 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 27061-04 for <netdev@vger.kernel.org>;
 Wed,  7 May 2014 15:35:03 +0100 (BST)
In-Reply-To: <CANHbGWttbfApi_K3HHFAFSa1=76fDmx2PP5bon1gzB1wOZXtAw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogViBKb2JOaWNrbmFtZQ0KPiAyMDE0LTA1LTA3IDA6NDEgR01UKzA4OjAwIEVyaWMgRHVt
YXpldCA8ZXJpYy5kdW1hemV0QGdtYWlsLmNvbT46DQo+ID4gT24gVHVlLCAyMDE0LTA1LTA2IGF0
IDA5OjMwIC0wNzAwLCBFcmljIER1bWF6ZXQgd3JvdGU6DQo+ID4NCj4gPj4gSSBjYW50IHNlZSBh
bnkgZWZmZWN0IGZvciB0aGlzIHBhdGNoIGV4cGxhaW5pbmcgYSA1MCUgcmVkdWN0aW9uIGluDQo+
ID4+IHNwZWVkLCB1bmxlc3MgYSBzcGVjaWFsIHFkaXNjIHNldHVwIG1heWJlLg0KPiA+DQo+ID4g
T2ggd2FpdCwgYSBidWdneSBkcml2ZXIgY291bGQgZXhwbGFpbiB0aGUgcHJvYmxlbS4NCj4gPg0K
PiA+IFNvbWUgZHJpdmVycyByZWFsbHkgZXhwZWN0ZWQgVFggY29tcGxldGlvbiB0byBoYXBwZW4g
YXMgYSBzaWRlIGVmZmVjdCBvZg0KPiA+IHN1YnNlcXVlbnQgdHJhbnNtaXRzLg0KPiA+DQo+ID4g
WW91J2xsIGhhdmUgdG8gZ2l2ZSBtb3JlIGRldGFpbHMgb24gdGhlIGNvbmZpZ3VyYXRpb24geW91
IGFyZSB1c2luZy4NCg0KPiBEb2VzIHRoZSAiYnVnZ3kgZHJpdmVyIiBoZXJlIG1lYW4gdGhlIE5J
QyBkcml2ZXIgb3Igc29tZSBoaWdoZXIgbGV2ZWwNCj4gbmV0d29yayBzdGFjayBkcml2ZXI/DQo+
IFRoZSB4bWl0IGZ1bmN0aW9uIG9mIHRoZSB1c2VkIE5JQyBkcml2ZXIgaXMgdG8gc3R1ZmYgRE1B
IGNoYW5uZWwsIGlzDQo+IHRoZXJlIGhhdmUgImV4cGVjdGVkIFR4IGNvbXBsZXRpb24iIGJlaGF2
aW9yIGluIHRoZSBkcml2ZXIncyBmbG93ID8NCg0KU29tZSBvZiB0aGUgVENQIHRyYW5zbWl0IGZs
b3cgY29udHJvbCByZXF1aXJlcyB0aGF0IHRoZSBOSUMgZHJpdmVyDQpmcmVlIHRoZSBza2IgYXMg
c29vbiBhcyBpdCBpcyB0cmFuc21pdHRlZCAoaWYgbm90IGJlZm9yZSkgYW5kIGFsc28NCnRvIGxp
bWl0IHRoZSBudW1iZXIgb2YgYnl0ZXMgb2YgZGF0YSBxdWV1ZWQgZm9yIHRyYW5zbWl0Lg0KDQpU
aGlzIGlzIGRvbmUgdG8gZ2l2ZSBmYWlyKGVyKSBhY2Nlc3MgdG8gdGhlIG5ldHdvcmsgd2hlbiB0
aGVyZSBhcmUNCnNvbWUgY29ubmVjdGlvbnMgZG9pbmcgZmlsZSB0cmFuc2ZlciB3aXRoIGxhcmdl
IHdpbmRvdyBhbmQgb3RoZXJzDQpkb2luZyBjb21tYW5kLXJlc3BvbnNlLg0KDQoJRGF2aWQNCg==
