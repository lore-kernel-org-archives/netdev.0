From: Teng Qin <qinteng@fb.com>
Subject: Re: [PATCH net-next] bpf: update perf event helper function signature
 and documentation
Date: Tue, 23 May 2017 03:17:31 +0000
Message-ID: <BB53B290-EED3-4B92-8D2D-33954D7B6C68@fb.com>
References: <E796EF36-C195-4FFA-AAA0-A1F9E7730349@fb.com>
 <20170522.230849.1056416550811494880.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "peterz@infradead.org" <peterz@infradead.org>,
        "bgregg@netflix.com" <bgregg@netflix.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>,
        Alexei Starovoitov <ast@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170522.230849.1056416550811494880.davem@davemloft.net>
Content-Language: en-US
Content-ID: <D599AF1D2857AF4EA83A370C9999048E@namprd15.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DQoNCk9uIDUvMjIvMTcsIDIwOjA4LCAiRGF2aWQgTWlsbGVyIiA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5l
dD4gd3JvdGU6DQoNCiAgICBGcm9tOiBUZW5nIFFpbiA8cWludGVuZ0BmYi5jb20+DQogICAgRGF0
ZTogVHVlLCAyMyBNYXkgMjAxNyAwMDozOTozNCArMDAwMA0KICAgIA0KICAgID4gZGlmZiAtLWdp
dCBhL3NhbXBsZXMvYnBmL2JwZl9oZWxwZXJzLmggYi9zYW1wbGVzL2JwZi9icGZfaGVscGVycy5o
DQogICAgPiBpbmRleCA5YTljOTVmLi5hOTRjZTQyIDEwMDY0NA0KICAgID4gLS0tIGEvc2FtcGxl
cy9icGYvYnBmX2hlbHBlcnMuaA0KICAgID4gKysrIGIvc2FtcGxlcy9icGYvYnBmX2hlbHBlcnMu
aA0KICAgID4gQEAgLTM3LDkgKzM3LDggQEAgc3RhdGljIGludCAoKmJwZl9jbG9uZV9yZWRpcmVj
dCkodm9pZCAqY3R4LCBpbnQgaWZpbmRleCwgaW50IGZsYWdzKSA9DQogICAgPiAgCSh2b2lkICop
IEJQRl9GVU5DX2Nsb25lX3JlZGlyZWN0Ow0KICAgID4gIHN0YXRpYyBpbnQgKCpicGZfcmVkaXJl
Y3QpKGludCBpZmluZGV4LCBpbnQgZmxhZ3MpID0NCiAgICA+ICAJKHZvaWQgKikgQlBGX0ZVTkNf
cmVkaXJlY3Q7DQogICAgPiAtc3RhdGljIGludCAoKmJwZl9wZXJmX2V2ZW50X291dHB1dCkodm9p
ZCAqY3R4LCB2b2lkICptYXAsDQogICAgPiAtCQkJCSAgICB1bnNpZ25lZCBsb25nIGxvbmcgZmxh
Z3MsIHZvaWQgKmRhdGEsDQogICAgPiAtCQkJCSAgICBpbnQgc2l6ZSkgPQ0KICAgID4gK3N0YXRp
YyBpbnQgKCpicGZfcGVyZl9ldmVudF9vdXRwdXQpKHZvaWQgKmN0eCwgdm9pZCAqbWFwLCB1NjQg
ZmxhZ3MsDQogICAgPiArCSAgICAgICAgICAgICAgICAgICAgICAgICAgICB2b2lkICpkYXRhLCBp
bnQgc2l6ZSkgPQ0KICAgID4gIAkodm9pZCAqKSBCUEZfRlVOQ19wZXJmX2V2ZW50X291dHB1dDsN
CiAgICA+ICBzdGF0aWMgaW50ICgqYnBmX2dldF9zdGFja2lkKSh2b2lkICpjdHgsIHZvaWQgKm1h
cCwgaW50IGZsYWdzKSA9DQogICAgPiAgCSh2b2lkICopIEJQRl9GVU5DX2dldF9zdGFja2lkOw0K
ICAgIA0KICAgIEkgdGhpbmsgd2UndmUgYmVlbiBpbnRlbnRpb25hbGx5IGF2b2lkaW5nIHRoZSB1
c2Ugb2YgInU2NCIsICJ1MzIiLA0KICAgIGV0Yy4gaW4gdGhpcyBmaWxlLg0KICAgIA0KICAgIEJ1
dCB3aGF0IGRvIEkga25vdy4NCg0KQWxleGVpIHNhaWQgaXQgd2FzIGR1ZSB0byBDbGFuZyBub3Qg
dGFraW5nIHU2NCwgdTMyIGV0Yy4gZm9yIGNvbXBpbGF0aW9uLg0KSSBkaWRu4oCZdCBrbm93IHRo
ZSBjb250ZXh0IGFuZCBqdXN0IHVzZWQgdGhlbS4gQnV0IGFwcGFyZW50bHksIHNvbWV0aGluZw0K
Y2hhbmdlZCBhbmQgbm93IHRoZXkgYnVpbGQgYW5kIHJ1biBPSy4uLi4uLg0KDQo=
