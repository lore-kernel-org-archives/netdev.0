From: "Berg, Johannes" <johannes.berg@intel.com>
Subject: RE: [PATCH net-next] iwlwifi: dont pull too much payload in skb head
Date: Tue, 29 May 2012 14:45:34 +0000
Message-ID: <1DC40B07CD6EC041A66726C271A73AE61955F646@IRSMSX102.ger.corp.intel.com>
References: <1337352513.7029.18.camel@edumazet-glaptop>
	 <1DC40B07CD6EC041A66726C271A73AE61955AE5D@IRSMSX102.ger.corp.intel.com>
 <1337354484.7029.42.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Guy, Wey-Yi W" <wey-yi.w.guy@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:36140 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753364Ab2E2Oq3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2012 10:46:29 -0400
In-Reply-To: <1337354484.7029.42.camel@edumazet-glaptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IFdlIG1heSB3YW50IHRvIG1vdmUgdGhpcyBjb2RlIGludG8gbWFjODAyMTEgbGF0ZXIgdGhv
dWdoIHNpbmNlIGl0IGFsc28NCj4gPiBoYXMgYW4gaWYgKHB1bGwgaW4gZXZlcnl0aGluZywgZXZl
biByZWFsbG9jYXRpbmcgaWYgbmVjZXNzYXJ5LCBpZiBpdCdzDQo+ID4gYSBtYW5hZ2VtZW50IGZy
YW1lKSwgYnV0IHRoYXQgY2FuIHdhaXQsIEkgdGhpbmsgd2UncmUgdGhlIG9ubHkgZHJpdmVyDQo+
ID4gdXNpbmcgcGFnZWQgUlguDQo+IA0KPiBUaGlzIGlzIE9LLCB0aGVzZSBmcmFtZXMgd29udCBi
ZSBpbmplY3RlZCBpbiBsaW51eCBJUC9UQ1Agc3RhY2suDQoNClJpZ2h0Lg0KDQo+IE9yIG1heWJl
IHlvdSB3b3VsZCBsaWtlIGFuIG9wdGltaXplZCB2ZXJzaW9uIG9mIHNrYl9oZWFkZXJfcG9pbnRl
cigpLA0KPiBhdm9pZGluZyB0aGUgY29weSBpZiB0aGUgd2hvbGUgYmxvYiBjYW4gYmUgcGFydCBv
ZiBfb25lXyBmcmFnbWVudCA/DQoNCkhtbS4gSSBndWVzcyB0aGF0IHdvdWxkIHdvcmssIGJ1dCBJ
J20gbm90IHN1cmUgaXQncyB3b3J0aCB0aGUgZWZmb3J0IHNpbmNlIHRoZXJlIHR5cGljYWxseSBh
cmVuJ3QgbWFueSBtYW5hZ2VtZW50IGZyYW1lcy4gV2UnZCBoYXZlIHRvIHJlcGxhY2UgYWxsIHNr
Yi0+ZGF0YSwgdGhlIGVudGlyZSBtYWM4MDIxMSBhc3N1bWVzIHRoYXQgbWFuYWdlbWVudCBmcmFt
ZXMgYXJlIGxpbmVhci4gDQoNCmpvaGFubmVzDQotLSANCg0KLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0KSW50ZWwgR21iSApEb3JuYWNoZXIgU3RyYXNzZSAxCjg1NjIyIEZlbGRraXJjaGVu
L011ZW5jaGVuLCBEZXV0c2NobGFuZCAKU2l0eiBkZXIgR2VzZWxsc2NoYWZ0OiBGZWxka2lyY2hl
biBiZWkgTXVlbmNoZW4KR2VzY2hhZWZ0c2Z1ZWhyZXI6IERvdWdsYXMgTHVzaywgUGV0ZXIgR2xl
aXNzbmVyLCBIYW5uZXMgU2Nod2FkZXJlcgpSZWdpc3RlcmdlcmljaHQ6IE11ZW5jaGVuIEhSQiA0
NzQ1NiAKVXN0Li1JZE5yLi9WQVQgUmVnaXN0cmF0aW9uIE5vLjogREUxMjkzODU4OTUKQ2l0aWJh
bmsgRnJhbmtmdXJ0IGEuTS4gKEJMWiA1MDIgMTA5IDAwKSA2MDAxMTkwNTIK
