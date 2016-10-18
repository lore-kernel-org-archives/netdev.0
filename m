From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 27/28] rocker: fix maybe-uninitialized warning
Date: Tue, 18 Oct 2016 14:21:18 -0400 (EDT)
Message-ID: <20161018.142118.319304612159280333.davem@davemloft.net>
References: <20161017220342.1627073-1-arnd@arndb.de>
        <20161017221650.1902729-8-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: jiri@resnulli.us, torvalds@linux-foundation.org,
        linux-kernel@vger.kernel.org, idosch@mellanox.com,
        dan.carpenter@oracle.com, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45064 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034340AbcJRSVT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 14:21:19 -0400
In-Reply-To: <20161017221650.1902729-8-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQXJuZCBCZXJnbWFubiA8YXJuZEBhcm5kYi5kZT4NCkRhdGU6IFR1ZSwgMTggT2N0IDIw
MTYgMDA6MTY6MTUgKzAyMDANCg0KPiBJbiBzb21lIHJhcmUgY29uZmlndXJhdGlvbnMsIHdlIGdl
dCBhIHdhcm5pbmcgYWJvdXQgdGhlICdpbmRleCcgdmFyaWFibGUNCj4gYmVpbmcgdXNlZCB3aXRo
b3V0IGFuIGluaXRpYWxpemF0aW9uOg0KPiANCj4gZHJpdmVycy9uZXQvZXRoZXJuZXQvcm9ja2Vy
L3JvY2tlcl9vZmRwYS5jOiBJbiBmdW5jdGlvbiChb2ZkcGFfcG9ydF9maWJfaXB2NC5pc3JhLjE2
LmNvbnN0cHJvcKI6DQo+IGRyaXZlcnMvbmV0L2V0aGVybmV0L3JvY2tlci9yb2NrZXJfb2ZkcGEu
YzoyNDI1OjkyOiB3YXJuaW5nOiChaW5kZXiiIG1heSBiZSB1c2VkIHVuaW5pdGlhbGl6ZWQgaW4g
dGhpcyBmdW5jdGlvbiBbLVdtYXliZS11bmluaXRpYWxpemVkXQ0KPiANCj4gVGhpcyBpcyBhIGZh
bHNlIHBvc2l0aXZlLCB0aGUgbG9naWMgaXMganVzdCBhIGJpdCB0b28gY29tcGxleCBmb3IgZ2Nj
DQo+IHRvIGZvbGxvdyBoZXJlLiBNb3ZpbmcgdGhlIGludGlhbGl6YXRpb24gb2YgJ2luZGV4JyBh
IGxpdHRsZSBmdXJ0aGVyDQo+IGRvd24gbWFrZXMgaXQgY2xlYXIgdG8gZ2NjIHRoYXQgdGhlIGZ1
bmN0aW9uIGFsd2F5cyByZXR1cm5zIGFuIGVycm9yDQo+IGlmIGl0IGlzIG5vdCBpbml0aWFsaXpl
ZC4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEFybmQgQmVyZ21hbm4gPGFybmRAYXJuZGIuZGU+DQoN
CkFwcGxpZWQuDQo=
