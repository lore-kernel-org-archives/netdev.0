From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH FINAL] SCTP: fix race between sctp_bind_addr_free() and
 sctp_bind_addr_conflict()
Date: Sat, 21 May 2011 02:05:54 -0400 (EDT)
Message-ID: <20110521.020554.264807564381349277.davem@davemloft.net>
References: <4DD575A1.4080405@gmail.com>
	<20110520232717.GA5038@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: difrost.kernel@gmail.com, vladislav.yasevich@hp.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57919 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765Ab1EUGGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2011 02:06:05 -0400
In-Reply-To: <20110520232717.GA5038@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2ZSBKb25lcyA8ZGF2ZWpAcmVkaGF0LmNvbT4NCkRhdGU6IEZyaSwgMjAgTWF5IDIw
MTEgMTk6Mjc6MTcgLTA0MDANCg0KPiBKdXN0IHNhdyB0aGlzIGxhbmQgaW4gTGludXMgdHJlZSwg
YW5kIGl0IGJyb2tlIHRoZSBidWlsZCBmb3IgbWUuLg0KPiANCj4gbmV0L3NjdHAvYmluZF9hZGRy
LmM6IEluIGZ1bmN0aW9uIKFzY3RwX2JpbmRfYWRkcl9jbGVhbqI6DQo+IG5ldC9zY3RwL2JpbmRf
YWRkci5jOjE0ODoyNDogZXJyb3I6IKFzY3RwX2xvY2FsX2FkZHJfZnJlZaIgdW5kZWNsYXJlZCAo
Zmlyc3QgdXNlIGluIHRoaXMgZnVuY3Rpb24pDQo+IG5ldC9zY3RwL2JpbmRfYWRkci5jOjE0ODoy
NDogbm90ZTogZWFjaCB1bmRlY2xhcmVkIGlkZW50aWZpZXIgaXMgcmVwb3J0ZWQgb25seSBvbmNl
IGZvciBlYWNoIGZ1bmN0aW9uIGl0IGFwcGVhcnMgaW4NCj4gbWFrZVsyXTogKioqIFtuZXQvc2N0
cC9iaW5kX2FkZHIub10gRXJyb3IgMQ0KDQpZZXMgdGhpcyBpbnRlcmFjdGVkIGFuZCBtZXJnZWQg
YmFkbHkgd2l0aCB0aGUga2ZyZWVfcmN1KCkgY2hhbmdlcywNCkknbGwgZml4IHRoaXMgdXAsIHRo
YW5rcy4NCg==
