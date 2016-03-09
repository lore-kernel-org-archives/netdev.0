From: Jarno Rajahalme <jarno-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH nf-next v8 3/8] openvswitch: Add commentary to
	conntrack.c
Date: Wed, 9 Mar 2016 15:14:43 -0800
Message-ID: <C2353FFE-5D2F-4B8B-9241-B50113F63723@ovn.org>
References: <1457483084-13944-1-git-send-email-jarno@ovn.org>
 <1457483084-13944-3-git-send-email-jarno@ovn.org>
 <56E02A15.6030005@cogentembedded.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <56E02A15.6030005-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
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

U2VyZ2VpLAoKSnVzdCBmb3VuZCB0aGlzIGZyb20gbXkganVuayBtYWlsIGJveCwgc29ycnkuIFdp
bGwgZml4IHNwZWxsaW5nLCBidXQgSSBqdXN0IHNlbnQgdjkgYW5kIHdpbGwgd2FpdCBmb3Igb3Ro
ZXIgcmV2aWV3cyBiZWZvcmUgcmUtcG9zdGluZy4KCiAgSmFybm8KCj4gT24gTWFyIDksIDIwMTYs
IGF0IDU6NTAgQU0sIFNlcmdlaSBTaHR5bHlvdiA8c2VyZ2VpLnNodHlseW92QGNvZ2VudGVtYmVk
ZGVkLmNvbT4gd3JvdGU6Cj4gCj4gSGVsbG8uCj4gCj4gT24gMy85LzIwMTYgMzoyNCBBTSwgSmFy
bm8gUmFqYWhhbG1lIHdyb3RlOgo+IAo+PiBUaGlzIG1ha2VzIHRoZSBjb2RlIGVhc2llciB0byB1
bmRlcnN0YW5kIGFuZCB0aGUgZm9sbG93aW5nIHBhdGNoZXMKPj4gbW9yZSBmb2N1c2VkLgo+PiAK
Pj4gU2lnbmVkLW9mZi1ieTogSmFybm8gUmFqYWhhbG1lIDxqYXJub0Bvdm4ub3JnPgo+PiAtLS0K
Pj4gIG5ldC9vcGVudnN3aXRjaC9jb25udHJhY2suYyB8IDIxICsrKysrKysrKysrKysrKysrKysr
LQo+PiAgMSBmaWxlIGNoYW5nZWQsIDIwIGluc2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkKPj4g
Cj4+IGRpZmYgLS1naXQgYS9uZXQvb3BlbnZzd2l0Y2gvY29ubnRyYWNrLmMgYi9uZXQvb3BlbnZz
d2l0Y2gvY29ubnRyYWNrLmMKPj4gaW5kZXggMzA0NTI5MC4uOGNkMDExMCAxMDA2NDQKPj4gLS0t
IGEvbmV0L29wZW52c3dpdGNoL2Nvbm50cmFjay5jCj4+ICsrKyBiL25ldC9vcGVudnN3aXRjaC9j
b25udHJhY2suYwo+IFsuLi5dCj4+IEBAIC00MTgsNiArNDI5LDEzIEBAIHN0YXRpYyBpbnQgb3Zz
X2N0X2xvb2t1cChzdHJ1Y3QgbmV0ICpuZXQsIHN0cnVjdCBzd19mbG93X2tleSAqa2V5LAo+PiAg
ewo+PiAgCXN0cnVjdCBuZl9jb25udHJhY2tfZXhwZWN0ICpleHA7Cj4+IAo+PiArCS8qIElmIHdl
IHBhc3MgYW4gZXhwZWN0ZWQgcGFja2V0IHRocm91Z2ggbmZfY29ubnRyYWNrX2luKCkgdGhlCj4+
ICsJICogZXhwZWN0aWF0aW9uIGlzIHR5cGljYWxseSByZW1vdmVkLCBidXQgdGhlIHBhY2tldCBj
b3VsZCBzdGlsbCBiZQo+IAo+ICAgRXhwZWN0YXRpb24uCj4gWy4uLl0KPiAKPiBNQlIsIFNlcmdl
aQo+IAoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KZGV2
IG1haWxpbmcgbGlzdApkZXZAb3BlbnZzd2l0Y2gub3JnCmh0dHA6Ly9vcGVudnN3aXRjaC5vcmcv
bWFpbG1hbi9saXN0aW5mby9kZXYK
