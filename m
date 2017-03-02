From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: Re: [PATCH net] xen-netback: Use GFP_ATOMIC to allocate
	hash
Date: Thu, 2 Mar 2017 10:51:52 +0000
Message-ID: <92c0d11454744be4879fd3f4870480be@AMSPEX02CL03.citrite.net>
References: <1488451820-4759-1-git-send-email-anoob.soman@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Wei Liu <wei.liu2@citrix.com>, Anoob Soman <anoob.soman@citrix.com>
To: Anoob Soman <anoob.soman@citrix.com>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>, "xen-devel@lists.xenproject.org"
 <xen-devel@lists.xenproject.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1488451820-4759-1-git-send-email-anoob.soman@citrix.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQo+IEZyb206IEFub29iIFNvbWFuIFttYWlsdG86
YW5vb2Iuc29tYW5AY2l0cml4LmNvbV0KPiBTZW50OiAwMiBNYXJjaCAyMDE3IDEwOjUwCj4gVG86
IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc7IHhlbi1kZXZlbEBsaXN0cy54ZW5wcm9qZWN0Lm9yZwo+
IENjOiBQYXVsIER1cnJhbnQgPFBhdWwuRHVycmFudEBjaXRyaXguY29tPjsgV2VpIExpdSA8d2Vp
LmxpdTJAY2l0cml4LmNvbT47Cj4gQW5vb2IgU29tYW4gPGFub29iLnNvbWFuQGNpdHJpeC5jb20+
Cj4gU3ViamVjdDogW1BBVENIIG5ldF0geGVuLW5ldGJhY2s6IFVzZSBHRlBfQVRPTUlDIHRvIGFs
bG9jYXRlIGhhc2gKPiAKPiBBbGxvY2F0aW9uIG9mIG5ld19oYXNoLCBpbnNpZGUgeGVudmlmX25l
d19oYXNoKCksIGFsd2F5cyBoYXBwZW4KPiBpbiBzb2Z0aXJxIGNvbnRleHQsIHNvIHVzZSBHRlBf
QVRPTUlDIGluc3RlYWQgb2YgR0ZQX0tFUk5FTCBmb3IgbmV3Cj4gaGFzaCBhbGxvY2F0aW9uLgo+
IAo+IFNpZ25lZC1vZmYtYnk6IEFub29iIFNvbWFuIDxhbm9vYi5zb21hbkBjaXRyaXguY29tPgoK
QWNrZWQtYnk6IFBhdWwgRHVycmFudCA8cGF1bC5kdXJyYW50QGNpdHJpeC5jb20+Cgo+IC0tLQo+
ICBkcml2ZXJzL25ldC94ZW4tbmV0YmFjay9oYXNoLmMgfCAyICstCj4gIDEgZmlsZSBjaGFuZ2Vk
LCAxIGluc2VydGlvbigrKSwgMSBkZWxldGlvbigtKQo+IAo+IGRpZmYgLS1naXQgYS9kcml2ZXJz
L25ldC94ZW4tbmV0YmFjay9oYXNoLmMgYi9kcml2ZXJzL25ldC94ZW4tCj4gbmV0YmFjay9oYXNo
LmMKPiBpbmRleCBlOGM1ZGRkLi4zYzRjNThiIDEwMDY0NAo+IC0tLSBhL2RyaXZlcnMvbmV0L3hl
bi1uZXRiYWNrL2hhc2guYwo+ICsrKyBiL2RyaXZlcnMvbmV0L3hlbi1uZXRiYWNrL2hhc2guYwo+
IEBAIC0zOSw3ICszOSw3IEBAIHN0YXRpYyB2b2lkIHhlbnZpZl9hZGRfaGFzaChzdHJ1Y3QgeGVu
dmlmICp2aWYsIGNvbnN0IHU4Cj4gKnRhZywKPiAgCXVuc2lnbmVkIGxvbmcgZmxhZ3M7Cj4gIAli
b29sIGZvdW5kOwo+IAo+IC0JbmV3ID0ga21hbGxvYyhzaXplb2YoKmVudHJ5KSwgR0ZQX0tFUk5F
TCk7Cj4gKwluZXcgPSBrbWFsbG9jKHNpemVvZigqZW50cnkpLCBHRlBfQVRPTUlDKTsKPiAgCWlm
ICghbmV3KQo+ICAJCXJldHVybjsKPiAKPiAtLQo+IDIuNy40CgoKX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX18KWGVuLWRldmVsIG1haWxpbmcgbGlzdApYZW4t
ZGV2ZWxAbGlzdHMueGVuLm9yZwpodHRwczovL2xpc3RzLnhlbi5vcmcveGVuLWRldmVsCg==
