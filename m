From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH v2] smsc95xx: Use skb_cow_head to deal with cloned skbs
Date: Tue, 18 Apr 2017 22:09:41 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40A477A5@CHN-SV-EXMX02.mchp-main.com>
References: <20170418171706.21190-1-james.hughes@raspberrypi.org>
 <1492541921.10587.135.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>, <steve.glendinning@shawell.net>,
        <UNGLinuxDriver@microchip.com>
To: <eric.dumazet@gmail.com>, <james.hughes@raspberrypi.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa2.microchip.iphmx.com ([68.232.149.84]:16466 "EHLO
        esa2.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753683AbdDRWJn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 18:09:43 -0400
In-Reply-To: <1492541921.10587.135.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IEBAIC0yMDY3LDEzICsyMDY3LDkgQEAgc3RhdGljIHN0cnVjdCBza19idWZmICpzbXNjOTV4
eF90eF9maXh1cChzdHJ1Y3QNCj4gdXNibmV0ICpkZXYsDQo+ID4gIAkvKiBXZSBkbyBub3QgYWR2
ZXJ0aXNlIFNHLCBzbyBza2JzIHNob3VsZCBiZSBhbHJlYWR5IGxpbmVhcml6ZWQgKi8NCj4gPiAg
CUJVR19PTihza2Jfc2hpbmZvKHNrYiktPm5yX2ZyYWdzKTsNCj4gPg0KPiA+IC0JaWYgKHNrYl9o
ZWFkcm9vbShza2IpIDwgb3ZlcmhlYWQpIHsNCj4gPiAtCQlzdHJ1Y3Qgc2tfYnVmZiAqc2tiMiA9
IHNrYl9jb3B5X2V4cGFuZChza2IsDQo+ID4gLQkJCW92ZXJoZWFkLCAwLCBmbGFncyk7DQo+ID4g
LQkJZGV2X2tmcmVlX3NrYl9hbnkoc2tiKTsNCj4gPiAtCQlza2IgPSBza2IyOw0KPiA+IC0JCWlm
ICghc2tiKQ0KPiA+IC0JCQlyZXR1cm4gTlVMTDsNCj4gPiArCS8qIE1ha2Ugd3JpdGFibGUgYW5k
IGV4cGFuZCBoZWFkZXIgc3BhY2UgYnkgb3ZlcmhlYWQgaWYgcmVxdWlyZWQNCj4gKi8NCj4gPiAr
CWlmIChza2JfY293X2hlYWQoc2tiLCBvdmVyaGVhZCkpIHsNCj4gDQo+IEkgYmVsaWV2ZSB5b3Ug
c3RpbGwgbmVlZCB0bw0KPiAJCWRldl9rZnJlZV9za2JfYW55KHNrYik7DQo+IA0KSSB0aGluayBj
YWxsZXIgb2YgdXNibmV0X3N0YXJ0X3htaXQoKSB0YWtlcyBjYXJlIG9mIGZyZWUgd2hlbiByZXR1
cm4gTlVMTC4NCg0KLSBXb29qdW5nDQo=
