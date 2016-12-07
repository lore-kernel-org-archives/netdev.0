From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 07/10] vsock/virtio: add a missing __le annotation
Date: Wed, 7 Dec 2016 12:19:13 +0800
Message-ID: <356375b7-ccf3-d28f-7a53-90fe9f9a508a@redhat.com>
References: <1481038106-24899-1-git-send-email-mst@redhat.com>
	<1481038106-24899-8-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>,
	Stefan Hajnoczi <stefanha@redhat.com>, kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1481038106-24899-8-git-send-email-mst@redhat.com>
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

CgpPbiAyMDE25bm0MTLmnIgwNuaXpSAyMzo0MCwgTWljaGFlbCBTLiBUc2lya2luIHdyb3RlOgo+
IGd1ZXN0IGNpZCBpcyByZWFkIGZyb20gY29uZmlnIHNwYWNlLCB0aGVyZWZvcmUgaXQncyBpbiBs
aXR0bGUgZW5kaWFuCj4gZm9ybWF0IGFuZCBpcyB0cmVhdGVkIGFzIHN1Y2gsIGFubm90YXRlIGl0
IGFjY29yZGluZ2x5Lgo+Cj4gU2lnbmVkLW9mZi1ieTogTWljaGFlbCBTLiBUc2lya2luIDxtc3RA
cmVkaGF0LmNvbT4KPiAtLS0KPiAgIG5ldC92bXdfdnNvY2svdmlydGlvX3RyYW5zcG9ydC5jIHwg
MiArLQo+ICAgMSBmaWxlIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCspLCAxIGRlbGV0aW9uKC0pCj4K
PiBkaWZmIC0tZ2l0IGEvbmV0L3Ztd192c29jay92aXJ0aW9fdHJhbnNwb3J0LmMgYi9uZXQvdm13
X3Zzb2NrL3ZpcnRpb190cmFuc3BvcnQuYwo+IGluZGV4IDkzNmQ3ZWUuLjkwMDk2YjkgMTAwNjQ0
Cj4gLS0tIGEvbmV0L3Ztd192c29jay92aXJ0aW9fdHJhbnNwb3J0LmMKPiArKysgYi9uZXQvdm13
X3Zzb2NrL3ZpcnRpb190cmFuc3BvcnQuYwo+IEBAIC0zMzYsNyArMzM2LDcgQEAgc3RhdGljIHZv
aWQgdmlydGlvX3Zzb2NrX3Jlc2V0X3NvY2soc3RydWN0IHNvY2sgKnNrKQo+ICAgc3RhdGljIHZv
aWQgdmlydGlvX3Zzb2NrX3VwZGF0ZV9ndWVzdF9jaWQoc3RydWN0IHZpcnRpb192c29jayAqdnNv
Y2spCj4gICB7Cj4gICAJc3RydWN0IHZpcnRpb19kZXZpY2UgKnZkZXYgPSB2c29jay0+dmRldjsK
PiAtCXU2NCBndWVzdF9jaWQ7Cj4gKwlfX2xlNjQgZ3Vlc3RfY2lkOwo+ICAgCj4gICAJdmRldi0+
Y29uZmlnLT5nZXQodmRldiwgb2Zmc2V0b2Yoc3RydWN0IHZpcnRpb192c29ja19jb25maWcsIGd1
ZXN0X2NpZCksCj4gICAJCQkgICZndWVzdF9jaWQsIHNpemVvZihndWVzdF9jaWQpKTsKClJldmll
d2VkLWJ5OiBKYXNvbiBXYW5nIDxqYXNvd2FuZ0ByZWRoYXQuY29tPgpfX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpWaXJ0dWFsaXphdGlvbiBtYWlsaW5nIGxp
c3QKVmlydHVhbGl6YXRpb25AbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0
cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vdmlydHVhbGl6YXRpb24=
