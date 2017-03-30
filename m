From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] virtio_net: don't reset twice on XDP on/off
Date: Thu, 30 Mar 2017 13:39:49 +0800
Message-ID: <8949b5e9-602d-eef0-acdb-9f0f9a5a6f54@redhat.com>
References: <1490818456-6861-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, John Fastabend <john.fastabend@gmail.com>,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1490818456-6861-1-git-send-email-mst@redhat.com>
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

CgpPbiAyMDE35bm0MDPmnIgzMOaXpSAwNDoxNCwgTWljaGFlbCBTLiBUc2lya2luIHdyb3RlOgo+
IFdlIGFscmVhZHkgZG8gYSByZXNldCBvbmNlIGluIHJlbW92ZV92cV9jb21tb24gLQo+IHRoZXJl
IGFwcGVhcnMgdG8gYmUgbm8gcG9pbnQgaW4gZG9pbmcgYW5vdGhlciBvbmUKPiB3aGVuIHdlIGFk
ZC9yZW1vdmUgWERQLgo+Cj4gU2lnbmVkLW9mZi1ieTogTWljaGFlbCBTLiBUc2lya2luIDxtc3RA
cmVkaGF0LmNvbT4KPiAtLS0KPiAgIGRyaXZlcnMvbmV0L3ZpcnRpb19uZXQuYyB8IDEgLQo+ICAg
MSBmaWxlIGNoYW5nZWQsIDEgZGVsZXRpb24oLSkKPgo+IGRpZmYgLS1naXQgYS9kcml2ZXJzL25l
dC92aXJ0aW9fbmV0LmMgYi9kcml2ZXJzL25ldC92aXJ0aW9fbmV0LmMKPiBpbmRleCBkZTQyZTlh
Li5lZDhmNTQ4IDEwMDY0NAo+IC0tLSBhL2RyaXZlcnMvbmV0L3ZpcnRpb19uZXQuYwo+ICsrKyBi
L2RyaXZlcnMvbmV0L3ZpcnRpb19uZXQuYwo+IEBAIC0xODEwLDcgKzE4MTAsNiBAQCBzdGF0aWMg
aW50IHZpcnRuZXRfcmVzZXQoc3RydWN0IHZpcnRuZXRfaW5mbyAqdmksIGludCBjdXJyX3FwLCBp
bnQgeGRwX3FwKQo+ICAgCXZpcnRuZXRfZnJlZXplX2Rvd24oZGV2KTsKPiAgIAlfcmVtb3ZlX3Zx
X2NvbW1vbih2aSk7Cj4gICAKPiAtCWRldi0+Y29uZmlnLT5yZXNldChkZXYpOwo+ICAgCXZpcnRp
b19hZGRfc3RhdHVzKGRldiwgVklSVElPX0NPTkZJR19TX0FDS05PV0xFREdFKTsKPiAgIAl2aXJ0
aW9fYWRkX3N0YXR1cyhkZXYsIFZJUlRJT19DT05GSUdfU19EUklWRVIpOwo+ICAgCgpBY2tlZC1i
eTogSmFzb24gV2FuZyA8amFzb3dhbmdAcmVkaGF0LmNvbT4KX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX18KVmlydHVhbGl6YXRpb24gbWFpbGluZyBsaXN0ClZp
cnR1YWxpemF0aW9uQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGlu
dXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL3ZpcnR1YWxpemF0aW9u
