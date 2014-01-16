From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/2] random32: add prandom_u32_lt_N and convert
 "misuses" of reciprocal_divide
Date: Thu, 16 Jan 2014 09:28:33 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D45D899@AcuExch.aculab.com>
References: <1389828228-30312-1-git-send-email-dborkman@redhat.com>
	 <1389828228-30312-2-git-send-email-dborkman@redhat.com>
 <1389842050.31367.396.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:48263 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752243AbaAPJap (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 04:30:45 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 27006-02 for <netdev@vger.kernel.org>;
 Thu, 16 Jan 2014 09:30:41 +0000 (GMT)
In-Reply-To: <1389842050.31367.396.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IE9uIFRodSwgMjAxNC0wMS0xNiBhdCAwMDoyMyArMDEwMCwg
RGFuaWVsIEJvcmttYW5uIHdyb3RlOg0KPiANCj4gPiBAQCAtMTIyMCw3ICsxMjE5LDcgQEAgc3Rh
dGljIHVuc2lnbmVkIGludCBmYW5vdXRfZGVtdXhfaGFzaChzdHJ1Y3QgcGFja2V0X2Zhbm91dCAq
ZiwNCj4gPiAgCQkJCSAgICAgIHN0cnVjdCBza19idWZmICpza2IsDQo+ID4gIAkJCQkgICAgICB1
bnNpZ25lZCBpbnQgbnVtKQ0KPiA+ICB7DQo+ID4gLQlyZXR1cm4gcmVjaXByb2NhbF9kaXZpZGUo
c2tiLT5yeGhhc2gsIG51bSk7DQo+ID4gKwlyZXR1cm4gKHUzMikoKCh1NjQpIHNrYi0+cnhoYXNo
ICogbnVtKSA+PiAzMik7DQo+ID4gIH0NCj4gPg0KPiANCj4gVGhpcyBpcyB1bmZvcnR1bmF0ZS4N
Cj4gDQo+IChUaGlzIHJldmVydHMgb25lIG9mIHlvdXIgcGF0Y2ggOiBmNTVkMTEyZTUyOTM4NiAp
DQo+IA0KPiBQbGVhc2UgYWRkIGEgaGVscGVyIHRvIGV4cGxhaW4gd2hhdCdzIGdvaW5nIG9uIGhl
cmUsIGFuZCBvbiBtYW55IG90aGVyDQo+IHNwb3RzIHdlIGRvIHRoaXMgY29tcHV0YXRpb24gKGFz
IGluIGdldF9ycHNfY3B1KCkpLg0KPiBGZXcgcGVvcGxlIHJlYWxseSB1bmRlcnN0YW5kIHRoaXMu
DQo+IA0KPiBPciBrZWVwIHJlY2lwcm9jYWxfZGl2aWRlKCkgYXMgaXMsIGFuZCBpbnRyb2R1Y2Ug
YSBuZXcgc2V0IG9mIGZ1bmN0aW9ucw0KPiBmb3IgcGVvcGxlIHJlYWxseSB3YW50aW5nIHRoZSBw
cmVjaXNlIGRpdmlkZXMuDQoNCk1heWJlIHJlbmFtZSB0aGUgY3VycmVudCByZWNpcHJvY2FsX2Rp
dmlkZSgpIGFzIHdlbGw/DQoNCkluIHRoZSBhYm92ZSBjb2RlIGl0IGlzbid0IGltbWVkaWF0ZWx5
IG9idmlvdXMgdGhhdCB0aGUgcmVzdWx0IG9mDQphIGRpdmlzaW9uIGlzIGFzIHVzZWZ1bCBhcyB0
aGF0IG9mIGEgbW9kdWx1cyENCk9UT0ggdGhlIGhpZ2ggMzIgYml0cyBvZiBhIDMyeDMyIG11bHRp
cGx5IGFyZSAoc2xpZ2h0bHkpIG1vcmUgb2J2aW91c2x5DQppbiB0aGUgcmVxdWlyZWQgcmFuZ2Uu
DQoNCglEYXZpZA0KDQo=
