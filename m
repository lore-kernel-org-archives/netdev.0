From: wangyunjian <wangyunjian@huawei.com>
Subject: RE: [PATCH net] i40e: Fix limit imprecise of the number of MAC/VLAN
 that can be added for VFs
Date: Thu, 28 Sep 2017 01:32:31 +0000
Message-ID: <34EFBCA9F01B0748BEB6B629CE643AE60C64A993@dggemm513-mbx.china.huawei.com>
References: <1506495497-10736-1-git-send-email-wangyunjian@huawei.com>
 <fd104583-6743-9f1b-cba8-988fa1b216db@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        caihe <caihe@huawei.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:12896 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751946AbdI1Bcv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 21:32:51 -0400
In-Reply-To: <fd104583-6743-9f1b-cba8-988fa1b216db@cogentembedded.com>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VGhhbmtzLCBJIHdpbGwgc2VuZCB0aGUgdjIgbGF0ZXIuDQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNz
YWdlLS0tLS0NCj4gRnJvbTogU2VyZ2VpIFNodHlseW92IFttYWlsdG86c2VyZ2VpLnNodHlseW92
QGNvZ2VudGVtYmVkZGVkLmNvbV0NCj4gU2VudDogV2VkbmVzZGF5LCBTZXB0ZW1iZXIgMjcsIDIw
MTcgNzozNCBQTQ0KPiBUbzogd2FuZ3l1bmppYW4gPHdhbmd5dW5qaWFuQGh1YXdlaS5jb20+OyBk
YXZlbUBkYXZlbWxvZnQubmV0Ow0KPiBqZWZmcmV5LnQua2lyc2hlckBpbnRlbC5jb20NCj4gQ2M6
IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc7IGludGVsLXdpcmVkLWxhbkBsaXN0cy5vc3Vvc2wub3Jn
OyBjYWloZQ0KPiA8Y2FpaGVAaHVhd2VpLmNvbT4NCj4gU3ViamVjdDogUmU6IFtQQVRDSCBuZXRd
IGk0MGU6IEZpeCBsaW1pdCBpbXByZWNpc2Ugb2YgdGhlIG51bWJlciBvZg0KPiBNQUMvVkxBTiB0
aGF0IGNhbiBiZSBhZGRlZCBmb3IgVkZzDQo+IA0KPiBIZWxsbyENCj4gDQo+IE9uIDkvMjcvMjAx
NyA5OjU4IEFNLCB3MDAyNzMxODYgd3JvdGU6DQo+IA0KPiA+IEZyb206IFl1bmppYW4gV2FuZyA8
d2FuZ3l1bmppYW5AaHVhd2VpLmNvbT4NCj4gPg0KPiA+IE5vdyBpdCBkb24ndCBsaW1pdCB0aGUg
bnVtYmVyIG9mIE1BQy9WTEFOIHN0cmljdGx5LiBXaGVuIHRoZXJlIGlzIG1vcmUNCj4gDQo+ICAg
ICBEb2Vzbid0Lg0KPiANCj4gPiBlbGVtZW50cyBpbiB0aGUgdmlydGNobmwgTUFDL1ZMQU4gbGlz
dCwgaXQgY2FuIHN0aWxsIGFkZCBzdWNjZXNzZnVsbHkuDQo+ID4NCj4gPiBTaWduZWQtb2ZmLWJ5
OiBZdW5qaWFuIFdhbmcgPHdhbmd5dW5qaWFuQGh1YXdlaS5jb20+DQo+IA0KPiBbLi4uXQ0KPiAN
Cj4gTUJSLCBTZXJnZWkNCg==
