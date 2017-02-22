From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] virtio-net: switch to use build_skb() for small
	buffer
Date: Wed, 22 Feb 2017 10:58:08 +0800
Message-ID: <35244d06-2d0d-3f2e-0cd1-43137988c869@redhat.com>
References: <1487666788-9658-1-git-send-email-jasowang@redhat.com>
	<20170221162849-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20170221162849-mutt-send-email-mst@kernel.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

CgpPbiAyMDE35bm0MDLmnIgyMeaXpSAyMjozNywgTWljaGFlbCBTLiBUc2lya2luIHdyb3RlOgo+
IE9uIFR1ZSwgRmViIDIxLCAyMDE3IGF0IDA0OjQ2OjI4UE0gKzA4MDAsIEphc29uIFdhbmcgd3Jv
dGU6Cj4+IFRoaXMgcGF0Y2ggc3dpdGNoIHRvIHVzZSBidWlsZF9za2IoKSBmb3Igc21hbGwgYnVm
ZmVyIHdoaWNoIGNhbiBoYXZlCj4+IGJldHRlciBwZXJmb3JtYW5jZSBmb3IgYm90aCBUQ1AgYW5k
IFhEUCAoc2luY2Ugd2UgY2FuIHdvcmsgYXQgcGFnZQo+PiBiZWZvcmUgc2tiIGNyZWF0aW9uKS4g
SXQgYWxzbyByZW1vdmUgbG90cyBvZiBYRFAgY29kZXMgc2luY2UgYm90aAo+PiBtZXJnZWFibGUg
YW5kIHNtYWxsIGJ1ZmZlciB1c2UgcGFnZSBmcmFnIGR1cmluZyByZWZpbGwgbm93Lgo+Pgo+PiAg
ICAgICAgICAgICAgICAgICAgICAgICBCZWZvcmUgICB8IEFmdGVyCj4+IFhEUF9EUk9QKHhkcDEp
IDY0QiAgOiAgMTEuMU1wcHMgfCAxNC40TXBwcwo+Pgo+PiBUZXN0ZWQgd2l0aCB4ZHAxL3hkcDIv
eGRwX2lwX3R4X3R1bm5lbCBhbmQgbmV0cGVyZi4KPj4KPj4gU2lnbmVkLW9mZi1ieTogSmFzb24g
V2FuZzxqYXNvd2FuZ0ByZWRoYXQuY29tPgo+IFRoYW5rcyEKPiBJIGhhZCBhIHNpbWlsYXIgcGF0
Y2ggZm9yIG1lcmdlYWJsZSB0b28sIHRob3VnaCBpdCdzIHRyaWNraWVyIHRoZXJlCj4gYXMgaG9z
dCBoYXMgYSBsb3Qgb2YgZmxleGliaWxpdHkgaW4gc2l6aW5nIGJ1ZmZlcnMuCj4gTG9va3MgbGlr
ZSBhIGdvb2QgaW50ZXJtZWRpYXRlIHN0ZXAgdG8gbWUuCgpZZXMsIEkgdGhpbmsgaXQncyBtb3Jl
IHRyaWNreSBmb3IgdGhlIGNhc2Ugb2YgbWVyZ2VhYmxlIGJ1ZmZlcjoKCjEpIHdlIG5lZWQgcmVz
ZXJ2ZSBORVRfU0tCX1BBRCArIE5FVF9JUF9BTElHTiBmb3IgZWFjaCBidWZmZXIsIHRoaXMgd2ls
bCAKYnJlYWsgcnggZnJhZyBjb2FsZXNjaW5nCjIpIG5lZWQgdGFpbHJvb20gZm9yIHNrYl9zaGlu
Zm8sIHNvIGl0IHdvbid0IHdvcmsgZm9yIGFsbCBzaXplIG9mIHBhY2tldAoKVGhhbmtzCgo+Cj4K
PiBBY2tlZC1ieTogTWljaGFlbCBTLiBUc2lya2luPG1zdEByZWRoYXQuY29tPgo+CgpfX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpWaXJ0dWFsaXphdGlvbiBt
YWlsaW5nIGxpc3QKVmlydHVhbGl6YXRpb25AbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0
cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vdmlydHVhbGl6
YXRpb24=
