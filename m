From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] USB CDC NCM: Don't deref NULL in cdc_ncm_rx_fixup()
 and don't use uninitialized variable.
Date: Thu, 13 Jan 2011 21:50:28 -0800 (PST)
Message-ID: <20110113.215028.237355303.davem@davemloft.net>
References: <alpine.LNX.2.00.1101132229260.11347@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: linux-kernel@vger.kernel.org, oliver@neukum.name, gregkh@suse.de,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	alexey.orishko@stericsson.com, hans.petter.selasky@stericsson.com
To: jj@chaosbits.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49940
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752375Ab1ANFt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 00:49:56 -0500
In-Reply-To: <alpine.LNX.2.00.1101132229260.11347@swampdragon.chaosbits.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSmVzcGVyIEp1aGwgPGpqQGNoYW9zYml0cy5uZXQ+DQpEYXRlOiBUaHUsIDEzIEphbiAy
MDExIDIyOjQwOjExICswMTAwIChDRVQpDQoNCj4gc2tiX2Nsb25lKCkgZHluYW1pY2FsbHkgYWxs
b2NhdGVzIG1lbW9yeSBhbmQgbWF5IGZhaWwuIElmIGl0IGRvZXMgaXQgDQo+IHJldHVybnMgTlVM
TC4gVGhpcyBtZWFucyB3ZSdsbCBkZXJlZmVyZW5jZSBhIE5VTEwgcG9pbnRlciBpbiANCj4gZHJp
dmVycy9uZXQvdXNiL2NkY19uY20uYzo6Y2RjX25jbV9yeF9maXh1cCgpLg0KPiBBcyBmYXIgYXMg
SSBjYW4gdGVsbCwgdGhlIHByb3BlciB3YXkgdG8gZGVhbCB3aXRoIHRoaXMgaXMgc2ltcGx5IHRv
IGdvdG8gDQo+IHRoZSBlcnJvciBsYWJlbC4NCj4gDQo+IEZ1cnRoZXJtb3JlIGdjYyBjb21wbGFp
bnMgdGhhdCAnc2tiJyBtYXkgYmUgdXNlZCB1bmluaXRpYWxpemVkOg0KPiAgIGRyaXZlcnMvbmV0
L3VzYi9jZGNfbmNtLmM6IEluIGZ1bmN0aW9uIKFjZGNfbmNtX3J4X2ZpeHVwojoNCj4gICBkcml2
ZXJzL25ldC91c2IvY2RjX25jbS5jOjkyMjoxODogd2FybmluZzogoXNrYqIgbWF5IGJlIHVzZWQg
dW5pbml0aWFsaXplZCBpbiB0aGlzIGZ1bmN0aW9uDQo+IGFuZCBJIGJlbGlldmUgaXQgaXMgcmln
aHQuIE9uIHRoZSBsaW5lIHdoZXJlIHdlDQo+ICAgcHJfZGVidWcoImludmFsaWQgZnJhbWUgZGV0
ZWN0ZWQgKGlnbm9yZWQpIiAuLi4NCj4gd2UgYXJlIHVzaW5nIHRoZSBsb2NhbCB2YXJpYWJsZSAn
c2tiJyBidXQgbm90aGluZyBoYXMgZXZlciBiZWVuIGFzc2lnbmVkIA0KPiB0byB0aGF0IHZhcmlh
YmxlIHlldC4gSSBiZWxpZXZlIHRoZSBjb3JyZWN0IGZpeCBmb3IgdGhhdCBpcyB0byB1c2UgDQo+
ICdza2JfaW4nIGluc3RlYWQuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBKZXNwZXIgSnVobCA8ampA
Y2hhb3NiaXRzLm5ldD4NCg0KQXBwbGllZC4NCg==
