From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v1 3/3] usb: gadget: NCM: Stop RX TCP Bursts getting
 dropped.
Date: Thu, 12 Jun 2014 09:42:54 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725B9CA@AcuExch.aculab.com>
References: <Jim Baxter <jim_baxter@mentor.com>
	 <1401383543-10181-1-git-send-email-jim_baxter@mentor.com>
	 <1401383543-10181-4-git-send-email-jim_baxter@mentor.com>
 <1401390263.3645.51.camel@edumazet-glaptop2.roam.corp.google.com>
 <53886ABC.8030303@mentor.com> <53997503.7040109@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Felipe Balbi <balbi@ti.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	=?utf-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Jim Baxter' <jim_baxter@mentor.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:48624 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932784AbaFLJns (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jun 2014 05:43:48 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 31206-07 for <netdev@vger.kernel.org>;
 Thu, 12 Jun 2014 10:43:47 +0100 (BST)
In-Reply-To: <53997503.7040109@mentor.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSmltIEJheHRlcg0KPiBPbiAzMC8wNS8xNCAxMjoyNSwgSmltIEJheHRlciB3cm90ZToN
Cj4gPiBPbiAyOS8wNS8xNCAyMDowNCwgRXJpYyBEdW1hemV0IHdyb3RlOg0KPiA+PiBPbiBUaHUs
IDIwMTQtMDUtMjkgYXQgMTg6MTIgKzAxMDAsIEppbSBCYXh0ZXIgd3JvdGU6DQo+ID4+DQo+ID4+
IE5vdGUgdGhlIHBhdGNoIGlzIE9LLCBidXQgY2hhbmdlbG9nIGEgYml0IG1pc2xlYWRpbmcgOykN
Cj4gPj4NCj4gPj4gS2VybmVsIHdhcyBub3QgcnVubmluZyBvdXQgb2YgbWVtb3J5LCBiZWNhdXNl
IHRydWVzaXplIHdhcyBjb3JyZWN0Lg0KPiA+Pg0KPiA+PiBUaGUgcHJvYmxlbSBoZXJlIGlzIHRo
YXQgYSBmcmFtZSB3YXMgY29uc3VtaW5nIG1vcmUga2VybmVsIG1lbW9yeSB0aGFuDQo+ID4+IHJl
YWxseSBuZWVkZWQsIHNvIGNoYW5jZXMgb2YgaGl0dGluZyBzb2NrZXQgc2tfcmN2YnVmIGxpbWl0
IHdhcyBoaWdoLg0KPiA+Pg0KPiA+PiBCVFcgOg0KPiA+PiAjZGVmaW5lIE5UQl9PVVRfU0laRSAg
ICAgICAgICAgICAgMTYzODQNCj4gPj4NCj4gPj4gYWxsb2Nfc2tiKHNpemUpIC0+DQo+ID4+IAlr
bWFsbG9jKDE2Mzg0ICsgc2l6ZW9mKHN0cnVjdCBza2Jfc2hhcmVkX2luZm8pKSAtPg0KPiA+PiAJ
CXJvdW5kdXAoKSA9PiAzMjc2OA0KPiA+Pg0KPiA+PiBTbyB0cnVlc2l6ZSBvZiB0aGUgc2tiIHdh
cyBpbmZhY3QgfjMyS0IsIHdoaWNoIGlzIHJlYWxseSBpbnNhbmUgaW5kZWVkLg0KPiA+PiBBZnRl
ciB5b3VyIHBhdGNoLCBpdHMgYmFjayB0byB+MktCDQo+ID4+DQo+ID4+IEFja2VkLWJ5OiBFcmlj
IER1bWF6ZXQgPGVkdW1hemV0QGdvb2dsZS5jb20+DQo+ID4+DQo+ID4+DQo+ID4+DQo+ID4NCj4g
PiBUaGFuayB5b3UsIEkgd2lsbCBjbGFyaWZ5IHRoZSBkZXNjcmlwdGlvbi4NCj4gPg0KPiA+IEpp
bQ0KPiA+DQo+IA0KPiBIaSBFcmljLA0KPiANCj4gSXMgdGhpcyBjb21taXQgbG9nIG1vcmUgY29y
cmVjdD8NCj4gDQo+IA0KPiBUaGlzIGZpeGVzIGEgcHJvYmxlbSB3aXRoIGRyb3BwZWQgcGFja2V0
cyBvdmVyIDE2ayBDREMtTkNNDQo+IHdoZW4gdGhlIGNvbm5lY3Rpb24gaXMgYmVpbmcgaGVhdmls
eSB1c2VkLg0KPiANCj4gVGhlIGlzc3VlIHdhcyB0aGF0IHRoZSBleHRyYWN0ZWQgZnJhbWVzIGNs
b25lZCBmcm9tIHRoZQ0KPiByZWNlaXZlZCBmcmFtZSB3ZXJlIGNvbnN1bWluZyBtb3JlIG1lbW9y
eSB0aGFuIG5lY2Vzc2FyeQ0KPiBkdWUgdG8gdGhlIHRydWVzaXplIGJlaW5nIH4zMktCIGluc3Rl
YWQgb2YgfjJLQiwgdGhpcw0KPiBtZWFudCB0aGVyZSB3YXMgYSBoaWdoIGNoYW5jZSBvZiByZWFj
aGluZyB0aGUgc2tfcmN2YnVmDQo+IGxpbWl0Lg0KDQpzL2R1ZSB0by9yZXN1bHRpbmcgaW4vDQoN
CglEYXZpZA0KDQo+IA0KPiBBY2tlZC1ieTogRXJpYyBEdW1hemV0IDxlZHVtYXpldEBnb29nbGUu
Y29tPg0KPiBTaWduZWQtb2ZmLWJ5OiBKaW0gQmF4dGVyIDxqaW1fYmF4dGVyQG1lbnRvci5jb20+
DQo+IA0KPiBUaGFuayB5b3UsDQo+IEppbQ0KDQo=
