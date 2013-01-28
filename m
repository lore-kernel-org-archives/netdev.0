From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SCTP: Free the per-net sysctl table on net exit.
Date: Sun, 27 Jan 2013 19:35:11 -0500 (EST)
Message-ID: <20130127.193511.2294954038548420781.davem@davemloft.net>
References: <51004F2D.9000405@fold.natur.cuni.cz>
	<1359043367-30180-1-git-send-email-vyasevich@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	mmokrejs@fold.natur.cuni.cz, ebiederm@xmission.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36885 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753039Ab3A1AfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 19:35:13 -0500
In-Reply-To: <1359043367-30180-1-git-send-email-vyasevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogVmxhZCBZYXNldmljaCA8dnlhc2V2aWNoQGdtYWlsLmNvbT4NCkRhdGU6IFRodSwgMjQg
SmFuIDIwMTMgMTE6MDI6NDcgLTA1MDANCg0KPiBAQCAtMzY2LDcgKzM2NiwxMSBAQCBpbnQgc2N0
cF9zeXNjdGxfbmV0X3JlZ2lzdGVyKHN0cnVjdCBuZXQgKm5ldCkNCj4gIA0KPiAgdm9pZCBzY3Rw
X3N5c2N0bF9uZXRfdW5yZWdpc3RlcihzdHJ1Y3QgbmV0ICpuZXQpDQo+ICB7DQo+ICsJc3RydWN0
IGN0bF90YWJsZSAqdGFibGU7DQo+ICsNCj4gKwl0YWJsZSA9IG5ldC0+c2N0cC5zeXNjdGxfaGRy
LT5jdGxfdGFibGVfYXJnOw0KPiAgCXVucmVnaXN0ZXJfbmV0X3N5c2N0bF90YWJsZShuZXQtPnNj
dHAuc3lzY3RsX2hlYWRlcik7DQo+ICsJa2ZyZWUodGFibGUpOw0KPiAgfQ0KDQpJbiB3aGF0IHRy
ZWUgZG9lcyB0aGlzIGNvbXBpbGU/ICBJIHRyaWVkIGJvdGggJ25ldCcgYW5kICduZXQtbmV4dCcN
CmFuZCBnb3QgdGhlIHNhbWUgZXhhY3QgcmVzdWx0Og0KDQpuZXQvc2N0cC9zeXNjdGwuYzogSW4g
ZnVuY3Rpb24goXNjdHBfc3lzY3RsX25ldF91bnJlZ2lzdGVyojoNCm5ldC9zY3RwL3N5c2N0bC5j
OjM3MToxOTogZXJyb3I6IKFzdHJ1Y3QgbmV0bnNfc2N0cKIgaGFzIG5vIG1lbWJlciBuYW1lZCCh
c3lzY3RsX2hkcqINCm1ha2VbMV06ICoqKiBbbmV0L3NjdHAvc3lzY3RsLm9dIEVycm9yIDENCm1h
a2U6ICoqKiBbbmV0L3NjdHAvc3lzY3RsLm9dIEVycm9yIDINCg==
