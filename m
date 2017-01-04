From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next V2 3/3] tun: rx batching
Date: Wed, 4 Jan 2017 11:03:32 +0800
Message-ID: <73da2ef8-2454-5614-d637-0ce7c5287433@redhat.com>
References: <1482912571-3157-1-git-send-email-jasowang@redhat.com>
	<1482912571-3157-4-git-send-email-jasowang@redhat.com>
	<20170103133303.GC14707@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
To: Stefan Hajnoczi <stefanha@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20170103133303.GC14707@stefanha-x1.localdomain>
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

CgpPbiAyMDE35bm0MDHmnIgwM+aXpSAyMTozMywgU3RlZmFuIEhham5vY3ppIHdyb3RlOgo+IE9u
IFdlZCwgRGVjIDI4LCAyMDE2IGF0IDA0OjA5OjMxUE0gKzA4MDAsIEphc29uIFdhbmcgd3JvdGU6
Cj4+ICtzdGF0aWMgaW50IHR1bl9yeF9iYXRjaGVkKHN0cnVjdCB0dW5fZmlsZSAqdGZpbGUsIHN0
cnVjdCBza19idWZmICpza2IsCj4+ICsJCQkgIGludCBtb3JlKQo+PiArewo+PiArCXN0cnVjdCBz
a19idWZmX2hlYWQgKnF1ZXVlID0gJnRmaWxlLT5zay5za193cml0ZV9xdWV1ZTsKPj4gKwlzdHJ1
Y3Qgc2tfYnVmZl9oZWFkIHByb2Nlc3NfcXVldWU7Cj4+ICsJaW50IHFsZW47Cj4+ICsJYm9vbCBy
Y3YgPSBmYWxzZTsKPj4gKwo+PiArCXNwaW5fbG9jaygmcXVldWUtPmxvY2spOwo+IFNob3VsZCB0
aGlzIGJlIHNwaW5fbG9ja19iaCgpPyAgQmVsb3cgYW5kIGluIHR1bl9nZXRfdXNlcigpIHRoZXJl
IGFyZQo+IGV4cGxpY2l0IGxvY2FsX2JoX2Rpc2FibGUoKSBjYWxscyBzbyBJIGd1ZXNzIEJIcyBj
YW4gaW50ZXJydXB0IHVzIGhlcmUKPiBhbmQgdGhpcyB3b3VsZCBkZWFkbG9jay4KCnNrX3dyaXRl
X3F1ZXVlIHdlcmUgYWNjZXNzZWQgb25seSBpbiB0aGlzIGZ1bmN0aW9uIHdoaWNoIHJ1bnMgdW5k
ZXIgCnByb2Nlc3MgY29udGV4dCwgc28gbm8gbmVlZCBmb3Igc3Bpbl9sb2NrX2JoKCkgaGVyZS4K
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KVmlydHVhbGl6
YXRpb24gbWFpbGluZyBsaXN0ClZpcnR1YWxpemF0aW9uQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24u
b3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL3Zp
cnR1YWxpemF0aW9u
