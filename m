From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 7/8] vhost_net: try batch dequing from skb array
Date: Wed, 29 Mar 2017 18:53:27 +0800
Message-ID: <cea3d380-389e-d258-915a-3d4f60232535@redhat.com>
References: <1490069087-4783-1-git-send-email-jasowang@redhat.com>
	<1490069087-4783-8-git-send-email-jasowang@redhat.com>
	<20170322155111-mutt-send-email-mst@kernel.org>
	<f41bb12f-10d6-9fb2-1cd2-76e3e9460aff@redhat.com>
	<bf511f4a-b1d0-d732-a01e-9cd4b8ae6817@redhat.com>
	<674632255.8752546.1490784387956.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Pankaj Gupta <pagupta@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <674632255.8752546.1490784387956.JavaMail.zimbra@redhat.com>
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

CgpPbiAyMDE35bm0MDPmnIgyOeaXpSAxODo0NiwgUGFua2FqIEd1cHRhIHdyb3RlOgo+IEhpIEph
c29uLAo+Cj4+IE9uIDIwMTflubQwM+aciDIz5pelIDEzOjM0LCBKYXNvbiBXYW5nIHdyb3RlOgo+
Pj4KPj4+Pj4gK3sKPj4+Pj4gKyAgICBpZiAocnZxLT5yaCAhPSBydnEtPnJ0KQo+Pj4+PiArICAg
ICAgICBnb3RvIG91dDsKPj4+Pj4gKwo+Pj4+PiArICAgIHJ2cS0+cmggPSBydnEtPnJ0ID0gMDsK
Pj4+Pj4gKyAgICBydnEtPnJ0ID0gc2tiX2FycmF5X2NvbnN1bWVfYmF0Y2hlZF9iaChydnEtPnJ4
X2FycmF5LCBydnEtPnJ4cSwKPj4+Pj4gKyAgICAgICAgICAgICAgICAgICAgICAgIFZIT1NUX1JY
X0JBVENIKTsKPj4+PiBBIGNvbW1lbnQgZXhwbGFpbmluZyB3aHkgaXMgaXMgLWJoIHdvdWxkIGJl
IGhlbHBmdWwuCj4+PiBPay4KPj4+Cj4+PiBUaGFua3MKPj4gUmV0aGluayBhYm91dCB0aGlzLiBJ
dCBsb29rcyBsaWtlIC1iaCBpcyBub3QgbmVlZGVkIGluIHRoaXMgY2FzZSBzaW5jZQo+PiBubyBj
b25zdW1lciBydW4gaW4gYmguCj4gSW4gdGhhdCBjYXNlIGRvIHdlIG5lZWQgb3RoZXIgdmFyaWFu
dHMgb2YgInB0cl9yaW5nX2NvbnN1bWVfYmF0Y2hlZF8qKCkiIGZ1bmN0aW9ucy4KPiBBcmUgd2Ug
cGxhbm5pbmcgdG8gdXNlIHRoZW0gaW4gZnV0dXJlPwoKSSB0aGluayB3ZSdkIGJldHRlciBrZWVw
IHRoZW0sIHNpbmNlIGl0IHNlcnZlcyBhcyBoZWxwZXJzLiBZb3UgY2FuIHNlZSAKdGhhdCBub3Qg
YWxsIHRoZSBoZWxwZXJzIGluIHB0cl9yaW5nIGhhcyByZWFsIHVzZXJzLCBidXQgdGhleSB3ZXJl
IApwcmVwYXJlZCBmb3IgdGhlIGZ1dHVyZSB1c2UuCgpUaGFua3MKCj4KPj4gVGhhbmtzCj4+Cgpf
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpWaXJ0dWFsaXph
dGlvbiBtYWlsaW5nIGxpc3QKVmlydHVhbGl6YXRpb25AbGlzdHMubGludXgtZm91bmRhdGlvbi5v
cmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vdmly
dHVhbGl6YXRpb24=
