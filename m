From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] bridge: also trigger RTM_NEWLINK when
 interface is released from bridge
Date: Wed, 20 Sep 2017 15:41:17 -0700 (PDT)
Message-ID: <20170920.154117.1811118515077748495.davem@davemloft.net>
References: <20170920.140956.781667692297467325.davem@davemloft.net>
        <16e5566a-909d-ba83-7637-1fb6c93126bc@gmail.com>
        <87bmm56mu2.fsf@luffy.cx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: dsahern@gmail.com, stephen@networkplumber.org,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: vincent@bernat.im
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40864 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751733AbdITWlS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 18:41:18 -0400
In-Reply-To: <87bmm56mu2.fsf@luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogVmluY2VudCBCZXJuYXQgPHZpbmNlbnRAYmVybmF0LmltPg0KRGF0ZTogVGh1LCAyMSBT
ZXAgMjAxNyAwMDoxMjo1MyArMDIwMA0KDQo+ICDinaYgMjAgc2VwdGVtYnJlIDIwMTcgMTU6NTcg
LTA2MDAsIERhdmlkIEFoZXJuIDxkc2FoZXJuQGdtYWlsLmNvbT7CoDoNCj4gDQo+PiBUaGUgREVM
TElOSyBpcyBmb3IgQUZfQlJJREdFIGZhbWlseSAoaWZpX2ZhbWlseSkuIEFkZGluZyBmYW1pbHkg
dG8NCj4+IHByaW50X2xpbmtpbmZvIGFuZCBydW5uaW5nIHRoZSBtb25pdG9yIEkgZ2V0Og0KPj4N
Cj4+DQo+PiBbTElOS11mYW1pbHkgMDogMzU6IGR1bW15MTogPEJST0FEQ0FTVCxOT0FSUCxVUCxM
T1dFUl9VUD4gbXR1IDE1MDAgcWRpc2MNCj4+IG5vcXVldWUgbWFzdGVyIGJyMCBzdGF0ZSBVTktO
T1dOIGdyb3VwIGRlZmF1bHQNCj4+ICAgICBsaW5rL2V0aGVyIGQ2OmMzOjczOjg2OjNjOjczIGJy
ZCBmZjpmZjpmZjpmZjpmZjpmZg0KPj4NCj4+IFtMSU5LXWZhbWlseSA3OiAzNTogZHVtbXkxOiA8
QlJPQURDQVNULE5PQVJQLFVQLExPV0VSX1VQPiBtdHUgMTUwMA0KPj4gbWFzdGVyIGJyMCBzdGF0
ZSBVTktOT1dODQo+PiAgICAgbGluay9ldGhlciBkNjpjMzo3Mzo4NjozYzo3Mw0KPj4NCj4+IFtM
SU5LXURlbGV0ZWQgZmFtaWx5IDc6IDM1OiBkdW1teTE6IDxCUk9BRENBU1QsTk9BUlAsVVAsTE9X
RVJfVVA+IG10dQ0KPj4gMTUwMCBtYXN0ZXIgYnIwIHN0YXRlIFVOS05PV04NCj4+ICAgICBsaW5r
L2V0aGVyIGQ2OmMzOjczOjg2OjNjOjczDQo+IA0KPiBJIGRpZG4ndCBrbm93IGFib3V0IHRoZSBm
YW1pbHkuIFdlIGNhbiBkcm9wIHRoZSBwYXRjaC4NCg0KT2ssIEkndmUgcmV2ZXJ0ZWQuDQoNClRo
YW5rcy4NCg==
