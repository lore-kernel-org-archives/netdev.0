From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] enic: use kasprintf instead of snprintf
Date: Mon, 19 Jun 2017 10:27:32 -0400 (EDT)
Message-ID: <20170619.102732.757903859980010467.davem@davemloft.net>
References: <20170619050537.6393-1-gvaradar@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, benve@cisco.com
To: gvaradar@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58054 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750878AbdFSO1g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 10:27:36 -0400
In-Reply-To: <20170619050537.6393-1-gvaradar@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogR292aW5kYXJhanVsdSBWYXJhZGFyYWphbiA8Z3ZhcmFkYXJAY2lzY28uY29tPg0KRGF0
ZTogU3VuLCAxOCBKdW4gMjAxNyAyMjowNTozNyAtMDcwMA0KDQo+IFdpdGggLVdmb3JtYXQtdHJ1
bmNhdGlvbj0sIGdjYyB0aHJvd3MgdGhlIGZvbGxvd2luZyB3YXJuaW5nLiBJbnN0ZWFkIG9mDQo+
IHVzaW5nIHNucHJpbnRmLCB1c2Uga2FzcHJpbnRmIGFuZCBhbGxvY2F0ZSBzdHJpbmcgc2l6ZSBh
cyBuZWVkZWQuDQo+IA0KPiBkcml2ZXJzL25ldC9ldGhlcm5ldC9jaXNjby9lbmljL2VuaWNfbWFp
bi5jOiBJbiBmdW5jdGlvbiChZW5pY19vcGVuojoNCj4gZHJpdmVycy9uZXQvZXRoZXJuZXQvY2lz
Y28vZW5pYy9lbmljX21haW4uYzoxNzQwOjE1OiB3YXJuaW5nOiChJXWiIGRpcmVjdGl2ZSBvdXRw
dXQgbWF5IGJlIHRydW5jYXRlZCB3cml0aW5nIGJldHdlZW4gMSBhbmQgMiBieXRlcyBpbnRvIGEg
cmVnaW9uIG9mIHNpemUgYmV0d2VlbiAxIGFuZCAxMiBbLVdmb3JtYXQtdHJ1bmNhdGlvbj1dDQo+
ICAgICAgIiUuMTFzLXJ4LSV1IiwgbmV0ZGV2LT5uYW1lLCBpKTsNCj4gICAgICAgICAgICAgICAg
Xn4NCj4gZHJpdmVycy9uZXQvZXRoZXJuZXQvY2lzY28vZW5pYy9lbmljX21haW4uYzoxNzQwOjU6
IG5vdGU6IGRpcmVjdGl2ZSBhcmd1bWVudCBpbiB0aGUgcmFuZ2UgWzAsIDE2XQ0KPiAgICAgICIl
LjExcy1yeC0ldSIsIG5ldGRldi0+bmFtZSwgaSk7DQo+ICAgICAgXn5+fn5+fn5+fn5+fg0KPiBk
cml2ZXJzL25ldC9ldGhlcm5ldC9jaXNjby9lbmljL2VuaWNfbWFpbi5jOjE3Mzg6NDogbm90ZTog
oXNucHJpbnRmoiBvdXRwdXQgYmV0d2VlbiA2IGFuZCAxOCBieXRlcyBpbnRvIGEgZGVzdGluYXRp
b24gb2Ygc2l6ZSAxNg0KPiAgICAgc25wcmludGYoZW5pYy0+bXNpeFtpbnRyXS5kZXZuYW1lLA0K
PiAgICAgXn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fg0KPiAgICAgIHNpemVvZihl
bmljLT5tc2l4W2ludHJdLmRldm5hbWUpLA0KPiAgICAgIH5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+
fn5+fn5+fn5+fg0KPiAgICAgICIlLjExcy1yeC0ldSIsIG5ldGRldi0+bmFtZSwgaSk7DQo+ICAg
ICAgfn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fg0KPiBkcml2ZXJzL25ldC9ldGhlcm5l
dC9jaXNjby9lbmljL2VuaWNfbWFpbi5jOjE3NTE6NTogd2FybmluZzogoXNucHJpbnRmoiBvdXRw
dXQgbWF5IGJlIHRydW5jYXRlZCBiZWZvcmUgdGhlIGxhc3QgZm9ybWF0IGNoYXJhY3RlciBbLVdm
b3JtYXQtdHJ1bmNhdGlvbj1dDQo+ICAgICAgIiUuMTFzLXR4LSV1IiwgbmV0ZGV2LT5uYW1lLCBp
KTsNCj4gICAgICBefn5+fn5+fn5+fn5+DQo+IA0KPiBhbHNvIGluY3JlbWVudCB0aGUgdmVyc2lv
bi4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEdvdmluZGFyYWp1bHUgVmFyYWRhcmFqYW4gPGd2YXJh
ZGFyQGNpc2NvLmNvbT4NCg0KVXNpbmcgZHluYW1pYyBhbGxvY2F0aW9uIGlzIG92ZXJraWxsIGZv
ciB0aGlzIHByb2JsZW0uDQo=
