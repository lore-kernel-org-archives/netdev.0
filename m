From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next v2 2/5] virtio-net: transmit napi
Date: Thu, 20 Apr 2017 14:27:03 +0800
Message-ID: <2ae5889b-69d4-3041-d7fd-a7ea38e8c4e2@redhat.com>
References: <20170418202108.61920-1-willemdebruijn.kernel@gmail.com>
	<20170418202108.61920-3-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: Willem de Bruijn <willemb@google.com>,
	virtualization@lists.linux-foundation.org, davem@davemloft.net,
	mst@redhat.com
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>, netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20170418202108.61920-3-willemdebruijn.kernel@gmail.com>
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

CgpPbiAyMDE35bm0MDTmnIgxOeaXpSAwNDoyMSwgV2lsbGVtIGRlIEJydWlqbiB3cm90ZToKPiAr
c3RhdGljIHZvaWQgdmlydG5ldF9uYXBpX3R4X2VuYWJsZShzdHJ1Y3QgdmlydG5ldF9pbmZvICp2
aSwKPiArCQkJCSAgIHN0cnVjdCB2aXJ0cXVldWUgKnZxLAo+ICsJCQkJICAgc3RydWN0IG5hcGlf
c3RydWN0ICpuYXBpKQo+ICt7Cj4gKwlpZiAoIW5hcGktPndlaWdodCkKPiArCQlyZXR1cm47Cj4g
Kwo+ICsJaWYgKCF2aS0+YWZmaW5pdHlfaGludF9zZXQpIHsKPiArCQluYXBpLT53ZWlnaHQgPSAw
Owo+ICsJCXJldHVybjsKPiArCX0KPiArCj4gKwlyZXR1cm4gdmlydG5ldF9uYXBpX2VuYWJsZSh2
cSwgbmFwaSk7Cj4gK30KPiArCj4gICBzdGF0aWMgdm9pZCByZWZpbGxfd29yayhzdHJ1Y3Qgd29y
a19zdHJ1Y3QgKndvcmspCgpNYXliZSBJIHdhcyB3cm9uZywgYnV0IGFjY29yZGluZyB0byBNaWNo
YWVsJ3MgY29tbWVudCBpdCBsb29rcyBsaWtlIGhlIAp3YW50IGNoZWNrIGFmZmluaXR5X2hpbnRf
c2V0IGp1c3QgZm9yIHNwZWN1bGF0aXZlIHR4IHBvbGxpbmcgb24gcnggbmFwaSAKaW5zdGVhZCBv
ZiBkaXNhYmxpbmcgaXQgYXQgYWxsLgoKQW5kIEknbSBub3QgY29udmluY2VkIHRoaXMgaXMgcmVh
bGx5IG5lZWRlZCwgZHJpdmVyIG9ubHkgcHJvdmlkZSAKYWZmaW5pdHkgaGludCBpbnN0ZWFkIG9m
IGFmZmluaXR5LCBzbyBpdCdzIG5vdCBndWFyYW50ZWVkIHRoYXQgdHggYW5kIHJ4IAppbnRlcnJ1
cHQgYXJlIGluIHRoZSBzYW1lIHZjcHVzLgoKVGhhbmtzCl9fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fClZpcnR1YWxpemF0aW9uIG1haWxpbmcgbGlzdApWaXJ0
dWFsaXphdGlvbkBsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4
Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby92aXJ0dWFsaXphdGlvbg==
