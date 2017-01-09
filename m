From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V4 net-next 3/3] tun: rx batching
Date: Mon, 9 Jan 2017 10:39:55 +0800
Message-ID: <bff99f2f-8293-0dda-1db1-881e555f3623@redhat.com>
References: <1483668797-24112-1-git-send-email-jasowang@redhat.com>
	<1483668797-24112-4-git-send-email-jasowang@redhat.com>
	<20170106214323-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, wexu@redhat.com,
	stefanha@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20170106214323-mutt-send-email-mst@kernel.org>
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

CgpPbiAyMDE35bm0MDHmnIgwN+aXpSAwMzo0NywgTWljaGFlbCBTLiBUc2lya2luIHdyb3RlOgo+
PiArc3RhdGljIGludCB0dW5fZ2V0X2NvYWxlc2NlKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYsCj4+
ICsJCQkgICAgc3RydWN0IGV0aHRvb2xfY29hbGVzY2UgKmVjKQo+PiArewo+PiArCXN0cnVjdCB0
dW5fc3RydWN0ICp0dW4gPSBuZXRkZXZfcHJpdihkZXYpOwo+PiArCj4+ICsJZWMtPnJ4X21heF9j
b2FsZXNjZWRfZnJhbWVzID0gdHVuLT5yeF9iYXRjaGVkOwo+PiArCj4+ICsJcmV0dXJuIDA7Cj4+
ICt9Cj4+ICsKPj4gK3N0YXRpYyBpbnQgdHVuX3NldF9jb2FsZXNjZShzdHJ1Y3QgbmV0X2Rldmlj
ZSAqZGV2LAo+PiArCQkJICAgIHN0cnVjdCBldGh0b29sX2NvYWxlc2NlICplYykKPj4gK3sKPj4g
KwlzdHJ1Y3QgdHVuX3N0cnVjdCAqdHVuID0gbmV0ZGV2X3ByaXYoZGV2KTsKPj4gKwo+PiArCWlm
IChlYy0+cnhfbWF4X2NvYWxlc2NlZF9mcmFtZXMgPiBOQVBJX1BPTExfV0VJR0hUKQo+PiArCQly
ZXR1cm4gLUVJTlZBTDsKPiBTbyB3aGF0IHNob3VsZCB1c2Vyc3BhY2UgZG8/IEtlZXAgdHJ5aW5n
IHVudGlsIGl0IHN1Y2NlZWRzPwo+IEkgdGhpbmsgaXQncyBiZXR0ZXIgdG8ganVzdCB1c2UgTkFQ
SV9QT0xMX1dFSUdIVCBpbnN0ZWFkIGFuZCBEVFJUIGhlcmUuCj4KCldlbGwsIGxvb2tpbmcgYXQg
aG93IHNldF9jb2FsZXNjZSBpcyBpbXBsZW1lbnRlZCBpbiBvdGhlciBkcml2ZXJzLCAKLUVJTlZB
TCBpcyB1c3VhbGx5IHVzZWQgd2hlbiB1c2VyIGdpdmUgYSB2YWx1ZSB0aGF0IGV4Y2VlZHMgdGhl
IApsaW1pdGF0aW9uLiBGb3IgdHVudGFwLCB3aGF0IG1pc3NlZCBoZXJlIGlzIHByb2JhYmx5IGp1
c3QgYSAKZG9jdW1lbnRhdGlvbiBmb3IgY29hbGVzY2luZyBpbiB0dW50YXAudHh0LiAoT3IgZXh0
ZW5kIGV0aHRvb2wgdG8gcmV0dXJuIAp0aGUgbWF4IHZhbHVlKS4gVGhpcyBzZWVtcyBtdWNoIGJl
dHRlciB0aGFuIHNpbGVudGx5IHJlZHVjZSB0aGUgdmFsdWUgdG8gCnRoZSBsaW1pdGF0aW9uLgoK
VGhhbmtzCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fClZp
cnR1YWxpemF0aW9uIG1haWxpbmcgbGlzdApWaXJ0dWFsaXphdGlvbkBsaXN0cy5saW51eC1mb3Vu
ZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0
aW5mby92aXJ0dWFsaXphdGlvbg==
