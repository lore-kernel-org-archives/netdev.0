From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hv_netvsc: fix send buffer failure on MTU change
Date: Thu, 21 Sep 2017 15:18:41 -0700 (PDT)
Message-ID: <20170921.151841.2164510833838294238.davem@davemloft.net>
References: <20170920181735.31316-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: kys@microsoft.com, netdev@vger.kernel.org, alexng@microsoft.com,
        sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59946 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751728AbdIUWSm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 18:18:42 -0400
In-Reply-To: <20170920181735.31316-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogU3RlcGhlbiBIZW1taW5nZXIgPHN0ZXBoZW5AbmV0d29ya3BsdW1iZXIub3JnPg0KRGF0
ZTogV2VkLCAyMCBTZXAgMjAxNyAxMToxNzozNSAtMDcwMA0KDQo+IEZyb206IEFsZXggTmcgPGFs
ZXhuZ0BtaWNyb3NvZnQuY29tPg0KPiANCj4gSWYgTVRVIGlzIGNoYW5nZWQgdGhlIGhvc3Qgd291
bGQgcmVqZWN0IHRoZSBzZW5kIGJ1ZmZlciBjaGFuZ2UuDQo+IFRoaXMgcHJvYmxlbSBpcyByZXN1
bHQgb2YgcmVjZW50IGNoYW5nZSB0byBhbGxvdyBjaGFuZ2luZyBzZW5kDQo+IGJ1ZmZlciBzaXpl
Lg0KPiANCj4gRXZlcnkgdGltZSB3ZSBjaGFuZ2UgdGhlIE1UVSwgd2Ugc3RvcmUgdGhlIHByZXZp
b3VzIG5ldF9kZXZpY2Ugc2VjdGlvbg0KPiBjb3VudCBiZWZvcmUgZGVzdHJveWluZyB0aGUgYnVm
ZmVyLCBidXQgd2UgZG9uonQgc3RvcmUgdGhlIHByZXZpb3VzDQo+IHNlY3Rpb24gc2l6ZS4gV2hl
biB3ZSByZWluaXRpYWxpemUgdGhlIGJ1ZmZlciwgaXRzIHNpemUgaXMgY2FsY3VsYXRlZA0KPiBi
eSBtdWx0aXBseWluZyB0aGUgcHJldmlvdXMgY291bnQgYW5kIHByZXZpb3VzIHNpemUuIFNpbmNl
IHdlDQo+IGNvbnRpbnVvdXNseSBpbmNyZWFzZSB0aGUgTVRVLCB0aGUgaG9zdCByZXR1cm5zIHVz
IGEgZGVjcmVhc2luZyBjb3VudA0KPiB2YWx1ZSB3aGlsZSB0aGUgc2VjdGlvbiBzaXplIGlzIHJl
aW5pdGlhbGl6ZWQgdG8gMTcyOCBieXRlcyBldmVyeQ0KPiB0aW1lLg0KPiANCj4gVGhpcyBldmVu
dHVhbGx5IGxlYWRzIHRvIGEgY29uZGl0aW9uIHdoZXJlIHRoZSBjYWxjdWxhdGVkIGJ1Zl9zaXpl
IGlzDQo+IHNvIHNtYWxsIHRoYXQgdGhlIGhvc3QgcmVqZWN0cyBpdC4NCj4gDQo+IEZpeGVzOiA4
YjUzMjc5NzVhZTEgKCJuZXR2c2M6IGFsbG93IGNvbnRyb2xsaW5nIHNlbmQvcmVjdiBidWZmZXIg
c2l6ZSIpDQo+IFNpZ25lZC1vZmYtYnk6IEFsZXggTmcgPGFsZXhuZ0BtaWNyb3NvZnQuY29tPg0K
PiBTaWduZWQtb2ZmLWJ5OiBTdGVwaGVuIEhlbW1pbmdlciA8c3RoZW1taW5AbWljcm9zb2Z0LmNv
bT4NCg0KQXBwbGllZCwgdGhhbmsgeW91Lg0K
