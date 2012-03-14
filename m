From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH] net/hyperv: fix erroneous NETDEV_TX_BUSY use
Date: Wed, 14 Mar 2012 20:29:13 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DCE70A5@TK5EX14MBXC223.redmond.corp.microsoft.com>
References: <1331751214.6022.47.camel@edumazet-glaptop>
	 <4F60E9F7.4000402@candelatech.com>
	 <1331752632.6022.49.camel@edumazet-glaptop>
	 <A1F3067C9B68744AA19F6802BAB8FFDC0DCE702F@TK5EX14MBXC223.redmond.corp.microsoft.com>
 <1331756072.6022.57.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe005.messaging.microsoft.com ([216.32.180.31]:54995
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753875Ab2CNU3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 16:29:31 -0400
In-Reply-To: <1331756072.6022.57.camel@edumazet-glaptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogRXJpYyBEdW1hemV0IFtt
YWlsdG86ZXJpYy5kdW1hemV0QGdtYWlsLmNvbV0NCj4gU2VudDogV2VkbmVzZGF5LCBNYXJjaCAx
NCwgMjAxMiA0OjE1IFBNDQo+IFRvOiBIYWl5YW5nIFpoYW5nDQo+IENjOiBCZW4gR3JlZWFyOyBE
YXZpZCBNaWxsZXI7IG5ldGRldjsgS1kgU3Jpbml2YXNhbjsgR3JlZyBLcm9haC1IYXJ0bWFuDQo+
IFN1YmplY3Q6IFJFOiBbUEFUQ0hdIG5ldC9oeXBlcnY6IGZpeCBlcnJvbmVvdXMgTkVUREVWX1RY
X0JVU1kgdXNlDQo+IA0KPiBPbiBXZWQsIDIwMTItMDMtMTQgYXQgMjA6MDAgKzAwMDAsIEhhaXlh
bmcgWmhhbmcgd3JvdGU6DQo+IA0KPiA+IEFjdHVhbGx5LCBJJ20gd29ya2luZyBvbiB0aGlzIGJ1
ZywgYW5kIGhhdmUgYSBwYXRjaCB1bmRlciBvdXIgaW50ZXJuYWwNCj4gPiByZXZpZXcgbm93LiBN
eSBmaXggaXMgYWN0dWFsbHkgbm90IGZyZWVpbmcgdGhlIFNLQiwgYW5kIHJldHVybg0KPiBORVRE
RVZfVFhfQlVTWS4NCj4gPg0KPiA+IEV2ZW4gaWYgdGhlIHZtYnVzIHJpbmcgYnVmZmVyIGlzIGJ1
c3kgY3VycmVudGx5LCBpdCBjYW4gYmUgYXZhaWxhYmxlDQo+IGR1cmluZw0KPiA+IHRoZSBuZXh0
IHJlLXRyeSwgYmVjYXVzZSB0aGUgaG9zdCBpcyB0YWtpbmcgYXdheSBkYXRhIGZyb20gcmluZyBi
dWZmZXIuDQo+IFRoZQ0KPiA+IHN0b3Avd2FrZSBxdWV1ZSBtZWNoYW5pc20gaXMgaW4gdGhlIG5l
dHZzYy5jIGZpbGUuDQo+ID4NCj4gPiBJbiB0aGUgb3V0LW9mLW1lbW9yeSBjYXNlLCBkcm9wcGlu
ZyBwYWNrZXQgYW5kIHJldHVybiBORVRERVZfVFhfT0sgc2VlbXMNCj4gZmluZS4NCj4gDQo+IFRo
YXQgd2lsbCBiZSBmaW5lIGZvciBuZXQtbmV4dC4NCj4gDQo+IEkgc2VudCBhIHBhdGNoIGZvciBj
dXJyZW50IGtlcm5lbHMsIHdoZXJlIG9idmlvdXMgYW5kIG1pbmltYWwgZml4ZXMNCj4gYXBwbHku
DQoNClNvdW5kcyBnb29kLiBUaGFua3MuDQoNClJldmlld2VkLWJ5OiBIYWl5YW5nIFpoYW5nIDxo
YWl5YW5nekBtaWNyb3NvZnQuY29tPg0KDQo=
