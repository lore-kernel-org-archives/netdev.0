From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Can I limit the number of active tx per TCP socket?
Date: Fri, 7 Mar 2014 12:29:00 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6D755C@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6D3B91@AcuExch.aculab.com>
	<5318ADB1.5050107@hp.com>
 <CADVnQyn1+WRqS9HQmMn9JgpBz0Wajg=40yVhdyqv_AAo4tpWUA@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6D727E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	'Neal Cardwell' <ncardwell@google.com>,
	Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57619 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751082AbaCGM3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2014 07:29:38 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 25366-10 for <netdev@vger.kernel.org>;
 Fri,  7 Mar 2014 12:29:35 +0000 (GMT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6D727E@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTGFpZ2h0DQo+IEZyb206IE5lYWwgQ2FyZHdlbGwNCj4gPiBFcmljJ3MgcmVj
ZW50ICJhdXRvIGNvcmtpbmciIGZlYXR1cmUgbWF5IGJlIGhlbHBmdWwgaW4gdGhpcyBjb250ZXh0
Og0KPiA+DQo+ID4gICBodHRwOi8vbHduLm5ldC9BcnRpY2xlcy81NzYyNjMvDQo+IA0KPiBZZXMs
IEkgd2FzIHJ1bm5pbmcgc29tZSB0ZXN0cyB0byBtYWtlIHN1cmUgdGhpcyBkaWRuJ3QgY2F1c2Ug
dXMNCj4gYW55IGdyaWVmLg0KPiANCj4gSW4gZmFjdCB2ZXJ5IGFnZ3Jlc3NpdmUgImF1dG8gY29y
a2luZyIgd291bGQgaGVscCBteSB0cmFmZmljIGZsb3cuDQo+IEkgaGF2ZW4ndCB5ZXQgdHJpZWQg
bG9jYWxseSByZXZlcnRpbmcgdGhlIHBhdGNoIHRoYXQgc3RvcHBlZA0KPiBhdXRvIGNvcmtpbmcg
YmVpbmcgcXVpdGUgYXMgZWZmZWN0aXZlLg0KPiAoSSBtaWdodCBldmVuIHRyeSBzZXR0aW5nIHRo
ZSBsaW1pdCBsb3dlciB0aGFuIDIqc2tiX3RydWVfc2l6ZS4pDQoNCkFncmVzc2l2ZSBhdXRvIGNv
cmtpbmcgaGVscHMgKHJlZHVjZXMgdGhlIGNwdSBsb2FkIG9mIHRoZSBwcGMgZnJvbQ0KNjAlIHRv
IDMwJSBmb3IgdGhlIHNhbWUgdHJhZmZpYyBmbG93KSAtIGJ1dCBvbmx5IGlmIEkgcmVkdWNlIHRo
ZQ0KZXRoZXJuZXQgc3BlZWQgdG8gMTBNLg0KKEFjdHVhbGx5IEkgb25seSBoYXZlIHRoZSBwcm9j
ZXNzIGNwdSBsb2FkIGZvciB0aGUgcHBjLCBpdCBwcm9iYWJseQ0KZXhjbHVkZXMgYSBsb3Qgb2Yg
dGhlIHRjcCByeCBjb2RlLikNCg0KSSBndWVzcyB0aGF0IHRoZSB0cmFuc21pdCBpcyBjb21wbGV0
aW5nIGJlZm9yZSB0aGUgb3RoZXIgYWN0aXZlDQpwcm9jZXNzZXMva2VybmVsIHRocmVhZHMgbWFu
YWdlIHRvIHJlcXVlc3QgdGhlIG5leHQgdHJhbnNtaXQuDQpUaGlzIHdvbid0IGJlIGhlbHBlZCBi
eSB0aGUgZmlyc3QgcGFja2V0IGJlaW5nIHNob3J0Lg0KDQpTcGlubmluZyBhbGwgYnV0IG9uZSBv
ZiB0aGUgY3B1cyB3aXRoICd3aGlsZSA6OyBkbyA6OyBkb25lJw0KaGFzIGFuIGludGVyZXN0aW5n
IGVmZmVjdCBvbiB0aGUgd29ya2xvYWQvdGhyb3VnaHB1dC4NClRoZSBhZ2dyZWdhdGUgbWVzc2Fn
ZSByYXRlIGdvZXMgZnJvbSA1MjAwL3NlYyB0byA5MDAwL3NlYyAobm93DQpsaW1pdGVkIGJ5IHRo
ZSA2NGsgbGlua3MpLg0KSSB0aGluayB0aGlzIGhhcHBlbnMgYmVjYXVzZSB0aGUgc2NoZWR1bGVy
ICdyZXNpc3RzJyBwcmUtZW1wdGluZw0KcnVubmluZyBwcm9jZXNzZXMgLSBzbyB0aGUgVENQIHNl
bmQgcHJvY2Vzc2luZyBoYXBwZW5zIGluIGJ1cnN0cy4NClRoZSBwcGMgcHJvY2VzcyBpcyB0aGVu
IHVzaW5nIGFib3V0IDg1JSAoZnJvbSB0b3ApLg0KDQpJJ2xsIHByb2JhYmx5IGxvb2sgYXQgZGVs
YXlpbmcgdGhlIHNlbmRzIHdpdGhpbiBvdXIgb3duIGNvZGUuDQoNCglEYXZpZA0KDQoNCg==
