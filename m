From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [net-next PATCH V2 9/9] net: increase frag queue hash size andcache-line
Date: Thu, 29 Nov 2012 16:39:30 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70D1@saturn3.aculab.com>
References: <20121129161019.17754.29670.stgit@dragon> <20121129161552.17754.86087.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>,
	"Pablo Neira Ayuso" <pablo@netfilter.org>,
	"Thomas Graf" <tgraf@suug.ch>, "Cong Wang" <amwang@redhat.com>,
	"Patrick McHardy" <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"Herbert Xu" <herbert@gondor.hengli.com.au>
To: "Jesper Dangaard Brouer" <brouer@redhat.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Florian Westphal" <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45768 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751191Ab2K2Qku (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 11:40:50 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11105-10 for <netdev@vger.kernel.org>;
 Thu, 29 Nov 2012 16:40:40 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20121129161552.17754.86087.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBJbmNyZWFzZSBmcmFnIHF1ZXVlIGhhc2ggc2l6ZSBhbmQgYXNzdXJlIGNhY2hlLWxpbmUgYWxp
Z25tZW50IHRvDQo+IGF2b2lkIGZhbHNlIHNoYXJpbmcuICBIYXNoIHNpemUgaXMgc2V0IHRvIDI1
NiwgYmVjYXVzZSBJIGhhdmUNCj4gb2JzZXJ2ZWQgMjA2IGZyYWcgcXVldWVzIGluIHVzZSBhdCA0
eDEwRyB3aXRoIHBhY2tldCBzaXplIDQ0MTYgYnl0ZXMNCj4gKHRocmVlIGZyYWdtZW50cykuDQoN
ClNpbmNlIGl0IGlzIGEgaGFzaCBsaXN0LCB3b24ndCB0aGVyZSBhbHdheXMgYmUgd29ya2xvYWRz
IHdoZXJlDQp0aGVyZSBhcmUgaGFzaCBjb2xsaXNpb25zPw0KSSdtIG5vdCBzdXJlIEknbSBpbiBm
YXZvdXIgb2YgbWFzc2l2ZWx5IHBhZGRpbmcgb3V0IHN0cnVjdHVyZQ0KdG8gdGhlIHNpemUgb2Yg
Y2FjaGUgbGluZXMuDQoNCkJvdGggdGhlc2UgY2hhbmdlcyBhZGQgYSBtb2RlcmF0ZSBhbW91bnQg
dG8gdGhlIGtlcm5lbCBkYXRhIHNpemUNCih0aG9zZSBwZW9wbGUgd2hvIGFyZSB3b3JyaWVkIGFi
b3V0IG5vdCBiZWluZyBhYmxlIHRvIGRpc2NhcmQNCmNvZGUgYmVjYXVzZSBob3RfcGx1ZyBpcyBh
bHdheXMgY29uZmlndXJlZCByZWFsbHkgb3VnaHQgdG8NCmJlIHdvcnJpZWQgYWJvdXQgdGhlIGZv
b3RwcmludCBvZiBzb21lIG9mIHRoZXNlIGhhc2ggdGFibGVzKS4NCg0KV2UgcnVuIExpbnV4IG9u
IGVtYmVkZGVkIChzbWFsbCkgcHBjIHdoZXJlIHRoZXJlIG1pZ2h0IG9ubHkNCmJlIGEgaGFuZGZ1
bCBvZiBUQ1AgY29ubmVjdGlvbnMsIHRoZXNlIHNvcnQgb2YgdGFibGVzIHVzZSB1cA0KcHJlY2lv
dXMgbWVtb3J5Lg0KDQpXaGlsZSBwYWRkaW5nIHRvIGNhY2hlIGxpbmUgbWlnaHQgcmVkdWNlIHRo
ZSBudW1iZXIgb2YgY2FjaGUNCnNub29wcyB3aGVuIGF0dGFja2luZyB0aGUgY29kZSwgaW4gYSBy
ZWFsIGxpZmUgc2l0dWF0aW9uIEkNCnN1c3BlY3QgdGhlIGVmZmVjdCBvZiBtYWtpbmcgYW5vdGhl
ciBjYWNoZSBsaW5lIGJ1c3kgaXMgYXMNCmxpa2VseSB0byBmbHVzaCBvdXQgc29tZSBvdGhlciBp
bXBvcnRhbnQgZGF0YS4NClRoaXMgaXMgc2ltaWxhciB0byB0aGUgcmVhc29ucyB0aGF0IGV4Y2Vz
c2l2ZSBmdW5jdGlvbiBpbmxpbmluZw0KYW5kIGxvb3AgdW5yb2xsaW5nIHdpbGwgc3BlZWQgdXAg
YmVuY2htYXJrcyBidXQgc2xvdyBkb3duIHJlYWwNCmNvZGUuDQoNCglEYXZpZA0KDQo=
