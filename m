From: Ilan Tayari <ilant@mellanox.com>
Subject: RE: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Mon, 29 May 2017 16:05:10 +0000
Message-ID: <AM4PR0501MB194037FF8F17466BC9ECC73DDBF30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
References: <20170523114404.20387-5-saeedm@mellanox.com>
 <20170524165059.42lmrwzzcxvi2sf7@ast-mbp>
 <AM4PR0501MB1940885C2F1CEF4DDE4EA8D1DBFF0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170526030701.du4345mbprhcwjyi@ast-mbp>
 <CALzJLG98D=3yMJV_q4sjVNG41AERFRU+6rwqQJsxnRuVeDTPdA@mail.gmail.com>
 <20170526175624.5xxflpf24je5673h@ast-mbp>
 <20170526181517.GA3860@obsidianresearch.com>
 <AM4PR0501MB1940330F0EBAA819C87C5278DBF20@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170529153131.GB7924@obsidianresearch.com>
 <AM4PR0501MB1940D05A19F098286B99EAD0DBF30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170529160252.GA27550@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        "David S. Miller" <davem@davemloft.net>,
        "Doug Ledford" <dledford@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "jsorensen@fb.com" <jsorensen@fb.com>,
        "Andy Shevchenko" <andy.shevchenko@gmail.com>,
        "linux-fpga@vger.kernel.org" <linux-fpga@vger.kernel.org>,
        Alan Tull <atull@opensource.altera.com>,
        "yi1.li@linux.intel.com" <yi1.li@linux.intel.com>,
        Boris Pismenny <borisp@mellanox.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0089.outbound.protection.outlook.com ([104.47.2.89]:4257
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750811AbdE2QFO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 May 2017 12:05:14 -0400
In-Reply-To: <20170529160252.GA27550@obsidianresearch.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBKYXNvbiBHdW50aG9ycGUgW21h
aWx0bzpqZ3VudGhvcnBlQG9ic2lkaWFucmVzZWFyY2guY29tXQ0KPiBTdWJqZWN0OiBSZTogW2Zv
ci1uZXh0IDQvNl0gbmV0L21seDU6IEZQR0EsIEFkZCBiYXNpYyBzdXBwb3J0IGZvciBJbm5vdmEN
Cj4gDQo+IE9uIE1vbiwgTWF5IDI5LCAyMDE3IGF0IDAzOjU4OjMzUE0gKzAwMDAsIElsYW4gVGF5
YXJpIHdyb3RlOg0KPiA+ID4gRnJvbTogSmFzb24gR3VudGhvcnBlIFttYWlsdG86amd1bnRob3Jw
ZUBvYnNpZGlhbnJlc2VhcmNoLmNvbV0NCj4gPiA+IFN1YmplY3Q6IFJlOiBbZm9yLW5leHQgNC82
XSBuZXQvbWx4NTogRlBHQSwgQWRkIGJhc2ljIHN1cHBvcnQgZm9yDQo+IElubm92YQ0KPiA+ID4N
Cj4gPiA+IE9uIFN1biwgTWF5IDI4LCAyMDE3IGF0IDA3OjIyOjI3QU0gKzAwMDAsIElsYW4gVGF5
YXJpIHdyb3RlOg0KPiA+ID4NCj4gPiA+ID4gVGhpcyBpcyBuZWl0aGVyIFBDSS1iYXIgbWFwcGVk
LCBub3IgbWFpbGJveCBjb21tYW5kLg0KPiA+ID4gPiBUaGUgRlBHQSBpcyBpbmRlZWQgYSBidW1w
LW9uLXRoZS13aXJlLg0KPiA+ID4gPiAoSXQgaGFzIEkyQyB0byB0aGUgQ1g0IGNoaXAsIGJ1dCB0
aGF0IGlzIGZvciBkZWJ1ZyBwdXJwb3NlcywgYW5kIHRvbw0KPiA+ID4gc2xvdw0KPiA+ID4gPiB0
byBwZXJmb3JtIHJlYWwgcHJvZ3JhbW1pbmcpDQo+ID4gPg0KPiA+ID4gV2FpdC4uIFNvIGlmIGl0
IHRydWVseSBoYXMgbm90aGluZyB0byBkbyB3aXRoIHRoZSBleGlzdGluZyBtZWxsYW5veA0KPiA+
ID4gZHJpdmVyLCB0aGVuIG5vdGhpbmcgbW9yZSB0aGFuIHRoZSBmcGdhIGxvYWRlciBzaG91bGQg
YmUgaW4gdGhlIG1seDUNCj4gPiA+IGRpcmVjdG9yeT8NCj4gPg0KPiA+IFRydWUsIGV4Y2VwdCBp
biBzcGVjaWZpYyBjYXNlcyB3aGVuIHRoZSBGUEdBIG1heSBtYW5nbGUgdGhlIHBhY2tldHMgaW4N
Cj4gPiBhIHdheSB0aGF0IHRoZSBuZXRkZXZpY2UgY29uZmlndXJlcywgYW5kIHRoZSBkcml2ZXIg
bmVlZHMgdG8gYWRhcHQgdGhlDQo+ID4gZGF0YSBwYXRoLg0KPiANCj4gPiBTdWNoIGlzIHRoZSBj
YXNlIG9mIElQU2VjIGFuZCBUTFMgb2ZmbG9hZHMuDQo+ID4gVGhvc2UgYXJlIHRpZWQgdG8gdGhl
IG1seDUgRXRoZXJuZXQgZHJpdmVyIChpc29sYXRlZCB3aXRoIGEga2NvbmZpZykuDQo+IA0KPiBC
dXQgdGhlcmUgaXMgbm90aGluZyBzdG9wcGluZyB0aGlzIHNvcnQgb2YgRlBHQSBtYW5nbGluZyBs
b2dpYyBiZWluZw0KPiBkb3duc3RyZWFtIG9mIGFueSBOSUMsIE1lbGxhbm94IGlzIGp1c3QgdGhl
IGZpcnN0IHRvIGRvIHRoaXMuDQo+IA0KPiBJIHRoaW5rIHlvdSdkIGJlIGJldHRlciB0byBhZGQg
c29tZXRoaW5nIHRvIHRoZSBuZXQgc3RhY2sgdG8gbW9kZWwNCj4gdGhpcyBwb3N0LW5pYyBtYW5n
bGluZyBoYXJkd2FyZSwgdGhhbiB0cnlpbmcgdG8gaGlkZSBpdCBpbiBhIGRyaXZlci4NCg0KT2Yg
Y291cnNlLg0KDQpGb3IgSVBTZWMsIHRoaXMgaXMgYWxyZWFkeSBpbiB0aGUga2VybmVsLg0KU2Vl
IHRoaXMgcGF0Y2hzZXQ6DQpodHRwOi8vd3d3Lm1haWwtYXJjaGl2ZS5jb20vbmV0ZGV2QHZnZXIu
a2VybmVsLm9yZy9tc2cxNjI4NzYuaHRtbA0KDQpGb3IgVExTLCBEYXZlIFdhdHNvbiBpcyB3b3Jr
aW5nIHdpdGggb3VyIGd1eXMgdG8gYWRkIGl0Lg0KDQo+IA0KPiBKYXNvbg0K
