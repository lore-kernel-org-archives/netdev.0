From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [PATCH] net: fib: fix fib_new_table() logical issue
Date: Wed, 21 Jun 2017 23:48:44 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15BCDA5D@cnshjmbx02>
References: <1498053744-3217-1-git-send-email-cugyly@163.com>
 <CAM_iQpWAeYVkyxKtLFzg7J0H8VcB8VFoU+EUQMQM-2DzMjo04g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, yuan linyu <cugyly@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:42089 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751988AbdFUXsr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 19:48:47 -0400
In-Reply-To: <CAM_iQpWAeYVkyxKtLFzg7J0H8VcB8VFoU+EUQMQM-2DzMjo04g@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

U29ycnksIGl0J3Mgbm90IGRlYWQgbG9vcCwgSSByZWFsaXplZCBpdCBidXQgSSB0cmllZCB0byBz
ZW5kIHRvIG1haWwgdG8gbm90ZSBpdCBvbiBteSBwaG9uZSwgaXQgZmFpbGVkLiANCg0KPiAtLS0t
LU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBDb25nIFdhbmcgW21haWx0bzp4aXlvdS53
YW5nY29uZ0BnbWFpbC5jb21dDQo+IFNlbnQ6IFRodXJzZGF5LCBKdW5lIDIyLCAyMDE3IDY6NTQg
QU0NCj4gVG86IHl1YW4gbGlueXUNCj4gQ2M6IExpbnV4IEtlcm5lbCBOZXR3b3JrIERldmVsb3Bl
cnM7IERhdmlkIFMgLiBNaWxsZXI7IFlVQU4gTGlueXUNCj4gU3ViamVjdDogUmU6IFtQQVRDSF0g
bmV0OiBmaWI6IGZpeCBmaWJfbmV3X3RhYmxlKCkgbG9naWNhbCBpc3N1ZQ0KPiANCj4gT24gV2Vk
LCBKdW4gMjEsIDIwMTcgYXQgNzowMiBBTSwgeXVhbiBsaW55dSA8Y3VneWx5QDE2My5jb20+IHdy
b3RlOg0KPiA+IEZyb206IHl1YW4gbGlueXUgPExpbnl1Lll1YW5AYWxjYXRlbC1zYmVsbC5jb20u
Y24+DQo+ID4NCj4gPiB3aGVuIENPTkZJR19JUF9NVUxUSVBMRV9UQUJMRVMgZGVmaW5lZCwNCj4g
PiBpZiBpZCA9PSBSVF9UQUJMRV9MT0NBTCBhbmQgIW5ldC0+aXB2NC5maWJfaGFzX2N1c3RvbV9y
dWxlcywNCj4gPiBmaWJfbmV3X3RhYmxlKCkgY2FsbCBpdHNlbGYgdG8gZ2V0IFJUX1RBQkxFX01B
SU4gdGFibGUsDQo+ID4gYnV0IGlmIFJUX1RBQkxFX01BSU4gdGFibGUgbm90IGV4aXN0IGF0IHRo
aXMgcG9pbnQsDQo+ID4gdGhpcyBmdW5jdGlvbiB3aWxsIGJlY29tZSBkZWFkbG9vcC4NCj4gDQo+
IFdoeSBkZWFkbG9vcCBoZXJlPyBJZiBmaWJfbmV3X3RhYmxlKCkgaXMgY2FsbGVkIHJlY3Vyc2l2
ZWx5LA0KPiB0aGVuIG1haW4gdGFibGUgaXMgY3JlYXRlZCBieSBmaWJfdHJpZV90YWJsZSgpIGFu
ZCB3ZSByZXR1cm4uDQo=
