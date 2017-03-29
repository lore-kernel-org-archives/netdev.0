From: Pankaj Gupta <pagupta@redhat.com>
Subject: Re: [PATCH net-next 7/8] vhost_net: try batch dequing from skb array
Date: Wed, 29 Mar 2017 06:46:27 -0400 (EDT)
Message-ID: <674632255.8752546.1490784387956.JavaMail.zimbra@redhat.com>
References: <1490069087-4783-1-git-send-email-jasowang@redhat.com>
	<1490069087-4783-8-git-send-email-jasowang@redhat.com>
	<20170322155111-mutt-send-email-mst@kernel.org>
	<f41bb12f-10d6-9fb2-1cd2-76e3e9460aff@redhat.com>
	<bf511f4a-b1d0-d732-a01e-9cd4b8ae6817@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <bf511f4a-b1d0-d732-a01e-9cd4b8ae6817@redhat.com>
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

SGkgSmFzb24sCgo+IAo+IE9uIDIwMTflubQwM+aciDIz5pelIDEzOjM0LCBKYXNvbiBXYW5nIHdy
b3RlOgo+ID4KPiA+Cj4gPj4KPiA+Pj4gK3sKPiA+Pj4gKyAgICBpZiAocnZxLT5yaCAhPSBydnEt
PnJ0KQo+ID4+PiArICAgICAgICBnb3RvIG91dDsKPiA+Pj4gKwo+ID4+PiArICAgIHJ2cS0+cmgg
PSBydnEtPnJ0ID0gMDsKPiA+Pj4gKyAgICBydnEtPnJ0ID0gc2tiX2FycmF5X2NvbnN1bWVfYmF0
Y2hlZF9iaChydnEtPnJ4X2FycmF5LCBydnEtPnJ4cSwKPiA+Pj4gKyAgICAgICAgICAgICAgICAg
ICAgICAgIFZIT1NUX1JYX0JBVENIKTsKPiA+PiBBIGNvbW1lbnQgZXhwbGFpbmluZyB3aHkgaXMg
aXMgLWJoIHdvdWxkIGJlIGhlbHBmdWwuCj4gPgo+ID4gT2suCj4gPgo+ID4gVGhhbmtzCj4gCj4g
UmV0aGluayBhYm91dCB0aGlzLiBJdCBsb29rcyBsaWtlIC1iaCBpcyBub3QgbmVlZGVkIGluIHRo
aXMgY2FzZSBzaW5jZQo+IG5vIGNvbnN1bWVyIHJ1biBpbiBiaC4KCkluIHRoYXQgY2FzZSBkbyB3
ZSBuZWVkIG90aGVyIHZhcmlhbnRzIG9mICJwdHJfcmluZ19jb25zdW1lX2JhdGNoZWRfKigpIiBm
dW5jdGlvbnMuCkFyZSB3ZSBwbGFubmluZyB0byB1c2UgdGhlbSBpbiBmdXR1cmU/IAoKPiAKPiBU
aGFua3MKPiAKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18K
VmlydHVhbGl6YXRpb24gbWFpbGluZyBsaXN0ClZpcnR1YWxpemF0aW9uQGxpc3RzLmxpbnV4LWZv
dW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xp
c3RpbmZvL3ZpcnR1YWxpemF0aW9u
