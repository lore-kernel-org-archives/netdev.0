From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [PATCH nf-next v9 8/8] openvswitch: Interface with
	NAT.
Date: Thu, 10 Mar 2016 13:00:21 +0100
Message-ID: <20160310120021.GA26693@pox.localdomain>
References: <1457565024-27300-1-git-send-email-jarno@ovn.org>
 <1457565024-27300-8-git-send-email-jarno@ovn.org>
 <CAPWQB7GkhrfZaaT-LkTP7Esfj4tzU=Fgto2ZaSq4YkurhOf8bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Joe Stringer <joe-LZ6Gd1LRuIk@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAPWQB7GkhrfZaaT-LkTP7Esfj4tzU=Fgto2ZaSq4YkurhOf8bw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

T24gMDMvMDkvMTYgYXQgMDc6NDdwbSwgSm9lIFN0cmluZ2VyIHdyb3RlOgo+IE9uIDkgTWFyY2gg
MjAxNiBhdCAxNToxMCwgSmFybm8gUmFqYWhhbG1lIDxqYXJub0Bvdm4ub3JnPiB3cm90ZToKPiA+
IEV4dGVuZCBPVlMgY29ubnRyYWNrIGludGVyZmFjZSB0byBjb3ZlciBOQVQuICBOZXcgbmVzdGVk
Cj4gPiBPVlNfQ1RfQVRUUl9OQVQgYXR0cmlidXRlIG1heSBiZSB1c2VkIHRvIGluY2x1ZGUgTkFU
IHdpdGggYSBDVCBhY3Rpb24uCj4gPiBBIGJhcmUgT1ZTX0NUX0FUVFJfTkFUIG9ubHkgbWFuZ2xl
cyBleGlzdGluZyBhbmQgZXhwZWN0ZWQgY29ubmVjdGlvbnMuCj4gPiBJZiBPVlNfTkFUX0FUVFJf
U1JDIG9yIE9WU19OQVRfQVRUUl9EU1QgaXMgaW5jbHVkZWQgd2l0aGluIHRoZSBuZXN0ZWQKPiA+
IGF0dHJpYnV0ZXMsIG5ldyAobm9uLWNvbW1pdHRlZC9ub24tY29uZmlybWVkKSBjb25uZWN0aW9u
cyBhcmUgbWFuZ2xlZAo+ID4gYWNjb3JkaW5nIHRvIHRoZSByZXN0IG9mIHRoZSBuZXN0ZWQgYXR0
cmlidXRlcy4KPiA+Cj4gPiBUaGUgY29ycmVzcG9uZGluZyBPVlMgdXNlcnNwYWNlIHBhdGNoIHNl
cmllcyBpbmNsdWRlcyB0ZXN0IGNhc2VzIChpbgo+ID4gdGVzdHMvc3lzdGVtLXRyYWZmaWMuYXQp
IHRoYXQgYWxzbyBzZXJ2ZSBhcyBleGFtcGxlIHVzZXMuCj4gPgo+ID4gVGhpcyB3b3JrIGV4dGVu
ZHMgb24gYSBicmFuY2ggYnkgVGhvbWFzIEdyYWYgYXQKPiA+IGh0dHBzOi8vZ2l0aHViLmNvbS90
Z3JhZi9vdnMvdHJlZS9uYXQuCj4gCj4gVGhvbWFzLCBJIGd1ZXNzIHRoZXJlIHdhcyBub3Qgc2ln
bm9mZiBpbiB0aGVzZSBwYXRjaGVzIHNvIEphcm5vIGRvZXMKPiBub3QgaGF2ZSB5b3VyIHNpZ25v
ZmYgaW4gdGhpcyBwYXRjaC4KClRoYXQncyBmaW5lLiBUaGUgY29kZSBoYXMgZXZvbHZlZCBhIGxv
dCBzaW5jZS4gSSBkb24ndCBzZWUgYW55dGhpbmcKZnVydGhlciB0aGFuIHdoYXQgSm9lIHNwb3R0
ZWQgc28gZmVlbCBmcmVlIHRvIGFkZCBteQoKQWNrZWQtYnk6IFRob21hcyBHcmFmIDx0Z3JhZkBz
dXVnLmNoPgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpk
ZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNoLm9y
Zy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
