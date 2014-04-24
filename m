From: David Miller <davem@davemloft.net>
Subject: [PATCH] netfilter: Fix warning in nfnetlink_receive().
Date: Thu, 24 Apr 2014 13:52:02 -0400 (EDT)
Message-ID: <20140424.135202.671727829943438386.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33124 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757450AbaDXRwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 13:52:03 -0400
Received: from localhost (unknown [75.103.36.255])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 8870D58428D
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 10:52:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCm5ldC9uZXRmaWx0ZXIvbmZuZXRsaW5rLmM6IEluIGZ1bmN0aW9uIKFuZm5ldGxpbmtfcmN2
ojoNCm5ldC9uZXRmaWx0ZXIvbmZuZXRsaW5rLmM6MzcxOjE0OiB3YXJuaW5nOiB1bnVzZWQgdmFy
aWFibGUgoW5ldKIgWy1XdW51c2VkLXZhcmlhYmxlXQ0KDQpTaWduZWQtb2ZmLWJ5OiBEYXZpZCBT
LiBNaWxsZXIgPGRhdmVtQGRhdmVtbG9mdC5uZXQ+DQotLS0NCiBuZXQvbmV0ZmlsdGVyL25mbmV0
bGluay5jIHwgMSAtDQogMSBmaWxlIGNoYW5nZWQsIDEgZGVsZXRpb24oLSkNCg0KZGlmZiAtLWdp
dCBhL25ldC9uZXRmaWx0ZXIvbmZuZXRsaW5rLmMgYi9uZXQvbmV0ZmlsdGVyL25mbmV0bGluay5j
DQppbmRleCA4NDM5MmYzLi5lMDA5MDg3IDEwMDY0NA0KLS0tIGEvbmV0L25ldGZpbHRlci9uZm5l
dGxpbmsuYw0KKysrIGIvbmV0L25ldGZpbHRlci9uZm5ldGxpbmsuYw0KQEAgLTM2OCw3ICszNjgs
NiBAQCBkb25lOg0KIHN0YXRpYyB2b2lkIG5mbmV0bGlua19yY3Yoc3RydWN0IHNrX2J1ZmYgKnNr
YikNCiB7DQogCXN0cnVjdCBubG1zZ2hkciAqbmxoID0gbmxtc2dfaGRyKHNrYik7DQotCXN0cnVj
dCBuZXQgKm5ldCA9IHNvY2tfbmV0KHNrYi0+c2spOw0KIAlpbnQgbXNnbGVuOw0KIA0KIAlpZiAo
bmxoLT5ubG1zZ19sZW4gPCBOTE1TR19IRFJMRU4gfHwNCi0tIA0KMS43LjExLjcNCg0K
