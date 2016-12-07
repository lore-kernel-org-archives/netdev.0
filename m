From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 05/10] vhost: make interval tree static inline
Date: Wed, 7 Dec 2016 12:16:06 +0800
Message-ID: <3a862cdc-cd02-98f2-fc9a-7bc0f99a0ba3@redhat.com>
References: <1481038106-24899-1-git-send-email-mst@redhat.com>
	<1481038106-24899-6-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1481038106-24899-6-git-send-email-mst@redhat.com>
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
IHZob3N0X3VtZW1faW50ZXJ2YWxfdHJlZSBpcyBvbmx5IHVzZWQgbG9jYWxseSB3aXRoaW4gdmhv
c3QuYywgbWFyayBpdAo+IHN0YXRpYy4gQXMgc29tZSBmdW5jdGlvbnMgZ2VuZXJhdGVkIGdvIHVu
dXNlZCwgdGhpcyB0cmlnZ2VycyB3YXJuaW5ncwo+IHVubGVzcyB3ZSBhbHNvIG1hcmsgaXQgaW5s
aW5lLgo+Cj4gU2lnbmVkLW9mZi1ieTogTWljaGFlbCBTLiBUc2lya2luIDxtc3RAcmVkaGF0LmNv
bT4KPiAtLS0KPiAgIGRyaXZlcnMvdmhvc3Qvdmhvc3QuYyB8IDIgKy0KPiAgIDEgZmlsZSBjaGFu
Z2VkLCAxIGluc2VydGlvbigrKSwgMSBkZWxldGlvbigtKQo+Cj4gZGlmZiAtLWdpdCBhL2RyaXZl
cnMvdmhvc3Qvdmhvc3QuYyBiL2RyaXZlcnMvdmhvc3Qvdmhvc3QuYwo+IGluZGV4IGM2ZjJkODku
LjczMzFlZjMgMTAwNjQ0Cj4gLS0tIGEvZHJpdmVycy92aG9zdC92aG9zdC5jCj4gKysrIGIvZHJp
dmVycy92aG9zdC92aG9zdC5jCj4gQEAgLTQ5LDcgKzQ5LDcgQEAgZW51bSB7Cj4gICAKPiAgIElO
VEVSVkFMX1RSRUVfREVGSU5FKHN0cnVjdCB2aG9zdF91bWVtX25vZGUsCj4gICAJCSAgICAgcmIs
IF9fdTY0LCBfX3N1YnRyZWVfbGFzdCwKPiAtCQkgICAgIFNUQVJULCBMQVNULCAsIHZob3N0X3Vt
ZW1faW50ZXJ2YWxfdHJlZSk7Cj4gKwkJICAgICBTVEFSVCwgTEFTVCwgc3RhdGljIGlubGluZSwg
dmhvc3RfdW1lbV9pbnRlcnZhbF90cmVlKTsKPiAgIAo+ICAgI2lmZGVmIENPTkZJR19WSE9TVF9D
Uk9TU19FTkRJQU5fTEVHQUNZCj4gICBzdGF0aWMgdm9pZCB2aG9zdF9kaXNhYmxlX2Nyb3NzX2Vu
ZGlhbihzdHJ1Y3Qgdmhvc3RfdmlydHF1ZXVlICp2cSkKClJldmlld2VkLWJ5OiBKYXNvbiBXYW5n
IDxqYXNvd2FuZ0ByZWRoYXQuY29tPgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fXwpWaXJ0dWFsaXphdGlvbiBtYWlsaW5nIGxpc3QKVmlydHVhbGl6YXRpb25A
bGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24u
b3JnL21haWxtYW4vbGlzdGluZm8vdmlydHVhbGl6YXRpb24=
