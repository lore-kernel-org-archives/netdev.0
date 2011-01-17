From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] vhost-net: use lock_sock_fast() in peek_head_len()
Date: Mon, 17 Jan 2011 10:33:48 +0100
Message-ID: <1295256828.3335.2.camel@edumazet-laptop>
References: <20110117081058.18900.67456.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
	<20110117081117.18900.48672.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: virtualization@lists.osdl.org, mst@redhat.com,
        linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
        netdev@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20110117081117.18900.48672.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

TGUgbHVuZGkgMTcgamFudmllciAyMDExIMOgIDE2OjExICswODAwLCBKYXNvbiBXYW5nIGEgw6lj
cml0IDoKPiBXZSBjYW4gdXNlIGxvY2tfc29ja19mYXN0KCkgaW5zdGVhZCBvZiBsb2NrX3NvY2so
KSBpbiBvcmRlciB0byBnZXQKPiBzcGVlZHVwIGluIHBlZWtfaGVhZF9sZW4oKS4KPiAKPiBTaWdu
ZWQtb2ZmLWJ5OiBKYXNvbiBXYW5nIDxqYXNvd2FuZ0ByZWRoYXQuY29tPgo+IC0tLQo+ICBkcml2
ZXJzL3Zob3N0L25ldC5jIHwgICAgNCArKy0tCj4gIDEgZmlsZXMgY2hhbmdlZCwgMiBpbnNlcnRp
b25zKCspLCAyIGRlbGV0aW9ucygtKQo+IAo+IGRpZmYgLS1naXQgYS9kcml2ZXJzL3Zob3N0L25l
dC5jIGIvZHJpdmVycy92aG9zdC9uZXQuYwo+IGluZGV4IGMzMmEyZTQuLjUwYjYyMmEgMTAwNjQ0
Cj4gLS0tIGEvZHJpdmVycy92aG9zdC9uZXQuYwo+ICsrKyBiL2RyaXZlcnMvdmhvc3QvbmV0LmMK
PiBAQCAtMjExLDEyICsyMTEsMTIgQEAgc3RhdGljIGludCBwZWVrX2hlYWRfbGVuKHN0cnVjdCBz
b2NrICpzaykKPiAgewo+ICAJc3RydWN0IHNrX2J1ZmYgKmhlYWQ7Cj4gIAlpbnQgbGVuID0gMDsK
PiArCWJvb2wgc2xvdyA9IGxvY2tfc29ja19mYXN0KHNrKTsKPiAgCj4gLQlsb2NrX3NvY2soc2sp
Owo+ICAJaGVhZCA9IHNrYl9wZWVrKCZzay0+c2tfcmVjZWl2ZV9xdWV1ZSk7Cj4gIAlpZiAoaGVh
ZCkKPiAgCQlsZW4gPSBoZWFkLT5sZW47Cj4gLQlyZWxlYXNlX3NvY2soc2spOwo+ICsJdW5sb2Nr
X3NvY2tfZmFzdChzaywgc2xvdyk7Cj4gIAlyZXR1cm4gbGVuOwo+ICB9Cj4gIApBY2tlZC1ieTog
RXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPgoKCl9fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fClZpcnR1YWxpemF0aW9uIG1haWxpbmcgbGlz
dApWaXJ0dWFsaXphdGlvbkBsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3Rz
LmxpbnV4LWZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vdmlydHVhbGl6YXRpb24=
