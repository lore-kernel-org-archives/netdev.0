From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] ip6_tunnel: fix potential issue in __ip6_tnl_rcv
Date: Thu, 08 Jun 2017 09:18:35 -0400 (EDT)
Message-ID: <20170608.091835.68093454960092119.davem@davemloft.net>
References: <20170608043847.uejvydlitzuik76j@ast-mbp>
        <3A078CA0-C9C8-45D2-A359-1FB38B25792D@cmss.chinamobile.com>
        <20170608050041.cte3gpavshg2nmdc@ast-mbp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: yanhaishuang@cmss.chinamobile.com, netdev@vger.kernel.org,
        edumazet@google.com
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55088 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751232AbdFHNSh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 09:18:37 -0400
In-Reply-To: <20170608050041.cte3gpavshg2nmdc@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQWxleGVpIFN0YXJvdm9pdG92IDxhbGV4ZWkuc3Rhcm92b2l0b3ZAZ21haWwuY29tPg0K
RGF0ZTogV2VkLCA3IEp1biAyMDE3IDIyOjAwOjQzIC0wNzAwDQoNCj4gT24gVGh1LCBKdW4gMDgs
IDIwMTcgYXQgMTI6NTY6NThQTSArMDgwMCwg5Lil5rW35Y+MIHdyb3RlOg0KPj4gDQo+PiA+IE9u
IDggSnVuIDIwMTcsIGF0IDEyOjM4IFBNLCBBbGV4ZWkgU3Rhcm92b2l0b3YgPGFsZXhlaS5zdGFy
b3ZvaXRvdkBnbWFpbC5jb20+IHdyb3RlOg0KPj4gPiANCj4+ID4gT24gVGh1LCBKdW4gMDgsIDIw
MTcgYXQgMTI6MzI6NDRQTSArMDgwMCwgSGFpc2h1YW5nIFlhbiB3cm90ZToNCj4+ID4+IFdoZW4g
X19pcDZfdG5sX3JjdiBmYWlscywgdGhlIHR1bl9kc3Qgd29uJ3QgYmUgZnJlZWQsIHNvIGNhbGwN
Cj4+ID4+IGRzdF9yZWxlYXNlIHRvIGZyZWUgaXQgaW4gZXJyb3IgY29kZSBwYXRoLg0KPj4gPj4g
DQo+PiA+PiBDQzogQWxleGVpIFN0YXJvdm9pdG92IDxhc3RAZmIuY29tPg0KPj4gPj4gRml4ZXM6
IDhkNzkyNjZiYzQ4YyAoImlwNl90dW5uZWw6IGFkZCBjb2xsZWN0X21kIG1vZGUgdG8gSVB2NiB0
dW5uZWxzIikNCj4+ID4+IFNpZ25lZC1vZmYtYnk6IEhhaXNodWFuZyBZYW4gPHlhbmhhaXNodWFu
Z0BjbXNzLmNoaW5hbW9iaWxlLmNvbT4NCj4+ID4gDQo+PiA+IEkgZG9uJ3QgZ2V0IGl0LiBXaHkg
ZGlkIHlvdSBzZW5kIGFub3RoZXIgdmVyc2lvbiBvZiB0aGUgcGF0Y2g/DQo+PiA+IFdoYXQgd2Fz
IHdyb25nIHdpdGggcHJldmlvdXMgYXBwcm9hY2ggdGhhdCBteXNlbGYgYW5kIEVyaWMgYWNrZWQ/
DQo+PiA+IA0KPj4gPiANCj4+IA0KPj4gU29ycnkgZm9yIHlvdXIgY29uZnVzaW5nLCBiZWNhdXNl
IFByYXZpbiBTaGVsYXIgZ2l2ZSBhIGZlZWRiYWNrIGluIGlwdjQgcGF0Y2gsIHNlZSBiZWxvdzoN
Cj4gDQo+IGhtbS4gcmlnaHQuDQo+IFRoZW4gaXQgcmFpc2VzIHRoZSBxdWVzdGlvbjogSG93IGRp
ZCB5b3UgdGVzdCB0aGlzIGFuZCBwcmV2aW91cyBwYXRjaD8NCj4gDQo+IHNpbmNlIHByZXZpb3Vz
IHZlcnNpb24gd2FzIHNvcnQtb2YgZml4aW5nIHRoZSBidWcsIGJ1dCBjb21wbGV0ZWx5DQo+IGJy
ZWFraW5nIHRoZSBsb2dpYy4uLg0KDQpBbnlvbmUgd2hvIHBvc3RzIG5ldyBwYXRjaGVzIHRoaXMg
cGF0Y2ggaXNuJ3QgdGVzdGluZyB0aGluZ3MgdGhvcm91Z2hseSBhdCBhbGwuDQo=
