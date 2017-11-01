From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [PATCH] tcp_nv: fix division by zero in tcpnv_acked()
Date: Wed, 1 Nov 2017 13:47:17 +0000
Message-ID: <5FF5EDEE-FF34-43E0-9DFA-6CBDB206360D@fb.com>
References: <150954313588.153848.10192893966808917578.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <150954313588.153848.10192893966808917578.stgit@buzz>
Content-Language: en-US
Content-ID: <85C36806C43CA144A375021662C5F18F@namprd15.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

VGhhbmsgeW91IGZvciBmaW5kaW5nIGFuZCBmaXhpbmcgdGhpcy4NCg0KT24gMTEvMS8xNywgNjoz
MiBBTSwgIktvbnN0YW50aW4gS2hsZWJuaWtvdiIgPGtobGVibmlrb3ZAeWFuZGV4LXRlYW0ucnU+
IHdyb3RlOg0KDQogICAgQXZlcmFnZSBSVFQgY291bGQgYmVjb21lIHplcm8uIFRoaXMgaGFwcGVu
ZWQgaW4gcmVhbCBsaWZlIGF0IGxlYXN0IHR3aWNlLg0KICAgIFRoaXMgcGF0Y2ggdHJlYXRzIHpl
cm8gYXMgMXVzLg0KICAgIA0KICAgIFNpZ25lZC1vZmYtYnk6IEtvbnN0YW50aW4gS2hsZWJuaWtv
diBraGxlYm5pa292QHlhbmRleC10ZWFtLnJ1DQpBY2tlZC1ieTogTGF3cmVuY2UgQnJha21vIDxC
cmFrbW9AZmIuY29tPg0KICAgIC0tLQ0KICAgICBuZXQvaXB2NC90Y3BfbnYuYyB8ICAgIDIgKy0N
CiAgICAgMSBmaWxlIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCspLCAxIGRlbGV0aW9uKC0pDQogICAg
DQogICAgZGlmZiAtLWdpdCBhL25ldC9pcHY0L3RjcF9udi5jIGIvbmV0L2lwdjQvdGNwX252LmMN
CiAgICBpbmRleCAxZmY3Mzk4MmUyOGMuLjEyNWZjMTQ1MGIwMSAxMDA2NDQNCiAgICAtLS0gYS9u
ZXQvaXB2NC90Y3BfbnYuYw0KICAgICsrKyBiL25ldC9pcHY0L3RjcF9udi5jDQogICAgQEAgLTI1
Miw3ICsyNTIsNyBAQCBzdGF0aWMgdm9pZCB0Y3Budl9hY2tlZChzdHJ1Y3Qgc29jayAqc2ssIGNv
bnN0IHN0cnVjdCBhY2tfc2FtcGxlICpzYW1wbGUpDQogICAgIA0KICAgICAJLyogcmF0ZSBpbiAx
MDAncyBiaXRzIHBlciBzZWNvbmQgKi8NCiAgICAgCXJhdGU2NCA9ICgodTY0KXNhbXBsZS0+aW5f
ZmxpZ2h0KSAqIDgwMDAwMDA7DQogICAgLQlyYXRlID0gKHUzMilkaXY2NF91NjQocmF0ZTY0LCAo
dTY0KShhdmdfcnR0ICogMTAwKSk7DQogICAgKwlyYXRlID0gKHUzMilkaXY2NF91NjQocmF0ZTY0
LCAodTY0KShhdmdfcnR0ID86IDEpICogMTAwKTsNCiAgICAgDQogICAgIAkvKiBSZW1lbWJlciB0
aGUgbWF4aW11bSByYXRlIHNlZW4gZHVyaW5nIHRoaXMgUlRUDQogICAgIAkgKiBOb3RlOiBJdCBt
YXkgYmUgbW9yZSB0aGFuIG9uZSBSVFQuIFRoaXMgZnVuY3Rpb24gc2hvdWxkIGJlDQogICAgDQog
ICAgDQoNCg==
