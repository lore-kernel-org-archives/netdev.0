From: Joe Stringer <joe-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH nf-next v9 5/8] openvswitch: Find existing
 conntrack entry after upcall.
Date: Wed, 9 Mar 2016 18:29:06 -0800
Message-ID: <CAPWQB7HjMfhpK5hGSCZ0B91QCqbrAxP4+obA1GQTbtBUwXi2zg@mail.gmail.com>
References: <1457565024-27300-1-git-send-email-jarno@ovn.org>
 <1457565024-27300-5-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jarno Rajahalme <jarno-LZ6Gd1LRuIk@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1457565024-27300-5-git-send-email-jarno-LZ6Gd1LRuIk@public.gmane.org>
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

T24gOSBNYXJjaCAyMDE2IGF0IDE1OjEwLCBKYXJubyBSYWphaGFsbWUgPGphcm5vQG92bi5vcmc+
IHdyb3RlOgo+IEFkZCBhIG5ldyBmdW5jdGlvbiBvdnNfY3RfZmluZF9leGlzdGluZygpIHRvIGZp
bmQgYW4gZXhpc3RpbmcKPiBjb25udHJhY2sgZW50cnkgZm9yIHdoaWNoIHRoaXMgcGFja2V0IHdh
cyBhbHJlYWR5IGFwcGxpZWQgdG8uICBUaGlzIGlzCj4gb25seSB0byBiZSBjYWxsZWQgd2hlbiB0
aGVyZSBpcyBldmlkZW5jZSB0aGF0IHRoZSBwYWNrZXQgd2FzIGFscmVhZHkKPiB0cmFja2VkIGFu
ZCBjb21taXR0ZWQsIGJ1dCB3ZSBsb3N0IHRoZSBjdCByZWZlcmVuY2UgZHVlIHRvIGFuCj4gdXNl
cnNwYWNlIHVwY2FsbC4KPgo+IG92c19jdF9maW5kX2V4aXN0aW5nKCkgaXMgY2FsbGVkIGZyb20g
c2tiX25mY3RfY2FjaGVkKCksIHdoaWNoIGNhbiBub3cKPiBoaWRlIHRoZSBmYWN0IHRoYXQgdGhl
IGN0IHJlZmVyZW5jZSBtYXkgaGF2ZSBiZWVuIGxvc3QgZHVlIHRvIGFuCj4gdXBjYWxsLiAgVGhp
cyBhbGxvd3Mgb3ZzX2N0X2NvbW1pdCgpIHRvIGJlIHNpbXBsaWZpZWQuCj4KPiBUaGlzIHBhdGNo
IGlzIG5lZWRlZCBieSBsYXRlciAib3BlbnZzd2l0Y2g6IEludGVyZmFjZSB3aXRoIE5BVCIgcGF0
Y2gsCj4gYXMgd2UgbmVlZCB0byBiZSBhYmxlIHRvIHBhc3MgdGhlIHBhY2tldCB0aHJvdWdoIE5B
VCB1c2luZyB0aGUKPiBvcmlnaW5hbCBjdCByZWZlcmVuY2UgYWxzbyBhZnRlciB0aGUgcmVmZXJl
bmNlIGlzIGxvc3QgYWZ0ZXIgYW4KPiB1cGNhbGwuCj4KPiBTaWduZWQtb2ZmLWJ5OiBKYXJubyBS
YWphaGFsbWUgPGphcm5vQG92bi5vcmc+CgpBY2tlZC1ieTogSm9lIFN0cmluZ2VyIDxqb2VAb3Zu
Lm9yZz4KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KZGV2
IG1haWxpbmcgbGlzdApkZXZAb3BlbnZzd2l0Y2gub3JnCmh0dHA6Ly9vcGVudnN3aXRjaC5vcmcv
bWFpbG1hbi9saXN0aW5mby9kZXYK
