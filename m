From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 08/10] vsock/virtio: mark an internal function static
Date: Thu, 8 Dec 2016 16:25:55 +0200
Message-ID: <20161208162458-mutt-send-email-mst@kernel.org>
References: <1481038106-24899-1-git-send-email-mst@redhat.com>
	<1481038106-24899-9-git-send-email-mst@redhat.com>
	<487d3d4a-7a53-cb45-2cfd-5eb68d9b73f0@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Stefan Hajnoczi <stefanha@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <487d3d4a-7a53-cb45-2cfd-5eb68d9b73f0@redhat.com>
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

T24gV2VkLCBEZWMgMDcsIDIwMTYgYXQgMTI6MjE6MjJQTSArMDgwMCwgSmFzb24gV2FuZyB3cm90
ZToKPiAKPiAKPiBPbiAyMDE25bm0MTLmnIgwNuaXpSAyMzo0MSwgTWljaGFlbCBTLiBUc2lya2lu
IHdyb3RlOgo+ID4gdmlydGlvX3RyYW5zcG9ydF9hbGxvY19wa3QgaXMgb25seSB1c2VkIGxvY2Fs
bHksIG1ha2UgaXQgc3RhdGljLgo+ID4gCj4gPiBTaWduZWQtb2ZmLWJ5OiBNaWNoYWVsIFMuIFRz
aXJraW4gPG1zdEByZWRoYXQuY29tPgo+ID4gLS0tCj4gPiAgIG5ldC92bXdfdnNvY2svdmlydGlv
X3RyYW5zcG9ydF9jb21tb24uYyB8IDIgKy0KPiA+ICAgMSBmaWxlIGNoYW5nZWQsIDEgaW5zZXJ0
aW9uKCspLCAxIGRlbGV0aW9uKC0pCj4gPiAKPiA+IGRpZmYgLS1naXQgYS9uZXQvdm13X3Zzb2Nr
L3ZpcnRpb190cmFuc3BvcnRfY29tbW9uLmMgYi9uZXQvdm13X3Zzb2NrL3ZpcnRpb190cmFuc3Bv
cnRfY29tbW9uLmMKPiA+IGluZGV4IGE1M2IzYTEuLjYxMjAzODQgMTAwNjQ0Cj4gPiAtLS0gYS9u
ZXQvdm13X3Zzb2NrL3ZpcnRpb190cmFuc3BvcnRfY29tbW9uLmMKPiA+ICsrKyBiL25ldC92bXdf
dnNvY2svdmlydGlvX3RyYW5zcG9ydF9jb21tb24uYwo+ID4gQEAgLTMyLDcgKzMyLDcgQEAgc3Rh
dGljIGNvbnN0IHN0cnVjdCB2aXJ0aW9fdHJhbnNwb3J0ICp2aXJ0aW9fdHJhbnNwb3J0X2dldF9v
cHModm9pZCkKPiA+ICAgCXJldHVybiBjb250YWluZXJfb2YodCwgc3RydWN0IHZpcnRpb190cmFu
c3BvcnQsIHRyYW5zcG9ydCk7Cj4gPiAgIH0KPiA+IC1zdHJ1Y3QgdmlydGlvX3Zzb2NrX3BrdCAq
Cj4gPiArc3RhdGljIHN0cnVjdCB2aXJ0aW9fdnNvY2tfcGt0ICoKPiA+ICAgdmlydGlvX3RyYW5z
cG9ydF9hbGxvY19wa3Qoc3RydWN0IHZpcnRpb192c29ja19wa3RfaW5mbyAqaW5mbywKPiA+ICAg
CQkJICAgc2l6ZV90IGxlbiwKPiA+ICAgCQkJICAgdTMyIHNyY19jaWQsCj4gCj4gR2l0IGdyZXAg
c2hvd3MgaXQgd2FzIHVzZWQgYnkgdHJhY2luZy4KClRydWUgYnV0IHRyYWNlX3ZpcnRpb190cmFu
c3BvcnRfYWxsb2NfcGt0IGlzIGFsc28gbG9jYWwgdG8KdmlydGlvX3RyYW5zcG9ydF9jb21tb24u
YwoKLS0gCk1TVApfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
XwpWaXJ0dWFsaXphdGlvbiBtYWlsaW5nIGxpc3QKVmlydHVhbGl6YXRpb25AbGlzdHMubGludXgt
Zm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4v
bGlzdGluZm8vdmlydHVhbGl6YXRpb24=
