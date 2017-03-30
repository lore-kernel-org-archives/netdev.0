From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] virtio_net: fix mergeable bufs error handling
Date: Thu, 30 Mar 2017 11:59:21 +0800
Message-ID: <67f7d42f-7ab5-10f4-80b2-83044ae1048b@redhat.com>
References: <1490791050-22046-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, John Fastabend <john.fastabend@gmail.com>,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1490791050-22046-1-git-send-email-mst@redhat.com>
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

CgpPbiAyMDE35bm0MDPmnIgyOeaXpSAyMDozNywgTWljaGFlbCBTLiBUc2lya2luIHdyb3RlOgo+
IE9uIHhkcCBlcnJvciB3ZSB0cnkgdG8gZnJlZSBoZWFkX3NrYiB3aXRob3V0IGhhdmluZwo+IGlu
aXRpYWxpemVkIGl0LCB0aGF0J3MgY2xlYXJseSBib2d1cy4KPgo+IEZpeGVzOiBmNjAwYjY5MDUw
MTUgKCJ2aXJ0aW9fbmV0OiBBZGQgWERQIHN1cHBvcnQiKQo+IENjOiBKb2huIEZhc3RhYmVuZCA8
am9obi5mYXN0YWJlbmRAZ21haWwuY29tPgo+IFNpZ25lZC1vZmYtYnk6IE1pY2hhZWwgUy4gVHNp
cmtpbiA8bXN0QHJlZGhhdC5jb20+Cj4gLS0tCj4gICBkcml2ZXJzL25ldC92aXJ0aW9fbmV0LmMg
fCAyICstCj4gICAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKyksIDEgZGVsZXRpb24oLSkK
Pgo+IGRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC92aXJ0aW9fbmV0LmMgYi9kcml2ZXJzL25ldC92
aXJ0aW9fbmV0LmMKPiBpbmRleCAxMTc3M2Q2Li5lMGZiMzcwNyAxMDA2NDQKPiAtLS0gYS9kcml2
ZXJzL25ldC92aXJ0aW9fbmV0LmMKPiArKysgYi9kcml2ZXJzL25ldC92aXJ0aW9fbmV0LmMKPiBA
QCAtNTcwLDcgKzU3MCw3IEBAIHN0YXRpYyBzdHJ1Y3Qgc2tfYnVmZiAqcmVjZWl2ZV9tZXJnZWFi
bGUoc3RydWN0IG5ldF9kZXZpY2UgKmRldiwKPiAgIAl1MTYgbnVtX2J1ZjsKPiAgIAlzdHJ1Y3Qg
cGFnZSAqcGFnZTsKPiAgIAlpbnQgb2Zmc2V0Owo+IC0Jc3RydWN0IHNrX2J1ZmYgKmhlYWRfc2ti
LCAqY3Vycl9za2I7Cj4gKwlzdHJ1Y3Qgc2tfYnVmZiAqaGVhZF9za2IgPSBOVUxMLCAqY3Vycl9z
a2I7Cj4gICAJc3RydWN0IGJwZl9wcm9nICp4ZHBfcHJvZzsKPiAgIAl1bnNpZ25lZCBpbnQgdHJ1
ZXNpemU7Cj4gICAKCk15IHRyZWUgKG5ldC5naXQgSEVBRCBpcyA4ZjFmN2VlYjIyYzE2YTE5NzE1
OWNmN2IzNWQxMzUwNjk1MTkzZWFkKSBoYXM6CgogICAgIGhlYWRfc2tiID0gTlVMTDsKCmp1c3Qg
YWZ0ZXIgdGhlIGFib3ZlIGNvZGVzLgoKVGhhbmtzCl9fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fClZpcnR1YWxpemF0aW9uIG1haWxpbmcgbGlzdApWaXJ0dWFs
aXphdGlvbkBsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91
bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby92aXJ0dWFsaXphdGlvbg==
