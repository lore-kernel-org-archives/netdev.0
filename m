From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Namespaceify tcp_max_orphans knob
Date: Fri, 08 Sep 2017 22:16:48 -0700 (PDT)
Message-ID: <20170908.221648.186026315535806669.davem@davemloft.net>
References: <798CA25A-CA09-4D06-A9B6-7C5791A6EEC1@cmss.chinamobile.com>
        <CAM_iQpVDM0HwZd6c+Loych=nQE__eGteeJQ=XTOfHKgVxMRfrA@mail.gmail.com>
        <E15E5C56-D712-4FEF-9AC5-AE28857D8D27@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: xiyou.wangcong@gmail.com, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org, edumazet@google.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44460 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751048AbdIIFQt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 9 Sep 2017 01:16:49 -0400
In-Reply-To: <E15E5C56-D712-4FEF-9AC5-AE28857D8D27@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTog5Lil5rW35Y+MIDx5YW5oYWlzaHVhbmdAY21zcy5jaGluYW1vYmlsZS5jb20+DQpEYXRl
OiBTYXQsIDkgU2VwIDIwMTcgMTM6MDk6NTcgKzA4MDANCg0KPiANCj4gDQo+PiBPbiAyMDE35bm0
OeaciDnml6UsIGF0IOS4i+WNiDEyOjM1LCBDb25nIFdhbmcgPHhpeW91Lndhbmdjb25nQGdtYWls
LmNvbT4gd3JvdGU6DQo+PiANCj4+IE9uIEZyaSwgU2VwIDgsIDIwMTcgYXQgNjoyNSBQTSwg5Lil
5rW35Y+MIDx5YW5oYWlzaHVhbmdAY21zcy5jaGluYW1vYmlsZS5jb20+IHdyb3RlOg0KPj4+IA0K
Pj4+IA0KPj4+PiBPbiAyMDE35bm0OeaciDnml6UsIGF0IOS4iuWNiDY6MTMsIENvbmcgV2FuZyA8
eGl5b3Uud2FuZ2NvbmdAZ21haWwuY29tPiB3cm90ZToNCj4+Pj4gDQo+Pj4+IE9uIFdlZCwgU2Vw
IDYsIDIwMTcgYXQgODoxMCBQTSwgSGFpc2h1YW5nIFlhbg0KPj4+PiA8eWFuaGFpc2h1YW5nQGNt
c3MuY2hpbmFtb2JpbGUuY29tPiB3cm90ZToNCj4+Pj4+IERpZmZlcmVudCBuYW1lc3BhY2UgYXBw
bGljYXRpb24gbWlnaHQgcmVxdWlyZSBkaWZmZXJlbnQgbWF4aW1hbCBudW1iZXINCj4+Pj4+IG9m
IFRDUCBzb2NrZXRzIGluZGVwZW5kZW50bHkgb2YgdGhlIGhvc3QuDQo+Pj4+IA0KPj4+PiBTbyBh
ZnRlciB5b3VyIHBhdGNoIHdlIGNvdWxkIGhhdmUgTiAqIG5ldC0+aXB2NC5zeXNjdGxfdGNwX21h
eF9vcnBoYW5zDQo+Pj4+IGluIGEgd2hvbGUgc3lzdGVtLCByaWdodD8gVGhpcyBqdXN0IG1ha2Vz
IE9PTSBlYXNpZXIgdG8gdHJpZ2dlci4NCj4+Pj4gDQo+Pj4gDQo+Pj4gRnJvbSBteSB1bmRlcnN0
YW5kaW5nLCBiZWZvcmUgdGhlIHBhdGNoLCB3ZSBoYWQgTiAqIG5ldC0+aXB2NC5zeXNjdGxfdGNw
X21heF9vcnBoYW5zLA0KPj4+IGFuZCBhZnRlciB0aGUgcGF0Y2gsIHdlIGNvdWxkIGhhdmUgbnMx
LnN5c2N0bF90Y3BfbWF4X29ycGhhbnMgKyBuczIuc3lzY3RsX3RjcF9tYXhfb3JwaGFucw0KPj4+
ICsgbnMzLnN5c2N0bF90Y3BfbWF4X29ycGhhbnMsIGlzIHRoYXQgcmlnaHQ/IFRoYW5rcyBmb3Ig
eW91ciByZXZpZXdpbmcuDQo+PiANCj4+IE5vcGUsIGJ5IE4gSSBtZWFuIHRoZSBudW1iZXIgb2Yg
Y29udGFpbmVycy4gQmVmb3JlIHlvdXIgcGF0Y2gsIHRoZSBsaW1pdA0KPj4gaXMgZ2xvYmFsLCBh
ZnRlciB5b3VyIHBhdGNoIGl0IGlzIHBlciBjb250YWluZXIuDQo+PiANCj4gDQo+IFllYWgsIGZv
ciBleGFtcGxlLCBpZiB0aGVyZSBpcyBOIGNvbnRhaW5lcnMsIGJlZm9yZSB0aGUgcGF0Y2gsIEkg
bWVhbiB0aGUgbGltaXQgaXM6DQo+IA0KPiAJTiAqIG5ldC0+aXB2NC5zeXNjdGxfdGNwX21heF9v
cnBoYW5zDQo+IA0KPiBBZnRlciB0aGUgcGF0Y2gsIHRoZSBsaW1pdCBpczoNCj4gDQo+IAluczEu
IG5ldC0+aXB2NC5zeXNjdGxfdGNwX21heF9vcnBoYW5zICsgbnMyLiBuZXQtPmlwdjQuc3lzY3Rs
X3RjcF9tYXhfb3JwaGFucyArIOKApg0KDQpOb3QgdHJ1ZS4NCg0KUGxlYXNlIHJlbW92ZSAiTiIg
ZnJvbSB5b3VyIGVxdWF0aW9uIG9mIHRoZSBjdXJyZW50IHNpdHVhdGlvbi4NCg0KInN5c2N0bF90
Y3BfbWF4X29ycGhhbnMiIGFwcGxpZXMgdG8gZW50aXJlIHN5c3RlbSwgaXQgaXMgYSBnbG9iYWwg
bGltaXQsDQpjb21wYXJpbmcgb25lIGxpbWl0IGFnYWluc3QgYWxsIG9ycGhhbnMgaW4gdGhlIHN5
c3RlbSwgdGhlcmUgaXMgbm8gTi4NCg==
