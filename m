From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next V3 3/3] tun: rx batching
Date: Tue, 3 Jan 2017 11:18:17 +0800
Message-ID: <52dd7224-d26e-7684-214e-0d8289392ff3@redhat.com>
References: <1483075251-6889-1-git-send-email-jasowang@redhat.com>
	<1483075251-6889-4-git-send-email-jasowang@redhat.com>
	<20161231130333.347cb8f3@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	wexu@redhat.com, kvm@vger.kernel.org, mst@redhat.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20161231130333.347cb8f3@xeon-e3>
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

CgpPbiAyMDE35bm0MDHmnIgwMeaXpSAwNTowMywgU3RlcGhlbiBIZW1taW5nZXIgd3JvdGU6Cj4g
T24gRnJpLCAzMCBEZWMgMjAxNiAxMzoyMDo1MSArMDgwMAo+IEphc29uIFdhbmcgPGphc293YW5n
QHJlZGhhdC5jb20+IHdyb3RlOgo+Cj4+IGRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC90dW4uYyBi
L2RyaXZlcnMvbmV0L3R1bi5jCj4+IGluZGV4IGNkOGUwMmMuLmEyNjhlZDkgMTAwNjQ0Cj4+IC0t
LSBhL2RyaXZlcnMvbmV0L3R1bi5jCj4+ICsrKyBiL2RyaXZlcnMvbmV0L3R1bi5jCj4+IEBAIC03
NSw2ICs3NSwxMCBAQAo+PiAgIAo+PiAgICNpbmNsdWRlIDxsaW51eC91YWNjZXNzLmg+Cj4+ICAg
Cj4+ICtzdGF0aWMgaW50IHJ4X2JhdGNoZWQ7Cj4+ICttb2R1bGVfcGFyYW0ocnhfYmF0Y2hlZCwg
aW50LCAwNDQ0KTsKPj4gK01PRFVMRV9QQVJNX0RFU0MocnhfYmF0Y2hlZCwgIk51bWJlciBvZiBw
YWNrZXRzIGJhdGNoZWQgaW4gcngiKTsKPj4gKwo+PiAgIC8qIFVuY29tbWVudCB0byBlbmFibGUg
ZGVidWdnaW5nICovCj4gSSBsaWtlIHRoZSBjb25jZXB0IG9yIHJ4IGJhdGNoaW5nLiBCdXQgY29u
dHJvbGxpbmcgaXQgdmlhIGEgbW9kdWxlIHBhcmFtZXRlcgo+IGlzIG9uZSBvZiB0aGUgd29yc3Qg
QVBJIGNob2ljZXMuICBFdGh0b29sIHdvdWxkIGJlIGJldHRlciB0byB1c2UgYmVjYXVzZSB0aGF0
IGlzCj4gaG93IG90aGVyIG5ldHdvcmsgZGV2aWNlcyBjb250cm9sIGJhdGNoaW5nLgo+Cj4gSWYg
eW91IGRvIGV0aHRvb2wsIHlvdSBjb3VsZCBldmVuIGV4dGVuZCBpdCB0byBoYXZlIGFuIG51bWJl
ciBvZiBwYWNrZXRzCj4gYW5kIG1heCBsYXRlbmN5IHZhbHVlLgoKUmlnaHQsIHRoaXMgaXMgYmV0
dGVyIChJIGJlbGlldmUgeW91IG1lYW4gcngtZnJhbWVzKS4gRm9yIHJ4LXVzZWNzLCB3ZSAKY291
bGQgZG8gaXQgb24gdG9wIGluIHRoZSBmdXR1cmUuCgpUaGFua3MKX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX18KVmlydHVhbGl6YXRpb24gbWFpbGluZyBsaXN0
ClZpcnR1YWxpemF0aW9uQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMu
bGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL3ZpcnR1YWxpemF0aW9u
