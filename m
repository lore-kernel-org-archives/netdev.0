From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH 2/2] bpf: Initialise mod[] in bpf_trace_printk
Date: Mon, 14 Aug 2017 12:44:35 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0054C88@AcuExch.aculab.com>
References: <59897A7C.10009@iogearbox.net>
 <20170808.094857.245786887664041622.davem@davemloft.net>
 <650EB3B0-1101-4624-905A-E68D2EC5920F@imgtec.com>
 <20170808.145433.1287676484744976417.davem@davemloft.net>
 <20170809073926.GO6973@jhogan-linux.le.imgtec.org>
 <598B71C9.7090303@iogearbox.net> <598DDF88.6020809@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "ast@kernel.org" <ast@kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "rostedt@goodmis.org" <rostedt@goodmis.org>,
        "mingo@redhat.com" <mingo@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Daniel Borkmann' <daniel@iogearbox.net>,
        James Hogan <james.hogan@imgtec.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <598DDF88.6020809@iogearbox.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogRGFuaWVsIEJvcmttYW5uDQo+IFNlbnQ6IDExIEF1Z3VzdCAyMDE3IDE3OjQ3DQo+IE9u
IDA4LzA5LzIwMTcgMTA6MzQgUE0sIERhbmllbCBCb3JrbWFubiB3cm90ZToNCj4gPiBPbiAwOC8w
OS8yMDE3IDA5OjM5IEFNLCBKYW1lcyBIb2dhbiB3cm90ZToNCj4gPiBbLi4uXQ0KPiA+PiB0aW1l
IChidXQgcGxlYXNlIGNvbnNpZGVyIGxvb2tpbmcgYXQgdGhlIG90aGVyIHBhdGNoIHdoaWNoIGlz
IGNlcnRhaW5seQ0KPiA+PiBhIG1vcmUgcmVhbCBpc3N1ZSkuDQo+ID4NCj4gPiBTb3JyeSBmb3Ig
dGhlIGRlbGF5LCBzdGFydGVkIGxvb2tpbmcgaW50byB0aGF0IGFuZCB3aGV0aGVyIHdlDQo+ID4g
aGF2ZSBzb21lIG90aGVyIG9wdGlvbnMsIEknbGwgZ2V0IGJhY2sgdG8geW91IG9uIHRoaXMuDQo+
IA0KPiBDb3VsZCB3ZSBzb2x2ZSB0aGlzIG1vcmUgZ2VuZXJpY2FsbHkgKGFzIGluOiBvcmlnaW5h
bGx5IGludGVuZGVkKSBpbg0KPiB0aGUgc2Vuc2UgdGhhdCB3ZSBkb24ndCBuZWVkIHRvIHRydXN0
IHRoZSBnY2MgdmFfbGlzdCBoYW5kbGluZzsgSSBmZWVsDQo+IHRoaXMgaXMgcmVseWluZyBvbiBh
biBpbXBsZW1lbnRhdGlvbiBkZXRhaWw/IFBlcmhhcHMgc29tZXRoaW5nIGxpa2UNCj4gYmVsb3cg
cG9jIHBhdGNoPw0KDQpUaGF0IHBhdGNoIHN0aWxsIGhhcyAnY29uZCA/IGFyZyA6IGNvbmQxID8g
KGxvbmcpYXJnIDogKHUzMilhcmcnIHNvDQpwcm9iYWJseSBoYXMgdGhlIHNhbWUgd2FybmluZyBh
cyB0aGUgb3JpZ2luYWwgdmVyc2lvbi4NCg0KVGhlIHZhX2xpc3QgaGFuZGxpbmcgaXMgZGVmaW5l
ZCBieSB0aGUgcmVsZXZhbnQgQUJJLCBub3QgZ2NjLg0KDQpJdCBpcyBvayBvbiB4ODYtNjQgYmVj
YXVzZSBhbGwgMzJiaXQgdmFsdWVzIGFyZSBleHRlbmRlZCB0byA2NGJpdHMNCmJlZm9yZSBiZWlu
ZyBwYXNzZWQgYXMgYXJndW1lbnRzIChlaXRoZXIgaW4gcmVnaXN0ZXJzLCBvciBvbiB0aGUgc3Rh
Y2spLg0KTm90aGluZyBpbiB0aGUgQyBsYW5ndWFnZSByZXF1aXJlcyB0aGF0LCBzbyBvdGhlciA2
NGJpdCBhcmNoaXRlY3R1cmVzDQpjb3VsZCBwYXNzIDMyYml0IHZhbHVlcyBpbiA0IGJ5dGVzIG9m
IHN0YWNrLg0KDQoJRGF2aWQNCg0KDQo=
