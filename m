From: Emil Velikov <emil.l.velikov@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] drm/vmwgfx: remove userland definition of
 DIV_ROUND_UP
Date: Fri, 4 Mar 2016 21:36:25 +0000
Message-ID: <CACvgo53Hc9OztHKSn=PNjd019M9ba_Qz1SvmJ4OBQG-p5q1o7A@mail.gmail.com>
References: <20160303.170804.2300821465150459193.davem@davemloft.net>
 <1457088739-1065-1-git-send-email-nicolas.dichtel@6wind.com>
 <1457088739-1065-4-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
 "Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
 ML dri-devel <dri-devel@lists.freedesktop.org>, Karen Xie <kxie@chelsio.com>,
 ben@decadent.org.uk, "David S. Miller" <davem@davemloft.net>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
 Thomas Hellstrom <thellstrom@vmware.com>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <1457088739-1065-4-git-send-email-nicolas.dichtel@6wind.com>
List-Unsubscribe: <https://lists.freedesktop.org/mailman/options/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <https://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <https://lists.freedesktop.org/mailman/listinfo/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: dri-devel-bounces@lists.freedesktop.org
Sender: "dri-devel" <dri-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

SGkgTmljb2xhcywKCk9uIDQgTWFyY2ggMjAxNiBhdCAxMDo1MiwgTmljb2xhcyBEaWNodGVsIDxu
aWNvbGFzLmRpY2h0ZWxANndpbmQuY29tPiB3cm90ZToKPiBMZXQncyB1c2UgX19LRVJORUxfRElW
X1JPVU5EX1VQLCB3aGljaCBpcyBkZWZpbmVkIGluIHVhcGkvbGludXgva2VybmVsLmguCj4KPiBT
aWduZWQtb2ZmLWJ5OiBOaWNvbGFzIERpY2h0ZWwgPG5pY29sYXMuZGljaHRlbEA2d2luZC5jb20+
Cj4gLS0tCj4gIC4uLi9kcm0vdm13Z2Z4L2RldmljZV9pbmNsdWRlL3N2Z2EzZF9zdXJmYWNlZGVm
cy5oICAgfCAyMCArKysrKysrKysrKy0tLS0tLS0tLQo+ICAxIGZpbGUgY2hhbmdlZCwgMTEgaW5z
ZXJ0aW9ucygrKSwgOSBkZWxldGlvbnMoLSkKPgo+IGRpZmYgLS1naXQgYS9kcml2ZXJzL2dwdS9k
cm0vdm13Z2Z4L2RldmljZV9pbmNsdWRlL3N2Z2EzZF9zdXJmYWNlZGVmcy5oIGIvZHJpdmVycy9n
cHUvZHJtL3Ztd2dmeC9kZXZpY2VfaW5jbHVkZS9zdmdhM2Rfc3VyZmFjZWRlZnMuaAo+IGluZGV4
IDU4NzA0ZjBhNDYwNy4uNTMxZDIyMDI1ZmVjIDEwMDY0NAo+IC0tLSBhL2RyaXZlcnMvZ3B1L2Ry
bS92bXdnZngvZGV2aWNlX2luY2x1ZGUvc3ZnYTNkX3N1cmZhY2VkZWZzLmgKPiArKysgYi9kcml2
ZXJzL2dwdS9kcm0vdm13Z2Z4L2RldmljZV9pbmNsdWRlL3N2Z2EzZF9zdXJmYWNlZGVmcy5oCj4g
QEAgLTI1LDYgKzI1LDggQEAKPiAgICoKPiAgICoqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqLwo+Cj4gKyNpbmNs
dWRlIDxsaW51eC9rZXJuZWwuaD4KPiArCkZpbGVzIGZyb20gRFJNIG1vZHVsZXMgdGVuZCB0byBi
ZSB1c2VkIGluIHZhcmlvdXMgKGNyYXp5KSB3YXlzLiBCZQp0aGF0IGluIGxpbnV4IGFuZC9vciBv
dGhlciB1c2VyIHNwYWNlLgoKRmFpcmx5IGNlcnRhaW4gdGhhdCBldmVyeXRoaW5nIGlzIGZpbmUg
aGVyZSwganVzdCBhZGRpbmcgb25lIG9mIHRoZQpjb3JlIHZtd2dmeCBkZXZlbG9wZXJzLgoKVGhv
bWFzLCB0aGlzIHdvbid0IGNhdXNlIGFueSBpc3N1ZXMgd291bGQgaXQgPwoKQ2FuIHlvdSBndXlz
IHBsZWFzZSBhZGQgYW4gZW50cnkgZm9yIHZtd2dmeCB0byBNQUlOVEFJTkVSUywgc28gdGhhdApw
ZW9wbGUgY2FuIENDIHlvdSBndXlzIG9uIHBhdGNoZXMgdGhhdCB0b3VjaCB0aGUgZHJpdmVyID8K
ClRoYW5rcwpFbWlsCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fCmRyaS1kZXZlbCBtYWlsaW5nIGxpc3QKZHJpLWRldmVsQGxpc3RzLmZyZWVkZXNrdG9wLm9y
ZwpodHRwczovL2xpc3RzLmZyZWVkZXNrdG9wLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2RyaS1kZXZl
bAo=
