From: Yuval Mintz <yuvalm@mellanox.com>
Subject: RE: [patch net-next 1/7] skbuff: Add the offload_mr_fwd_mark field
Date: Fri, 29 Sep 2017 11:36:53 +0000
Message-ID: <AM0PR0502MB3683CFC85B77523AD883B573BF7E0@AM0PR0502MB3683.eurprd05.prod.outlook.com>
References: <20170928173415.15551-1-jiri@resnulli.us>
         <20170928173415.15551-2-jiri@resnulli.us>
 <1506683686.2980.44.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        Yotam Gigi <yotamg@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>, mlxsw <mlxsw@mellanox.com>,
        "nikolay@cumulusnetworks.com" <nikolay@cumulusnetworks.com>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "dsa@cumulusnetworks.com" <dsa@cumulusnetworks.com>,
        "edumazet@google.com" <edumazet@google.com>,
        "willemb@google.com" <willemb@google.com>,
        "johannes.berg@intel.com" <johannes.berg@intel.com>,
        "pabeni@redhat.com" <pabeni@redhat.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "fw@strlen.de" <fw@strlen.de>,
        "gfree.wind@vip.163.com" <gfree.wind@vip.163.com>
To: Davide Caratti <dcaratti@redhat.com>,
        Jiri Pirko <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0064.outbound.protection.outlook.com ([104.47.0.64]:46673
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751667AbdI2LhB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 07:37:01 -0400
In-Reply-To: <1506683686.2980.44.camel@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBoZWxsbyBKaXJpIGFuZCBZb3RhbSwNCj4gDQo+IE9uIFRodSwgMjAxNy0wOS0yOCBhdCAxOToz
NCArMDIwMCwgSmlyaSBQaXJrbyB3cm90ZToNCj4gPiBGcm9tOiBZb3RhbSBHaWdpIDx5b3RhbWdA
bWVsbGFub3guY29tPg0KPiA+DQo+ID4gZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvc2tidWZm
LmggYi9pbmNsdWRlL2xpbnV4L3NrYnVmZi5oDQo+ID4gaW5kZXggMTllNjRiZi4uYWRhODIxNCAx
MDA2NDQNCj4gPiAtLS0gYS9pbmNsdWRlL2xpbnV4L3NrYnVmZi5oDQo+ID4gKysrIGIvaW5jbHVk
ZS9saW51eC9za2J1ZmYuaA0KPiA+IEBAIC03NzIsNiArNzcyLDcgQEAgc3RydWN0IHNrX2J1ZmYg
ew0KPiA+ICAJX191OAkJCXJlbWNzdW1fb2ZmbG9hZDoxOw0KPiA+ICAjaWZkZWYgQ09ORklHX05F
VF9TV0lUQ0hERVYNCj4gPiAgCV9fdTgJCQlvZmZsb2FkX2Z3ZF9tYXJrOjE7DQo+ID4gKwlfX3U4
CQkJb2ZmbG9hZF9tcl9md2RfbWFyazoxOw0KPiANCj4gSSBoYWQgYSBsb29rIGF0IHRoZSBwYWhv
bGUgb3V0cHV0Og0KPiANCj4gJCBtYWtlIGFsbHllc2NvbmZpZw0KPiAkIG1ha2UgbmV0L2NvcmUv
c2tidWZmLm8NCj4gJCBwYWhvbGUgbmV0L2NvcmUvc2tidWZmLm8gfCBncmVwIC1DNyB0Y19mcm9t
X2luZ3Jlc3MNCj4gDQo+IA0KPiAgICAgICAgIF9fdTggICAgICAgICAgICAgICAgICAgICAgIGlw
dnNfcHJvcGVydHk6MTsgICAgICAvKiAgIDE0NzogNyAgMSAqLw0KPiAgICAgICAgIF9fdTggICAg
ICAgICAgICAgICAgICAgICAgIGlubmVyX3Byb3RvY29sX3R5cGU6MTsgLyogICAxNDc6IDYgIDEg
Ki8NCj4gICAgICAgICBfX3U4ICAgICAgICAgICAgICAgICAgICAgICByZW1jc3VtX29mZmxvYWQ6
MTsgICAgLyogICAxNDc6IDUgIDEgKi8NCj4gICAgICAgICBfX3U4ICAgICAgICAgICAgICAgICAg
ICAgICBvZmZsb2FkX2Z3ZF9tYXJrOjE7ICAgLyogICAxNDc6IDQgIDEgKi8NCj4gICAgICAgICBf
X3U4ICAgICAgICAgICAgICAgICAgICAgICB0Y19za2lwX2NsYXNzaWZ5OjE7ICAgLyogICAxNDc6
IDMgIDEgKi8NCj4gICAgICAgICBfX3U4ICAgICAgICAgICAgICAgICAgICAgICB0Y19hdF9pbmdy
ZXNzOjE7ICAgICAgLyogICAxNDc6IDIgIDEgKi8NCj4gICAgICAgICBfX3U4ICAgICAgICAgICAg
ICAgICAgICAgICB0Y19yZWRpcmVjdGVkOjE7ICAgICAgLyogICAxNDc6IDEgIDEgKi8NCj4gICAg
ICAgICBfX3U4ICAgICAgICAgICAgICAgICAgICAgICB0Y19mcm9tX2luZ3Jlc3M6MTsgICAgLyog
ICAxNDc6IDAgIDEgKi8NCj4gICAgICAgICBfX3UxNiAgICAgICAgICAgICAgICAgICAgICB0Y19p
bmRleDsgICAgICAgICAgICAgLyogICAxNDggICAgIDIgKi8NCj4gDQo+ICAgICAgICAgLyogWFhY
IDIgYnl0ZXMgaG9sZSwgdHJ5IHRvIHBhY2sgKi8NCj4gDQo+ICAgICAgICAgdW5pb24gew0KPiAg
ICAgICAgICAgICAgICAgX193c3VtICAgICAgICAgICAgIGNzdW07ICAgICAgICAgICAgICAgICAv
KiAgICAgICAgICAgNCAqLw0KPiAgICAgICAgICAgICAgICAgc3RydWN0IHsNCj4gDQo+IGFwcGFy
ZW50bHkgdGhlcmUgYXJlIG5vIG1vcmUgc3BhcmUgYml0cyB0byB1c2UgYXQgdGhhdCBvZmZzZXQ6
IHRoZXJlZm9yZSwNCj4gYWRkaW5nICdvZmZsb2FkX21yX2Z3ZF9tYXJrJyBiZWZvcmUgJ3RjX3Nr
aXBfY2xhc3NpZnknIHdpbGwgbWFrZQ0KPiAndGNfZnJvbV9pbmdyZXNzJyBzbGlwIGF0IG9mZnNl
dCAxNDgsIGFuZCB0Y19pbmRleCBhdCBvZmZzZXQgMTUwLg0KPiBJIHRoaW5rIHlvdSBjYW4gdXNl
IHRoYXQgMi1ieXRlcyBob2xlIGJlbG93IHRjX2luZGV4LCBhbmQgYWxzbyBtb3ZlIHRoZQ0KPiBv
ZmZsb2FkX2Z3ZF9tYXJrIGJpdCB0aGVyZSwgYXMgd2UgdXNlIGJvdGggd2hlbg0KPiBDT05GSUdf
TkVUX1NXSVRDSERFViBpcw0KPiBlbmFibGVkLiBUaGlzIHdheSB3ZSB3aWxsIGFsc28gZ2FpbiBv
bmUgc3BhcmUgYml0LCB3aXRob3V0IGNoYW5naW5nIHRoZQ0KPiBzdHJ1Y3Qgc2l6ZSBvciB3b3Jz
ZW5pbmcgdGhlIGNhY2hlbGluZSBhbGlnbm1lbnRzLg0KPiANCj4gd2hhdCBkbyB5b3UgdGhpbms/
DQoNCllvdXIgcGFob2xlIG91dHB1dCBzdGlsbCBzaG93cyBhIDJCIGhvbGUgdW50aWwgdGhlIGZv
bGxvd2luZyB1bmlvbg0Kd2hpY2ggaXMgNEItYWxpZ25lZC4NCldoaWxlIGl0J3MgdHJ1ZSB0Y19p
bmRleCBtb3ZlcyB0byBvZmZzZXQgMTUwLCB0aGUgdW5pb24gd2lsbCBub3QgbW92ZSANCltJLmUu
LCBzdGF5IGF0IG9mZnNldCAxNTJdIHNvIHRoZSBsYXlvdXQgZG9lc24ndCByZWFsbHkgY2hhbmdl
IFtncmVhdGx5XQ0Kbm9yIHRoZSBzaXplIG9mIHRoZSBzdHJ1Y3QuIEFuZCB3ZSBoYXZlIHRoZSBi
ZW5lZml0IG9mIGFsbCB0aGUgYml0cw0KcmVtYWluaW5nIGNvbnNlY3V0aXZlLg0KDQo=
