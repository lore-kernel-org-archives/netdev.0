From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v6 net-next 1/2] net: add skb_mstamp infrastructure
Date: Tue, 25 Feb 2014 09:51:45 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6CA6D1@AcuExch.aculab.com>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg>
	 <1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393181458.2316.56.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393216927.2316.62.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393266251.2316.68.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1402242240290.1941@ja.home.ssi.bg>
	 <1393280025.2316.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1402250056250.1941@ja.home.ssi.bg>
	 <1393284682.2316.83.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140224155130.4c286cca@samsung-9>
	 <1393290667.2316.96.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393292339.2316.98.camel@edumazet-glaptop2.roam.corp.google.com>
 <1393309324.2316.119.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	"Yuchung Cheng" <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:47036 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752586AbaBYJwr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Feb 2014 04:52:47 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12101-06 for <netdev@vger.kernel.org>;
 Tue, 25 Feb 2014 09:52:42 +0000 (GMT)
In-Reply-To: <1393309324.2316.119.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IGt0aW1lX2dldCgpIGlzIHRvbyBleHBlbnNpdmUgb24gc29t
ZSBjYXNlcywgYW5kIHdlJ2QgbGlrZSB0byBnZXQNCj4gdXNlYyByZXNvbHV0aW9uIHRpbWVzdGFt
cHMgaW4gVENQIHN0YWNrLg0KPiANCj4gVGhpcyBwYXRjaCBhZGRzIGEgbGlnaHQgd2VpZ2h0IGZh
Y2lsaXR5IHVzaW5nIGEgY29tYmluYXRpb24gb2YNCj4gbG9jYWxfY2xvY2soKSBhbmQgamlmZmll
cyBzYW1wbGVzLg0KLi4uDQo+ICtzdHJ1Y3Qgc2tiX21zdGFtcCB7DQo+ICsJdW5pb24gew0KPiAr
CQl1NjQJCXY2NDsNCj4gKwkJc3RydWN0IHsNCj4gKwkJCXUzMglzdGFtcF91czsNCj4gKwkJCXUz
MglzdGFtcF9qaWZmaWVzOw0KPiArCQl9Ow0KPiArCX07DQo+ICt9Ow0KDQpEbyB5b3UgbmVlZCB0
aGUgdW5pb24gaGVyZT8NCklmIHlvdSBkb24ndCBhdHRlbXB0IHRvIGNvbnZlcnQgdGhlIHZhbHVl
IHRvIGEgdTY0IHRoZW4gY29kZQ0KaXMgbGVzcyBsaWtlbHkgdG8gcHJvY2VzcyBpdCBpbmNvcnJl
Y3RseS4NCg0KTW9zdCBtb2Rlcm4gQUJJIHBhc3MvcmV0dXJuIHNob3J0IHN0cnVjdHVyZXMgaW4g
cmVnaXN0ZXJzLA0Kc28gdGhlIGFjdHVhbCBjb2RlIHNob3VsZCBiZSBzaW1pbGFyIGlmIHlvdSBy
ZXR1cm4gdGhlIHN0cnVjdA0KYnkgdmFsdWUuDQoNCglEYXZpZA0KDQo=
