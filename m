From: David Miller <davem@davemloft.net>
Subject: [PATCH] bna: Fix warning false positive.
Date: Thu, 27 Sep 2012 18:32:25 -0400 (EDT)
Message-ID: <20120927.183225.276722553558516471.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59030 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753287Ab2I0Wc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 18:32:27 -0400
Received: from localhost (cpe-66-108-116-58.nyc.res.rr.com [66.108.116.58])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 3EE3B5864E4
	for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 15:32:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQpHQ0MgY2FuJ3Qgc2VlIHRoYXQgaW4gYWxsIG5vbi1lcnJvci1yZXR1cm4gcGF0aHMgd2UgZG8g
aW4gZmFjdA0Kc2V0ICp1c2luZ19kYWMgdG8gc29tZXRoaW5nLg0KDQpBZGQgYW4gZXhwbGljaXQg
aW5pdGlhbGl6YXRpb24gdG8gcmVtb3ZlIHRoaXMgd2FybmluZzoNCg0KZHJpdmVycy9uZXQvZXRo
ZXJuZXQvYnJvY2FkZS9ibmEvYm5hZC5jOiBJbiBmdW5jdGlvbiChYm5hZF9wY2lfcHJvYmWiOg0K
ZHJpdmVycy9uZXQvZXRoZXJuZXQvYnJvY2FkZS9ibmEvYm5hZC5jOjMwNzk6NTogd2FybmluZzog
oXVzaW5nX2RhY6IgbWF5IGJlIHVzZWQgdW5pbml0aWFsaXplZCBpbiB0aGlzIGZ1bmN0aW9uIFst
V21heWJlLXVuaW5pdGlhbGl6ZWRdDQpkcml2ZXJzL25ldC9ldGhlcm5ldC9icm9jYWRlL2JuYS9i
bmFkLmM6MzIzMzo3OiBub3RlOiChdXNpbmdfZGFjoiB3YXMgZGVjbGFyZWQgaGVyZQ0KDQpTaWdu
ZWQtb2ZmLWJ5OiBEYXZpZCBTLiBNaWxsZXIgPGRhdmVtQGRhdmVtbG9mdC5uZXQ+DQotLS0NCiBk
cml2ZXJzL25ldC9ldGhlcm5ldC9icm9jYWRlL2JuYS9ibmFkLmMgfCAxICsNCiAxIGZpbGUgY2hh
bmdlZCwgMSBpbnNlcnRpb24oKykNCg0KZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2V0aGVybmV0
L2Jyb2NhZGUvYm5hL2JuYWQuYyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2Jyb2NhZGUvYm5hL2Ju
YWQuYw0KaW5kZXggYjQ0MWYzMy4uY2UxZWFjNSAxMDA2NDQNCi0tLSBhL2RyaXZlcnMvbmV0L2V0
aGVybmV0L2Jyb2NhZGUvYm5hL2JuYWQuYw0KKysrIGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvYnJv
Y2FkZS9ibmEvYm5hZC5jDQpAQCAtMzI2OCw2ICszMjY4LDcgQEAgYm5hZF9wY2lfcHJvYmUoc3Ry
dWN0IHBjaV9kZXYgKnBkZXYsDQogCSAqCU91dHB1dCA6IHVzaW5nX2RhYyA9IDEgZm9yIDY0IGJp
dCBETUENCiAJICoJCQkgICA9IDAgZm9yIDMyIGJpdCBETUENCiAJICovDQorCXVzaW5nX2RhYyA9
IGZhbHNlOw0KIAllcnIgPSBibmFkX3BjaV9pbml0KGJuYWQsIHBkZXYsICZ1c2luZ19kYWMpOw0K
IAlpZiAoZXJyKQ0KIAkJZ290byB1bmxvY2tfbXV0ZXg7DQotLSANCjEuNy4xMS40DQoNCg==
