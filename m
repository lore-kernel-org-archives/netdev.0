From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH] net: ethtool support to configure number of channels
Date: Fri, 1 Apr 2011 22:13:39 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80FD10E8D95@MNEXMB2.qlogic.org>
References: <1301652075-382-1-git-send-email-amit.salecha@qlogic.com>
	 <1301677824.4679.10.camel@bwh-desktop>
	 <99737F4847ED0A48AECC9F4A1974A4B80FD10E8D93@MNEXMB2.qlogic.org>
 <1301712946.10056.179.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:10106 "EHLO
	TX2EHSOBE007.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287Ab1DBDNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 23:13:48 -0400
In-Reply-To: <1301712946.10056.179.camel@localhost>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+DQo+ID4gPiBUaGlzIGFsc28gb21pdHMgdGhlICdjb21iaW5lZCcgYW5kICdvdGhlcicgdHlw
ZXMuICBNb3N0IG11bHRpcXVldWUNCj4gPiA+IGRyaXZlcnMgcGFpciB1cCBSWCBhbmQgVFggcXVl
dWVzIHNvIHRoYXQgbW9zdCBjaGFubmVscyBjb21iaW5lIFJYDQo+IGFuZA0KPiA+ID4gVFgNCj4g
PiA+IHdvcmsuDQo+ID4NCj4gPiAnY29tYmluZWQnIGlzIG9rLCB3aGF0IGlzIHVzZSBvZiAnb3Ro
ZXInID8NCj4NCj4gQ291bGQgYmUgbGluayBpbnRlcnJ1cHRzLCBTUi1JT1YgY29vcmRpbmF0aW9u
LCBvciBzb21ldGhpbmcgZWxzZS4gIE5vdA0KPiBzb21ldGhpbmcgeW91J2QgbGlrZWx5IGJlIGFi
bGUgdG8gY2hhbmdlLCBidXQgaXQgY291bGQgYmUgdXNlZnVsIHRvDQo+IGtub3cNCj4gdGhhdCBz
b21lIGludGVycnVwdHMgYXJlIGFsbG9jYXRlZCB0byB0aGVtLiAgQWN0dWFsbHksIHRoYXQgZG9l
cyBtZWFuDQo+IGl0DQo+IG1pZ2h0IGJlIGhlbHBmdWwgZm9yIHRoZSAnZ2V0JyBvcGVyYXRpb24g
dG8gcmV0dXJuIGEgbWluaW11bSB2YWx1ZQ0KPiBhbG9uZw0KPiB3aXRoIHRoZSBtYXhpbXVtIHZh
bHVlLg0KPg0KSW5zdGVhZCBvZiBuYW1pbmcgYXMgJ290aGVyJywgY29ycmVzcG9uZGluZyBjaGFu
bmVsIHR5cGUgc2hvdWxkIGJlIGRlY2xhcmVkLg0KQWRhcHRlciBtYXkgaGF2ZSBtdWx0aXBsZSAn
b3RoZXInIGNoYW5uZWwuIEl0J3MgYmV0dGVyIHRvIG5hbWUgdGhlbS4NCk5hbWluZyB0aGVtIHdp
bGwgYmUgdXNlZnVsLCBpZiBvbmUgd2FudCB0byBjb25maWd1cmUgdGhlbS4NClNvIEkgd2lsbCBy
YXRoZXIgbGVhdmUgdGhpcyBvcGVuIGFuZCBsZXQgcGVvcGxlIHRvIGRlY2xhcmVkIGNoYW5uZWwg
dHlwZSBhcyB0aGV5IHJlcXVpcmVkLg0KDQoNClRoaXMgbWVzc2FnZSBhbmQgYW55IGF0dGFjaGVk
IGRvY3VtZW50cyBjb250YWluIGluZm9ybWF0aW9uIGZyb20gUUxvZ2ljIENvcnBvcmF0aW9uIG9y
IGl0cyB3aG9sbHktb3duZWQgc3Vic2lkaWFyaWVzIHRoYXQgbWF5IGJlIGNvbmZpZGVudGlhbC4g
SWYgeW91IGFyZSBub3QgdGhlIGludGVuZGVkIHJlY2lwaWVudCwgeW91IG1heSBub3QgcmVhZCwg
Y29weSwgZGlzdHJpYnV0ZSwgb3IgdXNlIHRoaXMgaW5mb3JtYXRpb24uIElmIHlvdSBoYXZlIHJl
Y2VpdmVkIHRoaXMgdHJhbnNtaXNzaW9uIGluIGVycm9yLCBwbGVhc2Ugbm90aWZ5IHRoZSBzZW5k
ZXIgaW1tZWRpYXRlbHkgYnkgcmVwbHkgZS1tYWlsIGFuZCB0aGVuIGRlbGV0ZSB0aGlzIG1lc3Nh
Z2UuDQo=

