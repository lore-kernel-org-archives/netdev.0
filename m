From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH v2 net] bnx2x: Fix busy_poll vs netpoll
Date: Wed, 15 Apr 2015 14:03:09 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63CF66F2@AVMB1.qlogic.org>
References: <1429018513-9553-1-git-send-email-Yuval.Mintz@qlogic.com>
	 ,<1429023140.7346.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <B5657A6538887040AD3A81F1008BEC63CF5830@AVMB1.qlogic.org>
	 ,<1429033912.7346.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <B5657A6538887040AD3A81F1008BEC63CF58CE@AVMB1.qlogic.org>
	 <1429035897.7346.49.camel@edumazet-glaptop2.roam.corp.google.com>
	 ,<1429062300.7346.64.camel@edumazet-glaptop2.roam.corp.google.com>
	 <B5657A6538887040AD3A81F1008BEC63CF5B1E@AVMB1.qlogic.org>
 <1429092351.7346.71.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, "bind@enas.net" <bind@enas.net>,
	"peter@hurleysoftware.com" <peter@hurleysoftware.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	"Willem de Bruijn" <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:51018 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752593AbbDOODX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 10:03:23 -0400
In-Reply-To: <1429092351.7346.71.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+DQo+ID4gQlRXLCB0aGlzIGxvb2tzIHF1aXRlIGdlbmVyaWMgLSBpc24ndCBpdCBwb3NzaWJs
ZSB0byB0YWtlIGl0IG91dCBvZg0KPiA+IHRoZSBkcml2ZXIgYW5kIHB1c2ggaXQgaW50byB0aGUg
bmV0d29ya2luZyBjb3JlLCB1bmlmb3JtaW5nIGl0IGluIHRoZSBwcm9jZXNzPw0KPiANCj4gWWVz
LCB0aGlzIGlzIHRoZSBwbGFuIEkgaGF2ZSBpbiBtaW5kLCBvbmNlIG5ldC1uZXh0IGlzIG9wZW5l
ZCBhZ2FpbiA7KQ0KPiANCj4gVGhhbmtzICENCj4gDQoNCkknbSBub3QgZmFtaWxpYXIgd2l0aCBh
bnkgcmVhbCBzdHJvbmcgdGVzdC1zdWl0ZSBmb3IgdGhlIGJ1c3kgcG9sbCwgYnV0IEkgZGlkIHRy
eQ0KcnVubmluZyBhbGwga2luZHMgb2YgbmV0cGVyZiBjb25uZWN0aW9ucyB3aXRoIHZhcmlvdXMg
YnVzeV97cG9sbCxyZWFkfSB2YWx1ZXMNCmFuZCBwZXJmb3JtYW5jZSBzZWVtZWQgcmVhc29uYWJs
ZSwgYW5kIHZlcmlmaWVkIHRoYXQgbmV0Y29uc29sZSBtYW5hZ2VzDQp0byB3b3JrLg0KDQpTbyBm
b3IgYWxsIGl0J3Mgd29ydGgsDQpUZXN0ZWQtYnk6IFl1dmFsIE1pbnR6IDxZdXZhbC5NaW50ekBx
bG9naWMuY29tPg0K
