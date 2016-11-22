From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [PATCH] net: ioctl SIOCSIFADDR minor cleanup
Date: Tue, 22 Nov 2016 04:30:50 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF0E431D3A@cnshjmbx02>
References: <1479213899-5952-1-git-send-email-cugyly@163.com>
 <20161115.220108.1225196299725031215.davem@davemloft.net>
 <8729016553E3654398EA69218DA29EEF0E42F73A@cnshjmbx02>
 <20161115.223111.734917440131578613.davem@davemloft.net>
 <8729016553E3654398EA69218DA29EEF0E42F7ED@cnshjmbx02>
 <CAM_iQpW0SnpXfN-DjBm-72_23KxtzH8kXbbc3FiQn=VChdX3Ww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
        "cugyly@163.com" <cugyly@163.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:48750 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755024AbcKVEay (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 23:30:54 -0500
In-Reply-To: <CAM_iQpW0SnpXfN-DjBm-72_23KxtzH8kXbbc3FiQn=VChdX3Ww@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SSB0aGluayB0aGVyZSBhcmUgbmV3YmllIGluY2x1ZGUgbWUgc3RpbGwgdXNlIGlmY29uZmlnIHV0
aWxpdHkuIA0KU28gd2hlbiBJIGNoZWNrIHRoaXMgY29kZSwgaXQgY2FuIGJlIG9wdGltaXplZC4N
Cg0KPiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBuZXRkZXYtb3duZXJAdmdl
ci5rZXJuZWwub3JnIFttYWlsdG86bmV0ZGV2LW93bmVyQHZnZXIua2VybmVsLm9yZ10NCj4gT24g
QmVoYWxmIE9mIENvbmcgV2FuZw0KPiBTZW50OiBUdWVzZGF5LCBOb3ZlbWJlciAyMiwgMjAxNiAx
MjoyMCBQTQ0KPiBUbzogWVVBTiBMaW55dQ0KPiBDYzogRGF2aWQgTWlsbGVyOyBjdWd5bHlAMTYz
LmNvbTsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZw0KPiBTdWJqZWN0OiBSZTogW1BBVENIXSBuZXQ6
IGlvY3RsIFNJT0NTSUZBRERSIG1pbm9yIGNsZWFudXANCj4gDQo+IE9uIFR1ZSwgTm92IDE1LCAy
MDE2IGF0IDc6NTcgUE0sIFlVQU4gTGlueXUNCj4gPExpbnl1Lll1YW5AYWxjYXRlbC1zYmVsbC5j
b20uY24+IHdyb3RlOg0KPiA+IE5vLCB0aGlzIHBhdGNoIHdpbGwgbm90IGNoYW5nZSBkZXYtPm5h
bWUsDQo+ID4gSXQncyBjYXJlIGFib3V0IGlmYS0+aWZhX2xhYmVsLg0KPiA+PiAtICAgICAgICAg
ICAgICAgICAgICAgaWYgKGNvbG9uKQ0KPiA+PiAtICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICBtZW1jcHkoaWZhLT5pZmFfbGFiZWwsIGlmci5pZnJfbmFtZSwNCj4gSUZOQU1TSVopOw0KPiA+
PiAtICAgICAgICAgICAgICAgICAgICAgZWxzZQ0KPiA+PiAtICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICBtZW1jcHkoaWZhLT5pZmFfbGFiZWwsIGRldi0+bmFtZSwNCj4gSUZOQU1TSVopOw0K
PiA+IFdoZW4gaWZyLmlmcl9uYW1lIGhhdmUgbm8gY29sb24sIGRldi0+bmFtZSBtdXN0IGVxdWFs
IHRvIGlmci5pZnJfbmFtZS4NCj4gPiBTbyB3ZSBjaGFuZ2UgdG8NCj4gPj4gLSAgICAgICAgICAg
ICAgICAgICAgIGVsc2UNCj4gPj4gLSAgICAgICAgICAgICAgICAgICAgICAgICAgICAgbWVtY3B5
KGlmYS0+aWZhX2xhYmVsLCBpZnIuaWZyX25hbWUsDQo+IElGTkFNU0laKTsNCj4gPiBUaGVuIGlm
IGFuZCBlbHNlIGRvIHNhbWUgdGhpbmcuIEp1c3Qgb25lIGxpbmUgaXMgZW5vdWdoLA0KPiA+IG1l
bWNweShpZmEtPmlmYV9sYWJlbCwgaWZyLmlmcl9uYW1lLCBJRk5BTVNJWik7DQo+ID4NCj4gDQo+
IEkgZG9uJ3QgdW5kZXJzdGFuZCB3aHkgeW91IHRyeSB0byBvcHRpbWl6ZSBhIHNsb3cgcGF0aCBh
bmQgc29tZSBraW5kIG9mDQo+IG9ic29sZXRlIGNvZGUuDQo=
