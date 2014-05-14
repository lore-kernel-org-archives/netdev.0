From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [PATCH net-next v2 1/8] tipc: decrease connection flow control
 window
Date: Wed, 14 May 2014 12:12:35 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D1C251322@eusaamb103.ericsson.se>
References: <1400060355-26308-1-git-send-email-jon.maloy@ericsson.com>
	 <1400060355-26308-2-git-send-email-jon.maloy@ericsson.com>
 <1400068233.7973.80.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"Erik Hugne" <erik.hugne@ericsson.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	"maloy@donjonn.com" <maloy@donjonn.com>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg21.ericsson.net ([198.24.6.65]:53145 "EHLO
	usevmg21.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755075AbaENMMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 08:12:37 -0400
In-Reply-To: <1400068233.7973.80.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogRXJpYyBEdW1hemV0IFtt
YWlsdG86ZXJpYy5kdW1hemV0QGdtYWlsLmNvbV0NCj4gU2VudDogTWF5LTE0LTE0IDc6NTEgQU0N
Cj4gVG86IEpvbiBNYWxveQ0KPiBDYzogZGF2ZW1AZGF2ZW1sb2Z0Lm5ldDsgbmV0ZGV2QHZnZXIu
a2VybmVsLm9yZzsgUGF1bCBHb3J0bWFrZXI7IEVyaWsNCj4gSHVnbmU7IHlpbmcueHVlQHdpbmRy
aXZlci5jb207IG1hbG95QGRvbmpvbm4uY29tOyB0aXBjLQ0KPiBkaXNjdXNzaW9uQGxpc3RzLnNv
dXJjZWZvcmdlLm5ldA0KPiBTdWJqZWN0OiBSZTogW1BBVENIIG5ldC1uZXh0IHYyIDEvOF0gdGlw
YzogZGVjcmVhc2UgY29ubmVjdGlvbiBmbG93IGNvbnRyb2wNCj4gd2luZG93DQo+IA0KPiBPbiBX
ZWQsIDIwMTQtMDUtMTQgYXQgMDU6MzkgLTA0MDAsIEpvbiBNYWxveSB3cm90ZToNCj4gPiBNZW1v
cnkgb3ZlcmhlYWQgd2hlbiBhbGxvY2F0aW5nIGJpZyBidWZmZXJzIGZvciBkYXRhIHRyYW5zZmVy
IG1heSBiZQ0KPiA+IHF1aXRlIHNpZ25pZmljYW50LiBFLmcuLCB0cnVlc2l6ZSBvZiBhIDY0IEtC
IGJ1ZmZlciB0dXJucyBvdXQgdG8gYmUNCj4gPiAxMzIgS0IsIDIgeCB0aGUgcmVxdWVzdGVkIHNp
emUuDQo+IA0KPiBJdCBtaWdodCBiZSB0aW1lIHRvIHVzZSBhIGRpZmZlcmVudCBzdHJhdGVneSBm
b3Igc2tiIGFsbG9jYXRpb25zIHRoZW4gPw0KDQpBYnNvbHV0ZWx5LiBUaGF0IGlzIGFscmVhZHkg
b25nb2luZy4gU2VlIG15IGFuc3dlciB0byBEYXZpZCBNIGFib3V0IHRoaXMuDQoNCi8vL2pvbg0K
DQo+IA0KPiBJcyB0aGlzIGJlY2F1c2UgVElQQyBkb2VzIG5vdCBzdXBwb3J0IFNHID8NCj4gDQoN
Cg==
