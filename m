From: Jani Nikula <jani.nikula@linux.intel.com>
Subject: Re: [PATCH] format-security: move static strings to const
Date: Thu, 06 Apr 2017 11:48:48 +0300
Message-ID: <87mvbtzztb.fsf@intel.com>
References: <20170405214711.GA5711@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-mips@linux-mips.org, linux-decnet-user@lists.sourceforge.net,
 kernel@stlinux.com, Qianqian Xie <xieqianqian@huawei.com>,
 Mugunthan V N <mugunthanvnm@ti.com>, Tony Lindgren <tony@atomide.com>,
 Viresh Kumar <viresh.kumar@linaro.org>,
 Rasmus Villemoes <linux@rasmusvillemoes.dk>, dri-devel@lists.freedesktop.org,
 linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
 "Maciej W. Rozycki" <macro@linux-mips.org>,
 Christian Gromm <christian.gromm@microchip.com>,
 Daniel Vetter <daniel.vetter@intel.com>, Ingo Molnar <mingo@kernel.org>,
 Andrey Shvetsov <andrey.shvetsov@k2l.de>, devel@driverdev.osuosl.org,
 Kejian Yan <yankejian@huawei.com>, Felipe Balbi <felipe.balbi@linux.intel.com>,
 Russell King <linux@armlinux.org.uk>, Jarod Wilson <jarod@redhat.com>,
 linux-hippi@sunsite.dk, Daode Huang <huangdaode@hisilicon.com>,
 linux-serial@vger.kernel.org, Jiri Slaby <jslaby@s
To: Kees Cook <keescook@chromium.org>,
 Andrew Morton <akpm@linux-foundation.org>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <20170405214711.GA5711@beast>
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

T24gVGh1LCAwNiBBcHIgMjAxNywgS2VlcyBDb29rIDxrZWVzY29va0BjaHJvbWl1bS5vcmc+IHdy
b3RlOgo+IFdoaWxlIGV4YW1pbmluZyBvdXRwdXQgZnJvbSB0cmlhbCBidWlsZHMgd2l0aCAtV2Zv
cm1hdC1zZWN1cml0eSBlbmFibGVkLAo+IG1hbnkgc3RyaW5ncyB3ZXJlIGZvdW5kIHRoYXQgc2hv
dWxkIGJlIGRlZmluZWQgYXMgImNvbnN0Iiwgb3IgYXMgYSBjaGFyCj4gYXJyYXkgaW5zdGVhZCBv
ZiBjaGFyIHBvaW50ZXIuIFRoaXMgbWFrZXMgc29tZSBzdGF0aWMgYW5hbHlzaXMgZWFzaWVyLAo+
IGJ5IHByb2R1Y2luZyBmZXdlciBmYWxzZSBwb3NpdGl2ZXMuCj4KPiBBcyB0aGVzZSBhcmUgYWxs
IHRyaXZpYWwgY2hhbmdlcywgaXQgc2VlbWVkIGJlc3QgdG8gcHV0IHRoZW0gYWxsIGluCj4gYSBz
aW5nbGUgcGF0Y2ggcmF0aGVyIHRoYW4gY2hvcHBpbmcgdGhlbSB1cCBwZXIgbWFpbnRhaW5lci4K
Cj4gZGlmZiAtLWdpdCBhL2RyaXZlcnMvZ3B1L2RybS9kcm1fZmJfaGVscGVyLmMgYi9kcml2ZXJz
L2dwdS9kcm0vZHJtX2ZiX2hlbHBlci5jCj4gaW5kZXggZjZkNGQ5NzAwNzM0Li4xZmY5ZDU5MTJi
ODMgMTAwNjQ0Cj4gLS0tIGEvZHJpdmVycy9ncHUvZHJtL2RybV9mYl9oZWxwZXIuYwo+ICsrKyBi
L2RyaXZlcnMvZ3B1L2RybS9kcm1fZmJfaGVscGVyLmMKPiBAQCAtMjMzMSw3ICsyMzMxLDcgQEAg
RVhQT1JUX1NZTUJPTChkcm1fZmJfaGVscGVyX2hvdHBsdWdfZXZlbnQpOwo+ICBpbnQgX19pbml0
IGRybV9mYl9oZWxwZXJfbW9kaW5pdCh2b2lkKQo+ICB7Cj4gICNpZiBkZWZpbmVkKENPTkZJR19G
UkFNRUJVRkZFUl9DT05TT0xFX01PRFVMRSkgJiYgIWRlZmluZWQoQ09ORklHX0VYUEVSVCkKPiAt
CWNvbnN0IGNoYXIgKm5hbWUgPSAiZmJjb24iOwo+ICsJY29uc3QgY2hhciBuYW1lW10gPSAiZmJj
b24iOwoKSSdkIGFsd2F5cyB3cml0ZSB0aGUgZm9ybWVyIG91dCBvZiBoYWJpdC4gV2h5IHNob3Vs
ZCBJIHN0YXJ0IHVzaW5nIHRoZQpsYXR0ZXI/IFdoYXQgbWFrZXMgaXQgYmV0dGVyPwoKV2hhdCBr
ZWVwcyB0aGUga2VybmVsIGZyb20gYWNjdW11bGF0aW5nIHRvbnMgbW9yZSBvZiB0aGUgZm9ybWVy
PwoKSGVyZSdzIGFuIGludGVyZXN0aW5nIGNvbXBhcmlzb24gb2YgdGhlIGdlbmVyYXRlZCBjb2Rl
LiBJJ20gYSBiaXQKc3VycHJpc2VkIGJ5IHdoYXQgZ2NjIGRvZXMsIEkgd291bGQgaGF2ZSBleHBl
Y3RlZCBubyBkaWZmZXJlbmNlLCBsaWtlCmNsYW5nLiBodHRwczovL2dvZGJvbHQub3JnL2cvT2Rx
VXZOCgpUaGUgb3RoZXIgY2hhbmdlcyBhZGRpbmcgY29uc3QgaW4gdGhpcyBwYXRjaCBhcmUsIG9m
IGNvdXJzZSwgZ29vZC4KCgpCUiwKSmFuaS4KCi0tIApKYW5pIE5pa3VsYSwgSW50ZWwgT3BlbiBT
b3VyY2UgVGVjaG5vbG9neSBDZW50ZXIKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX18KZHJpLWRldmVsIG1haWxpbmcgbGlzdApkcmktZGV2ZWxAbGlzdHMuZnJl
ZWRlc2t0b3Aub3JnCmh0dHBzOi8vbGlzdHMuZnJlZWRlc2t0b3Aub3JnL21haWxtYW4vbGlzdGlu
Zm8vZHJpLWRldmVsCg==
