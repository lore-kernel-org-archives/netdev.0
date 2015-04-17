From: David Miller <davem@davemloft.net>
Subject: [PATCH] sfc: Fix memcpy() with const destination compiler warning.
Date: Fri, 17 Apr 2015 15:16:54 -0400 (EDT)
Message-ID: <20150417.151654.1368879418386402419.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbbDQTQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 15:16:56 -0400
Received: from localhost (nat-pool-rdu-t.redhat.com [66.187.233.202])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 95711586126
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2015 12:16:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQpkcml2ZXJzL25ldC9ldGhlcm5ldC9zZmMvc2VsZnRlc3QuYzogSW4gZnVuY3Rpb24goWVmeF9p
dGVyYXRlX3N0YXRlojoNCmRyaXZlcnMvbmV0L2V0aGVybmV0L3NmYy9zZWxmdGVzdC5jOjM4ODo5
OiB3YXJuaW5nOiBwYXNzaW5nIGFyZ3VtZW50IDEgb2YgoW1lbWNweaIgZGlzY2FyZHMgoWNvbnN0
oiBxdWFsaWZpZXIgZnJvbSBwb2ludGVyIHRhcmdldCB0eXBlIFstV2Rpc2NhcmRlZC1hcnJheS1x
dWFsaWZpZXJzXQ0KDQpUaGlzIGlzIGJlY2F1c2UgdGhlIG1zZ1tdIG1lbWJlciBvZiBzdHJ1Y3Qg
ZWZ4X2xvb3BiYWNrX3BheWxvYWQNCmlzIG1hcmtlZCBhcyAnY29uc3QnLiAgUmVtb3ZlIHRoYXQu
DQoNClNpZ25lZC1vZmYtYnk6IERhdmlkIFMuIE1pbGxlciA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD4N
Ci0tLQ0KIGRyaXZlcnMvbmV0L2V0aGVybmV0L3NmYy9zZWxmdGVzdC5jIHwgMiArLQ0KIDEgZmls
ZSBjaGFuZ2VkLCAxIGluc2VydGlvbigrKSwgMSBkZWxldGlvbigtKQ0KDQpkaWZmIC0tZ2l0IGEv
ZHJpdmVycy9uZXQvZXRoZXJuZXQvc2ZjL3NlbGZ0ZXN0LmMgYi9kcml2ZXJzL25ldC9ldGhlcm5l
dC9zZmMvc2VsZnRlc3QuYw0KaW5kZXggMTBiNjE3My4uYjYwNWRmZDUgMTAwNjQ0DQotLS0gYS9k
cml2ZXJzL25ldC9ldGhlcm5ldC9zZmMvc2VsZnRlc3QuYw0KKysrIGIvZHJpdmVycy9uZXQvZXRo
ZXJuZXQvc2ZjL3NlbGZ0ZXN0LmMNCkBAIC00Niw3ICs0Niw3IEBAIHN0cnVjdCBlZnhfbG9vcGJh
Y2tfcGF5bG9hZCB7DQogCXN0cnVjdCBpcGhkciBpcDsNCiAJc3RydWN0IHVkcGhkciB1ZHA7DQog
CV9fYmUxNiBpdGVyYXRpb247DQotCWNvbnN0IGNoYXIgbXNnWzY0XTsNCisJY2hhciBtc2dbNjRd
Ow0KIH0gX19wYWNrZWQ7DQogDQogLyogTG9vcGJhY2sgdGVzdCBzb3VyY2UgTUFDIGFkZHJlc3Mg
Ki8NCi0tIA0KMi4zLjUNCg0K
