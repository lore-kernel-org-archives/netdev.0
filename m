From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [net-next rfc 1/3] net: avoid high order memory allocation for queues by using flex array
Date: Wed, 19 Jun 2013 17:06:21 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B729A@saturn3.aculab.com>
References: <1371620452-49349-1-git-send-email-jasowang@redhat.com> <1371620452-49349-2-git-send-email-jasowang@redhat.com> <1371623518.3252.267.camel@edumazet-glaptop> <20130619091132.GA2816@redhat.com> <1371635763.3252.289.camel@edumazet-glaptop> <20130619154059.GA13735@redhat.com> <1371657511.3252.324.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Jason Wang" <jasowang@redhat.com>, <davem@davemloft.net>,
	<edumazet@google.com>, <hkchu@google.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1371657511.3252.324.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiArc3RhdGljIHZvaWQgbmV0aWZfZnJlZV90eF9xdWV1ZXMoc3RydWN0IG5ldF9kZXZpY2UgKmRl
dikNCj4gK3sNCj4gKwlpZiAoaXNfdm1hbGxvY19hZGRyKGRldi0+X3R4KSkNCj4gKwkJdmZyZWUo
ZGV2LT5fdHgpOw0KPiArCWVsc2UNCj4gKwkJa2ZyZWUoZGV2LT5fdHgpOw0KPiArfQ0KPiArDQo+
ICBzdGF0aWMgaW50IG5ldGlmX2FsbG9jX25ldGRldl9xdWV1ZXMoc3RydWN0IG5ldF9kZXZpY2Ug
KmRldikNCj4gIHsNCj4gIAl1bnNpZ25lZCBpbnQgY291bnQgPSBkZXYtPm51bV90eF9xdWV1ZXM7
DQo+IEBAIC01MjYxLDkgKzUyNzAsMTEgQEAgc3RhdGljIGludCBuZXRpZl9hbGxvY19uZXRkZXZf
cXVldWVzKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYpDQo+ICAJQlVHX09OKGNvdW50IDwgMSk7DQo+
IA0KPiAgCXR4ID0ga2NhbGxvYyhjb3VudCwgc2l6ZW9mKHN0cnVjdCBuZXRkZXZfcXVldWUpLCBH
RlBfS0VSTkVMKTsNCj4gLQlpZiAoIXR4KQ0KPiAtCQlyZXR1cm4gLUVOT01FTTsNCj4gLQ0KPiAr
CWlmICghdHgpIHsNCj4gKwkJdHggPSB2emFsbG9jKGNvdW50ICogc2l6ZW9mKHN0cnVjdCBuZXRk
ZXZfcXVldWUpKTsNCj4gKwkJaWYgKCF0eCkNCj4gKwkJCXJldHVybiAtRU5PTUVNOw0KPiArCX0N
Cj4gIAlkZXYtPl90eCA9IHR4Ow0KDQpHaXZlbiB0aGUgbnVtYmVyIG9mIHBsYWNlcyBJJ3ZlIHNl
ZW4gdGhpcyBjb2RlIGFkZGVkLCB3aHkNCm5vdCBwdXQgaXQgaW4gYSBnZW5lcmFsIGhlbHBlcj8N
Cg0KSSBhbHNvIHRob3VnaHQgdGhhdCBtYWxsb2MoKSB3aXRoIEdGUF9LRVJORUwgd291bGQgc2xl
ZXAuDQpVbmRlciB3aGF0IGNvbmRpdGlvbnMgZG9lcyBpdCBmYWlsIGluc3RlYWQ/DQoNCglEYXZp
ZA0KDQo=
