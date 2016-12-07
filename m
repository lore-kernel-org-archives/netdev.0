From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 08/10] vsock/virtio: mark an internal function static
Date: Wed, 7 Dec 2016 12:21:22 +0800
Message-ID: <487d3d4a-7a53-cb45-2cfd-5eb68d9b73f0@redhat.com>
References: <1481038106-24899-1-git-send-email-mst@redhat.com>
	<1481038106-24899-9-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>,
	Stefan Hajnoczi <stefanha@redhat.com>, kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1481038106-24899-9-git-send-email-mst@redhat.com>
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

CgpPbiAyMDE25bm0MTLmnIgwNuaXpSAyMzo0MSwgTWljaGFlbCBTLiBUc2lya2luIHdyb3RlOgo+
IHZpcnRpb190cmFuc3BvcnRfYWxsb2NfcGt0IGlzIG9ubHkgdXNlZCBsb2NhbGx5LCBtYWtlIGl0
IHN0YXRpYy4KPgo+IFNpZ25lZC1vZmYtYnk6IE1pY2hhZWwgUy4gVHNpcmtpbiA8bXN0QHJlZGhh
dC5jb20+Cj4gLS0tCj4gICBuZXQvdm13X3Zzb2NrL3ZpcnRpb190cmFuc3BvcnRfY29tbW9uLmMg
fCAyICstCj4gICAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKyksIDEgZGVsZXRpb24oLSkK
Pgo+IGRpZmYgLS1naXQgYS9uZXQvdm13X3Zzb2NrL3ZpcnRpb190cmFuc3BvcnRfY29tbW9uLmMg
Yi9uZXQvdm13X3Zzb2NrL3ZpcnRpb190cmFuc3BvcnRfY29tbW9uLmMKPiBpbmRleCBhNTNiM2Ex
Li42MTIwMzg0IDEwMDY0NAo+IC0tLSBhL25ldC92bXdfdnNvY2svdmlydGlvX3RyYW5zcG9ydF9j
b21tb24uYwo+ICsrKyBiL25ldC92bXdfdnNvY2svdmlydGlvX3RyYW5zcG9ydF9jb21tb24uYwo+
IEBAIC0zMiw3ICszMiw3IEBAIHN0YXRpYyBjb25zdCBzdHJ1Y3QgdmlydGlvX3RyYW5zcG9ydCAq
dmlydGlvX3RyYW5zcG9ydF9nZXRfb3BzKHZvaWQpCj4gICAJcmV0dXJuIGNvbnRhaW5lcl9vZih0
LCBzdHJ1Y3QgdmlydGlvX3RyYW5zcG9ydCwgdHJhbnNwb3J0KTsKPiAgIH0KPiAgIAo+IC1zdHJ1
Y3QgdmlydGlvX3Zzb2NrX3BrdCAqCj4gK3N0YXRpYyBzdHJ1Y3QgdmlydGlvX3Zzb2NrX3BrdCAq
Cj4gICB2aXJ0aW9fdHJhbnNwb3J0X2FsbG9jX3BrdChzdHJ1Y3QgdmlydGlvX3Zzb2NrX3BrdF9p
bmZvICppbmZvLAo+ICAgCQkJICAgc2l6ZV90IGxlbiwKPiAgIAkJCSAgIHUzMiBzcmNfY2lkLAoK
R2l0IGdyZXAgc2hvd3MgaXQgd2FzIHVzZWQgYnkgdHJhY2luZy4KX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX18KVmlydHVhbGl6YXRpb24gbWFpbGluZyBsaXN0
ClZpcnR1YWxpemF0aW9uQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMu
bGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL3ZpcnR1YWxpemF0aW9u
