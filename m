From: Stephen Hemminger <sthemmin@microsoft.com>
Subject: RE: [PATCH net-next 4/4] mlx4: sizeof style usage
Date: Sun, 20 Aug 2017 18:00:27 +0000
Message-ID: <DM2PR21MB0074E2B2C697B1300B77EFEACC860@DM2PR21MB0074.namprd21.prod.outlook.com>
References: <20170815172919.26153-1-sthemmin@microsoft.com>
 <20170815172919.26153-5-sthemmin@microsoft.com>
 <d38cac6d-77a7-e411-73b0-78adad9cbd5f@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "virtualization@lists.linux-foundation.org"
        <virtualization@lists.linux-foundation.org>
To: Tariq Toukan <tariqt@mellanox.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "mlindner@marvell.com" <mlindner@marvell.com>,
        "mst@redhat.com" <mst@redhat.com>,
        "jasowang@redhat.com" <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0120.outbound.protection.outlook.com ([104.47.42.120]:45087
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753122AbdHTSAb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 20 Aug 2017 14:00:31 -0400
In-Reply-To: <d38cac6d-77a7-e411-73b0-78adad9cbd5f@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WWVzLCBnb29kIGNhdGNoLg0KDQotLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KRnJvbTogVGFy
aXEgVG91a2FuIFttYWlsdG86dGFyaXF0QG1lbGxhbm94LmNvbV0gDQpTZW50OiBTdW5kYXksIEF1
Z3VzdCAyMCwgMjAxNyAzOjI3IEFNDQpUbzogU3RlcGhlbiBIZW1taW5nZXIgPHN0ZXBoZW5AbmV0
d29ya3BsdW1iZXIub3JnPjsgbWxpbmRuZXJAbWFydmVsbC5jb207IG1zdEByZWRoYXQuY29tOyBq
YXNvd2FuZ0ByZWRoYXQuY29tDQpDYzogbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsgbGludXgtcmRt
YUB2Z2VyLmtlcm5lbC5vcmc7IHZpcnR1YWxpemF0aW9uQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24u
b3JnOyBTdGVwaGVuIEhlbW1pbmdlciA8c3RoZW1taW5AbWljcm9zb2Z0LmNvbT4NClN1YmplY3Q6
IFJlOiBbUEFUQ0ggbmV0LW5leHQgNC80XSBtbHg0OiBzaXplb2Ygc3R5bGUgdXNhZ2UNCg0KW1lv
dSBkb24ndCBvZnRlbiBnZXQgZW1haWwgZnJvbSBUQVJJUVRATUVMTEFOT1guQ09NLiBMZWFybiB3
aHkgdGhpcyBpcyBpbXBvcnRhbnQgYXQgaHR0cDovL2FrYS5tcy9MZWFybkFib3V0U2VuZGVySWRl
bnRpZmljYXRpb24uXQ0KDQpUaGFua3MgU3RlcGhlbi4NClNvcnJ5IGZvciB0aGUgbGF0ZSByZXBs
eSwgSSB3YXMgb24gdmFjYXRpb24uDQpJIGtub3cgdGhpcyBpcyBhbHJlYWR5IGFjY2VwdGVkLCBi
dXQgc3RpbGwgSSBoYXZlIG9uZSBjb21tZW50Lg0KDQpPbiAxNS8wOC8yMDE3IDg6MjkgUE0sIFN0
ZXBoZW4gSGVtbWluZ2VyIHdyb3RlOg0KPiBUaGUga2VybmVsIGNvZGluZyBzdHlsZSBpcyB0byB0
cmVhdCBzaXplb2YgYXMgYSBmdW5jdGlvbg0KPiAoaWUuIHdpdGggcGFyZW50aGVzaXMpIG5vdCBh
cyBhbiBvcGVyYXRvci4NCj4NCj4gQWxzbyB1c2Uga2NhbGxvYyBhbmQga21hbGxvY19hcnJheQ0K
Pg0KPiBTaWduZWQtb2ZmLWJ5OiBTdGVwaGVuIEhlbW1pbmdlciA8c3RlcGhlbkBuZXR3b3JrcGx1
bWJlci5vcmc+DQo+IC0tLQ0KPiBAQCAtNzI2LDcgKzcyNiw3IEBAIHN0YXRpYyBpbnQgbWx4NF9l
cV9pbnQoc3RydWN0IG1seDRfZGV2ICpkZXYsIHN0cnVjdCBtbHg0X2VxICplcSkNCj4gICAgICAg
ICAgICAgICAgICAgICAgIH0NCj4gICAgICAgICAgICAgICAgICAgICAgIG1lbWNweSgmcHJpdi0+
bWZ1bmMubWFzdGVyLmNvbW1fYXJtX2JpdF92ZWN0b3IsDQo+ICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgZXFlLT5ldmVudC5jb21tX2NoYW5uZWxfYXJtLmJpdF92ZWMsDQo+IC0gICAgICAg
ICAgICAgICAgICAgICAgICAgICAgc2l6ZW9mIGVxZS0+ZXZlbnQuY29tbV9jaGFubmVsX2FybS5i
aXRfdmVjKTsNCj4gKyAgICAgICAgICAgICAgICAgICAgICAgICAgICBzaXplb2YoZXFlKS0+ZXZl
bnQuY29tbV9jaGFubmVsX2FybS5iaXRfdmVjKTsNCg0KSSB0aGluayB0aGUgYnJhY2tldHMgaGVy
ZSBhcmUgbWlzcGxhY2VkLg0KU2hvdWxkbid0IHRoZXkgYmUgYXMgZm9sbG93cz8NCg0Kc2l6ZW9m
KGVxZS0+ZXZlbnQuY29tbV9jaGFubmVsX2FybS5iaXRfdmVjKSk7DQoNCj4gICAgICAgICAgICAg
ICAgICAgICAgIHF1ZXVlX3dvcmsocHJpdi0+bWZ1bmMubWFzdGVyLmNvbW1fd3EsDQo+ICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICZwcml2LT5tZnVuYy5tYXN0ZXIuY29tbV93b3Jr
KTsNCj4gICAgICAgICAgICAgICAgICAgICAgIGJyZWFrOw0KDQpUaGFua3MsDQpUYXJpcQ0K
