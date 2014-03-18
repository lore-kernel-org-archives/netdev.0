From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 6/6] net: Free skbs from irqs when possible.
Date: Tue, 18 Mar 2014 15:52:37 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6E02DB@AcuExch.aculab.com>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
 <87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
 <20140317.154916.2276987764507311378.davem@davemloft.net>
 <87iorcgh5d.fsf_-_@xmission.com> <87fvmgf2c7.fsf_-_@xmission.com>
 <1395149407.22343.8.camel@deadeye.wl.decadent.org.uk>
 <87lhw7inzg.fsf@nemi.mork.no>
 <1395156229.9114.35.camel@edumazet-glaptop2.roam.corp.google.com>
 <2c96faab-4293-4e7f-b8e0-4997af745fbf@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Ben Hutchings <ben@decadent.org.uk>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
	"mpm@selenic.com" <mpm@selenic.com>,
	"satyam.sharma@gmail.com" <satyam.sharma@gmail.com>
To: =?utf-8?B?J0Jqw7hybiBNb3JrJw==?= <bjorn@mork.no>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:34608 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750836AbaCRPxz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 11:53:55 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24038-03 for <netdev@vger.kernel.org>;
 Tue, 18 Mar 2014 15:53:52 +0000 (GMT)
In-Reply-To: <2c96faab-4293-4e7f-b8e0-4997af745fbf@email.android.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQmrDuHJuIE1vcmsNCi4uLg0KPiA+VHJ5IGZvbGxvd2luZyBjb2RlLCBhbmQgeW91J2xs
IGdldCBhIGNvbXBpbGF0aW9uIGVycm9yLg0KPiA+DQo+ID51bnNpZ25lZCBpbnQgY2FuX3RoaXNf
Zmx5KHN0cnVjdCBza19idWZmICpza2IpDQo+ID57DQo+ID4JcmV0dXJuIElTX0VOQUJMRUQoQ09O
RklHX05PV0FZX1NJUikgPyBza2ItPnVua25vd25fZmllbGQgOiAwOw0KPiA+fQ0KPiANCj4gRG9o
LiBPZiBjb3Vyc2UuIFRoYW5rcyBmb3Igc3Bvb24gZmVlZGluZyBtZSB0aGF0Lg0KDQpPZiBjb3Vy
c2UsIGNvbmZpZ19lbmFibGVkKGZvbykgY291bGQgYmUgaW1wbGVtZW50ZWQgYXMNCmNvbmZpZ19l
bmFibGVkXyhmb28sIDEsIDApDQpBbGxvd2luZyB5b3UgdG8gZGVmaW5lIGFuZCB0ZXN0Og0KCUlT
X0VOQUJMRURfUShDT05GSUdfTk9XQVlfU0lSLCBza2ItPnVua25vd25fZmllbGQsIDApDQoNCkFs
dGhvdWdoIHlvdSdkIHByb2JhYmx5IG5lZWQgdG8gcGFzdGUgdGhlIGV4cGFuc2lvbnMgb2YgYm90
aCAnZm9vJw0KJ2Zvb19NT0RVTEUnIG9udG8gX19BUkdfUExBQ0VIT0xERVJfIHRvIGF2b2lkIHRo
ZSB8fC4NCg0KTW9yZSB1c2VmdWwgbWlnaHQgYmUgSUZfRU5BQkxFRChmb28sIHgpIHdoaWNoIGV4
cGFuZHMgdG8gZWl0aGVyDQp4IG9yIG5vdGhpbmcgYXQgYWxsLg0KVGhlIHlvdSBjb3VsZCBjb25k
aXRpb25hbGx5IGdlbmVyYXRlIHRoZSBjaHVua3Mgb2YgZm9ybWF0IHN0YXRlbWVudA0KYXMgd2Vs
bCBhcyB0aGUgcGFyYW1ldGVyIGxpc3QuDQoNCk9UT0ggeW91IG1pZ2h0IHdhbnQgcmVhZGFibGUg
Y29kZSENCg0KCURhdmlkDQoNCg==
