From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [net-next RFC 08/14] openvswitch: Allocate & attach
 ip_tunnel_info for tunnel set action
Date: Thu, 4 Jun 2015 00:07:57 +0200
Message-ID: <20150603220757.GA687@pox.localdomain>
References: <cover.1433167295.git.tgraf@suug.ch>
 <13ac5a4837771ff2f52aa685f526b04c1ed76b86.1433167296.git.tgraf@suug.ch>
 <20150603172935.2a019653@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, marcelo.leitner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org,
 daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
 kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
 tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150603172935.2a019653@griffin>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

T24gMDYvMDMvMTUgYXQgMDU6MjlwbSwgSmlyaSBCZW5jIHdyb3RlOgo+IE9uIE1vbiwgIDEgSnVu
IDIwMTUgMTY6Mjc6MzIgKzAyMDAsIFRob21hcyBHcmFmIHdyb3RlOgo+ID4gLS0tIGEvbmV0L29w
ZW52c3dpdGNoL2Zsb3cuaAo+ID4gKysrIGIvbmV0L29wZW52c3dpdGNoL2Zsb3cuaAo+ID4gQEAg
LTQ1LDYgKzQ1LDExIEBAIHN0cnVjdCBza19idWZmOwo+ID4gICNkZWZpbmUgVFVOX01FVEFEQVRB
X09QVFMoZmxvd19rZXksIG9wdF9sZW4pIFwKPiA+ICAJKCh2b2lkICopKChmbG93X2tleSktPnR1
bl9vcHRzICsgVFVOX01FVEFEQVRBX09GRlNFVChvcHRfbGVuKSkpCj4gPiAgCj4gPiArc3RydWN0
IG92c190dW5uZWxfaW5mbwo+ID4gK3sKPiA+ICsJc3RydWN0IGlwX3R1bm5lbF9pbmZvCSppbmZv
Owo+ID4gK307Cj4gCj4gV2h5IGRvIHlvdSBrZWVwIHRoaXMgc3RydWN0dXJlPyBJdCBkb2Vzbid0
IHNlZW0gaXQncyB1c2VmdWwuCgpJdCdzIHRoZSBzdHJ1Y3R1cmUgd2hpY2ggZGVmaW5lcyB0aGUg
cGF5bG9hZCBvZiB0aGUgT1ZTIHNldAp0dW5uZWwgYWN0aW9uLiBUaG9zZSBhY3Rpb25zIGFyZSBj
b25maWd1cmVkIGFzIE5ldGxpbmsgYXR0cmlidXRlcwpvbmx5IHZpc2libGUgdG8gdGhlIGtlcm5l
bC4gU2luY2Ugd2UgYWxsb2NhdGUgdGhlIGlwX3R1bm5lbF9pbmZvCnRvIGF0dGFjaCBpdCB0byB0
aGUgcGFja2V0cyBwYXNzaW5nIGJ5LCB3ZSBvbmx5IG5lZWQgdG8ga2VlcCBhCnBvaW50ZXIgYXMg
dGhlIGNvbmZpZyB0byB0aGUgc2V0IGFjdGlvbi4gV2UgY291bGQgYWxzbyBkbwooc3RydWN0IGlw
X3R1bm5lbF9pbmZvICopIG5sYV9kYXRhKC4uLikgYW5kIHN0b3JlIHRoZSBwb2ludGVyCndpdGhv
dXQgZGVmaW5pbmcgYSBzdHJ1Y3QuIEkgZm91bmQgdGhpcyBtb3JlIHJlYWRhYmxlLiBIYXBweSB0
bwpjaGFuZ2UgaWYgeW91IGxpa2UgaXQgYmV0dGVyIHdpdGhvdXQgYSBzdHJ1Y3QgYXJvdW5kIGl0
LgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpkZXYgbWFp
bGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNoLm9yZy9tYWls
bWFuL2xpc3RpbmZvL2Rldgo=
