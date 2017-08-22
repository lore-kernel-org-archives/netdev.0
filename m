From: Koichiro Den <den@klaipeden.com>
Subject: Re: [PATCH 1/2] vhost: remove the possible fruitless search on
	iotlb prefetch
Date: Tue, 22 Aug 2017 23:09:44 +0900
Message-ID: <1503410984.8694.15.camel@klaipeden.com>
References: <20170819064114.27219-1-den@klaipeden.com>
	<20170821223039-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20170821223039-mutt-send-email-mst@kernel.org>
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

T24gTW9uLCAyMDE3LTA4LTIxIGF0IDIyOjQ1ICswMzAwLCBNaWNoYWVsIFMuIFRzaXJraW4gd3Jv
dGU6Cj4gT24gU2F0LCBBdWcgMTksIDIwMTcgYXQgMDM6NDE6MTRQTSArMDkwMCwgS29pY2hpcm8g
RGVuIHdyb3RlOgo+ID4gU2lnbmVkLW9mZi1ieTogS29pY2hpcm8gRGVuIDxkZW5Aa2xhaXBlZGVu
LmNvbT4KPiA+IC0tLQo+ID4gwqBkcml2ZXJzL3Zob3N0L3Zob3N0LmMgfCAyICstCj4gPiDCoDEg
ZmlsZSBjaGFuZ2VkLCAxIGluc2VydGlvbigrKSwgMSBkZWxldGlvbigtKQo+ID4gCj4gPiBkaWZm
IC0tZ2l0IGEvZHJpdmVycy92aG9zdC92aG9zdC5jIGIvZHJpdmVycy92aG9zdC92aG9zdC5jCj4g
PiBpbmRleCBlNDYxM2EzYzM2MmQuLjkzZTkwOWFmYzFjMyAxMDA2NDQKPiA+IC0tLSBhL2RyaXZl
cnMvdmhvc3Qvdmhvc3QuYwo+ID4gKysrIGIvZHJpdmVycy92aG9zdC92aG9zdC5jCj4gPiBAQCAt
MTE4NCw3ICsxMTg0LDcgQEAgc3RhdGljIGludCBpb3RsYl9hY2Nlc3Nfb2soc3RydWN0IHZob3N0
X3ZpcnRxdWV1ZSAqdnEsCj4gPiDCoAl3aGlsZSAobGVuID4gcykgewo+ID4gwqAJCW5vZGUgPSB2
aG9zdF91bWVtX2ludGVydmFsX3RyZWVfaXRlcl9maXJzdCgmdW1lbS0KPiA+ID51bWVtX3RyZWUs
Cj4gPiDCoAkJCQkJCQnCoMKgwqBhZGRyLAo+ID4gLQkJCQkJCQnCoMKgwqBhZGRyICsgbGVuIC0g
MSk7Cj4gPiArCQkJCQkJCcKgwqDCoGFkZHIgKyBsZW4gLSBzIC0KPiA+IDEpOwo+ID4gwqAJCWlm
IChub2RlID09IE5VTEwgfHwgbm9kZS0+c3RhcnQgPiBhZGRyKSB7Cj4gPiDCoAkJCXZob3N0X2lv
dGxiX21pc3ModnEsIGFkZHIsIGFjY2Vzcyk7Cj4gPiDCoAkJCXJldHVybiBmYWxzZTsKPiAKPiBU
aGlzIHdvcmtzIGJ1dCBpdCBwcm9iYWJseSBtYWtlcyBzZW5zZSB0byBqdXN0IHJlZmFjdG9yIHRo
ZSBjb2RlIHRvIG1ha2UgZW5kCj4gb2YKPiByYW5nZSBhIHZhcmlhYmxlLiBJIHBvc3RlZCBhIHBh
dGNoIGxpa2UgdGhpcywgcGxzIHRha2UgYSBsb29rLgo+IAo+ID4gLS3CoAo+ID4gMi45LjQKPiA+
IApPaywgdGhhbmtzLgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX18KVmlydHVhbGl6YXRpb24gbWFpbGluZyBsaXN0ClZpcnR1YWxpemF0aW9uQGxpc3RzLmxp
bnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWls
bWFuL2xpc3RpbmZvL3ZpcnR1YWxpemF0aW9u
