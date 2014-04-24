From: "Zhangjie (HZ)" <zhangjie14@huawei.com>
Subject: RE: Change dev->needed_headroom of virtio_net to make
 Patch"virtio-net: put virtio net header inline with data"work better
Date: Thu, 24 Apr 2014 11:50:24 +0000
Message-ID: <60A73B7A161A82449A7DB7B382BFD15537026F76@SZXEMA504-MBS.china.huawei.com>
References: <60A73B7A161A82449A7DB7B382BFD15537026EF3@SZXEMA504-MBS.china.huawei.com>
 <20140424114457.GB16979@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "jasowang@redhat.com" <jasowang@redhat.com>,
	Qinchuanyu <qinchuanyu@huawei.com>,
	Liuyongan <liuyongan@huawei.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:13479 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752996AbaDXLul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 07:50:41 -0400
In-Reply-To: <20140424114457.GB16979@redhat.com>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VGhhbmsgeW91IHZlcnkgbXVjaCENCkkgd2lsbCBwb3N0IGEgcGF0Y2ggdG9tb3Jyb3cuDQoNCi0t
QmVzdCB3aXNoZXMhDQovL1poYW5nIEppZQ0KLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCkZy
b206IE1pY2hhZWwgUy4gVHNpcmtpbiBbbWFpbHRvOm1zdEByZWRoYXQuY29tXSANClNlbnQ6IFRo
dXJzZGF5LCBBcHJpbCAyNCwgMjAxNCA3OjQ1IFBNDQpUbzogWmhhbmdqaWUgKEhaKQ0KQ2M6IGph
c293YW5nQHJlZGhhdC5jb207IFFpbmNodWFueXU7IExpdXlvbmdhbjsga3ZtQHZnZXIua2VybmVs
Lm9yZzsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZw0KU3ViamVjdDogUmU6IENoYW5nZSBkZXYtPm5l
ZWRlZF9oZWFkcm9vbSBvZiB2aXJ0aW9fbmV0IHRvIG1ha2UgUGF0Y2gidmlydGlvLW5ldDogcHV0
IHZpcnRpbyBuZXQgaGVhZGVyIGlubGluZSB3aXRoIGRhdGEid29yayBiZXR0ZXINCg0KT24gVGh1
LCBBcHIgMjQsIDIwMTQgYXQgMTA6MTk6NThBTSArMDAwMCwgWmhhbmdqaWUgKEhaKSB3cm90ZToN
Cj4gSGkhDQo+IA0KPiBQYXRjaCDigJx2aXJ0aW8tbmV0OiBwdXQgdmlydGlvIG5ldCBoZWFkZXIg
aW5saW5lIHdpdGggZGF0YeKAnSAsIGhhcyBhIA0KPiBub3RhYmxlIGltcHJvdmVtZW50IGZvciBU
Q1AgcGFja2FnZXMuDQo+IA0KPiBCdXQgVURQIHBhY2thZ2VzIGZyb20gdmlydGlvX25ldCBuaWMs
IGRvIG5vdCBoYXZlIGVub3VnaCBoZWFkIHJvb20uIEkgDQo+IHdvbmRlciBpZiB3ZSBjYW4gc2V0
IGRldi0+bmVlZGVkX2hlYWRyb29tDQo+IA0KPiB0byB0aGUgc2l6ZSBvZiB2aXJ0aW8gbmV0IGhl
YWRlciwgc28gYXMgdG8gcHV0IHRoZSBoZWFkZXIgaW4uIEJ5IGRvaW5nIA0KPiB0aGlzLCB1ZHAg
Z2V0IGFib3V0IDUlIGltcHJvdmVtZW50IGluIGJhbmR3aWR0aC4NCg0KU291bmRzIGxpa2UgYSBy
ZWFzb25hYmxlIHRoaW5nIHRvIGRvLg0KV2FudCB0byBwb3N0IHRoZSBwYXRjaCBzbyBwZW9wbGUg
Y2FuIHRyeSBpdCBvdXQ/DQoNCj4gIA0KPiANCj4gLS0NCj4gDQo+IFRoYW5rcywNCj4gDQo+IC8v
WmhhbmcgSmllDQo+IA0KPiAgDQo+IA0K
