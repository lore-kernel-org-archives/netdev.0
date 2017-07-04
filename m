From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [PATCH][bpf-next] bpf: add missing break in for the
 TCP_BPF_SNDCWND_CLAMP case
Date: Tue, 4 Jul 2017 18:26:34 +0000
Message-ID: <385C64DB-4BF4-4AC1-B7F0-76AB30969682@fb.com>
References: <20170704152112.18623-1-colin.king@canonical.com>
 <595BB3AF.3000304@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Colin King <colin.king@canonical.com>,
        Alexei Starovoitov <ast@kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <595BB3AF.3000304@iogearbox.net>
Content-Language: en-US
Content-ID: <5FAD45A869CEA3448391CC6ED6BC3521@namprd15.prod.outlook.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DQoNCk9uIDcvNC8xNywgODoyNiBBTSwgIm5ldGRldi1vd25lckB2Z2VyLmtlcm5lbC5vcmcgb24g
YmVoYWxmIG9mIERhbmllbCBCb3JrbWFubiIgPG5ldGRldi1vd25lckB2Z2VyLmtlcm5lbC5vcmcg
b24gYmVoYWxmIG9mIGRhbmllbEBpb2dlYXJib3gubmV0PiB3cm90ZToNCg0KICAgIFsgK0xhd3Jl
bmNlIF0NCiAgICANCiAgICBPbiAwNy8wNC8yMDE3IDA1OjIxIFBNLCBDb2xpbiBLaW5nIHdyb3Rl
Og0KICAgID4gRnJvbTogQ29saW4gSWFuIEtpbmcgPGNvbGluLmtpbmdAY2Fub25pY2FsLmNvbT4N
CiAgICA+DQogICAgPiBUaGVyZSBhcHBlYXJzIHRvIGJlIGEgbWlzc2luZyBicmVhayBpbiB0aGUg
VENQX0JQRl9TTkRDV05EX0NMQU1QIGNhc2UuDQogICAgPiBDdXJyZW50bHkgdGhlIG5vbi1lcnJv
ciBwYXRoIHdoZXJlIHZhbCBpcyBncmVhdGVyIHRoYW4gemVybyBmYWxscyB0aHJvdWdoDQogICAg
PiB0byB0aGUgZGVmYXVsdCBjYXNlIHRoYXQgc2V0cyB0aGUgZXJyb3IgcmV0dXJuIHRvIC1FSU5W
QUwuIEFkZCBpbg0KICAgID4gdGhlIG1pc3NpbmcgYnJlYWsuDQogICAgPg0KICAgID4gRGV0ZWN0
ZWQgYnkgQ292ZXJpdHlTY2FuLCBDSUQjMTQ0OTM3NiAoIk1pc3NpbmcgYnJlYWsgaW4gc3dpdGNo
IikNCiAgICA+DQogICAgPiBGaXhlczogMTNiZjk2NDExYWQyICgiYnBmOiBBZGRzIHN1cHBvcnQg
Zm9yIHNldHRpbmcgc25kY3duZCBjbGFtcCIpDQogICAgPiBTaWduZWQtb2ZmLWJ5OiBDb2xpbiBJ
YW4gS2luZyA8Y29saW4ua2luZ0BjYW5vbmljYWwuY29tPg0KICAgIA0KICAgIEFja2VkLWJ5OiBE
YW5pZWwgQm9ya21hbm4gZGFuaWVsQGlvZ2VhcmJveC5uZXQNCkFja2VkLWJ5OiBMYXdyZW5jZSBC
cmFrbW8gPGJyYWttb0BmYi5jb20+DQogICAgDQogICAgPiAtLS0NCiAgICA+ICAgbmV0L2NvcmUv
ZmlsdGVyLmMgfCAxICsNCiAgICA+ICAgMSBmaWxlIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCspDQog
ICAgPg0KICAgID4gZGlmZiAtLWdpdCBhL25ldC9jb3JlL2ZpbHRlci5jIGIvbmV0L2NvcmUvZmls
dGVyLmMNCiAgICA+IGluZGV4IDk0MTY5NTcyZDAwMi4uYzdmNzM3MDU4ZDg5IDEwMDY0NA0KICAg
ID4gLS0tIGEvbmV0L2NvcmUvZmlsdGVyLmMNCiAgICA+ICsrKyBiL25ldC9jb3JlL2ZpbHRlci5j
DQogICAgPiBAQCAtMjg2Nyw2ICsyODY3LDcgQEAgQlBGX0NBTExfNShicGZfc2V0c29ja29wdCwg
c3RydWN0IGJwZl9zb2NrX29wc19rZXJuICosIGJwZl9zb2NrLA0KICAgID4gICAJCQkJCXRwLT5z
bmRfY3duZF9jbGFtcCA9IHZhbDsNCiAgICA+ICAgCQkJCQl0cC0+c25kX3NzdGhyZXNoID0gdmFs
Ow0KICAgID4gICAJCQkJfQ0KICAgID4gKwkJCQlicmVhazsNCiAgICA+ICAgCQkJZGVmYXVsdDoN
CiAgICA+ICAgCQkJCXJldCA9IC1FSU5WQUw7DQogICAgPiAgIAkJCX0NCiAgICA+DQogICAgDQog
ICAgDQoNCg==
