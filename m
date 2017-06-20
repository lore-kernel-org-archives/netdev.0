From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] enic: Fix format truncation warning
Date: Tue, 20 Jun 2017 15:27:14 -0400 (EDT)
Message-ID: <20170620.152714.351257547066260274.davem@davemloft.net>
References: <20170619232844.34916-1-gvaradar@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, benve@cisco.com
To: gvaradar@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42300 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752601AbdFTT1Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 15:27:16 -0400
In-Reply-To: <20170619232844.34916-1-gvaradar@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogR292aW5kYXJhanVsdSBWYXJhZGFyYWphbiA8Z3ZhcmFkYXJAY2lzY28uY29tPg0KRGF0
ZTogTW9uLCAxOSBKdW4gMjAxNyAxNjoyODo0NCAtMDcwMA0KDQo+IFdpdGggLVdmb3JtYXQtdHJ1
bmNhdGlvbiwgZ2NjIHRocm93cyB0aGUgZm9sbG93aW5nIHdhcm5pbmcuDQo+IA0KPiBGaXggdGhp
cyBieSBpbmNyZWFzaW5nIHRoZSBzaXplIG9mIGRldm5hbWUgdG8gYWNjb21tb2RhdGUgMTUgY2hh
cmFjdGVyDQo+IG5ldGRldiBpbnRlcmZhY2UgbmFtZSBhbmQgZGVzY3JpcHRpb24uDQo+IA0KPiBS
ZW1vdmUgbGVuZ3RoIGZvcm1hdCBwcmVjaXNpb24gZm9yICVzLiBXZSBjYW4gZml0IGVudGlyZSBu
YW1lLg0KPiANCj4gQWxzbyBpbmNyZW1lbnQgdGhlIHZlcnNpb24uDQo+IA0KPiBkcml2ZXJzL25l
dC9ldGhlcm5ldC9jaXNjby9lbmljL2VuaWNfbWFpbi5jOiBJbiBmdW5jdGlvbiChZW5pY19vcGVu
ojoNCj4gZHJpdmVycy9uZXQvZXRoZXJuZXQvY2lzY28vZW5pYy9lbmljX21haW4uYzoxNzQwOjE1
OiB3YXJuaW5nOiChJXWiIGRpcmVjdGl2ZSBvdXRwdXQgbWF5IGJlIHRydW5jYXRlZCB3cml0aW5n
IGJldHdlZW4gMSBhbmQgMiBieXRlcyBpbnRvIGEgcmVnaW9uIG9mIHNpemUgYmV0d2VlbiAxIGFu
ZCAxMiBbLVdmb3JtYXQtdHJ1bmNhdGlvbj1dDQo+ICAgICAgIiUuMTFzLXJ4LSV1IiwgbmV0ZGV2
LT5uYW1lLCBpKTsNCj4gICAgICAgICAgICAgICAgXn4NCj4gZHJpdmVycy9uZXQvZXRoZXJuZXQv
Y2lzY28vZW5pYy9lbmljX21haW4uYzoxNzQwOjU6IG5vdGU6IGRpcmVjdGl2ZSBhcmd1bWVudCBp
biB0aGUgcmFuZ2UgWzAsIDE2XQ0KPiAgICAgICIlLjExcy1yeC0ldSIsIG5ldGRldi0+bmFtZSwg
aSk7DQo+ICAgICAgXn5+fn5+fn5+fn5+fg0KPiBkcml2ZXJzL25ldC9ldGhlcm5ldC9jaXNjby9l
bmljL2VuaWNfbWFpbi5jOjE3Mzg6NDogbm90ZTogoXNucHJpbnRmoiBvdXRwdXQgYmV0d2VlbiA2
IGFuZCAxOCBieXRlcyBpbnRvIGEgZGVzdGluYXRpb24gb2Ygc2l6ZSAxNg0KPiAgICAgc25wcmlu
dGYoZW5pYy0+bXNpeFtpbnRyXS5kZXZuYW1lLA0KPiAgICAgXn5+fn5+fn5+fn5+fn5+fn5+fn5+
fn5+fn5+fn5+fn5+fg0KPiAgICAgIHNpemVvZihlbmljLT5tc2l4W2ludHJdLmRldm5hbWUpLA0K
PiAgICAgIH5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fg0KPiAgICAgICIlLjExcy1y
eC0ldSIsIG5ldGRldi0+bmFtZSwgaSk7DQo+ICAgICAgfn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+
fn5+fn5+fg0KPiANCj4gU2lnbmVkLW9mZi1ieTogR292aW5kYXJhanVsdSBWYXJhZGFyYWphbiA8
Z3ZhcmFkYXJAY2lzY28uY29tPg0KPiAtLS0NCj4gdjI6IGRvbnQgdXNlIGthc3ByaW50ZiwgaW5j
cmVhc2UgdGhlIGRldm5hbWUgc2l6ZQ0KPiAgICAgaHR0cDovL3BhdGNod29yay5vemxhYnMub3Jn
L3BhdGNoLzc3NzU2OC8NCg0KQXBwbGllZCwgdGhhbmsgeW91Lg0K
