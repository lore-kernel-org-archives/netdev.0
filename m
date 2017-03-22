From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 1/8] ptr_ring: introduce batch dequeuing
Date: Wed, 22 Mar 2017 11:16:07 +0800
Message-ID: <590abb0f-e28a-52f7-5abc-b72159e31d5f@redhat.com>
References: <1490069087-4783-1-git-send-email-jasowang@redhat.com>
	<1490069087-4783-2-git-send-email-jasowang@redhat.com>
	<9ecd2a27-4f93-2b3f-cb91-c558976973a2@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, mst@redhat.com,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <9ecd2a27-4f93-2b3f-cb91-c558976973a2@cogentembedded.com>
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

CgpPbiAyMDE35bm0MDPmnIgyMeaXpSAxODoyNSwgU2VyZ2VpIFNodHlseW92IHdyb3RlOgo+IEhl
bGxvIQo+Cj4gT24gMy8yMS8yMDE3IDc6MDQgQU0sIEphc29uIFdhbmcgd3JvdGU6Cj4KPj4gU2ln
bmVkLW9mZi1ieTogSmFzb24gV2FuZyA8amFzb3dhbmdAcmVkaGF0LmNvbT4KPj4gLS0tCj4+ICBp
bmNsdWRlL2xpbnV4L3B0cl9yaW5nLmggfCA2NSAKPj4gKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrCj4+ICAxIGZpbGUgY2hhbmdlZCwgNjUgaW5zZXJ0aW9u
cygrKQo+Pgo+PiBkaWZmIC0tZ2l0IGEvaW5jbHVkZS9saW51eC9wdHJfcmluZy5oIGIvaW5jbHVk
ZS9saW51eC9wdHJfcmluZy5oCj4+IGluZGV4IDZjNzA0NDQuLjQ3NzFkZWQgMTAwNjQ0Cj4+IC0t
LSBhL2luY2x1ZGUvbGludXgvcHRyX3JpbmcuaAo+PiArKysgYi9pbmNsdWRlL2xpbnV4L3B0cl9y
aW5nLmgKPj4gQEAgLTI0Nyw2ICsyNDcsMjIgQEAgc3RhdGljIGlubGluZSB2b2lkICpfX3B0cl9y
aW5nX2NvbnN1bWUoc3RydWN0IAo+PiBwdHJfcmluZyAqcikKPj4gICAgICByZXR1cm4gcHRyOwo+
PiAgfQo+Pgo+PiArc3RhdGljIGlubGluZSBpbnQgX19wdHJfcmluZ19jb25zdW1lX2JhdGNoZWQo
c3RydWN0IHB0cl9yaW5nICpyLAo+PiArICAgICAgICAgICAgICAgICAgICAgICAgIHZvaWQgKiph
cnJheSwgaW50IG4pCj4+ICt7Cj4+ICsgICAgdm9pZCAqcHRyOwo+PiArICAgIGludCBpID0gMDsK
Pj4gKwo+PiArICAgIHdoaWxlIChpIDwgbikgewo+Cj4gICAgSG0sIHdoeSBub3QgKmZvcio/CgpZ
ZXMsIGl0IG1heWJlIGJldHRlciwgaWYgdGhlcmUncyBvdGhlciBjb21tZW50IG9uIHRoZSBzZXJp
ZXMsIHdpbGwgCmNoYW5nZSBpdCBpbiBuZXh0IHZlcnNpb24uCgpUaGFua3MKCl9fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fClZpcnR1YWxpemF0aW9uIG1haWxp
bmcgbGlzdApWaXJ0dWFsaXphdGlvbkBsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczov
L2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby92aXJ0dWFsaXphdGlv
bg==
