From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [Intel-gfx] [PATCH 4/4] drm/i915: Move ioremap_wc tracking onto
 VMA
Date: Wed, 20 Apr 2016 13:17:30 +0200
Message-ID: <20160420111730.GL2510@phenom.ffwll.local>
References: <20160419123028.GI1990@wotan.suse.de>
 <1461069238-31539-1-git-send-email-chris@chris-wilson.co.uk>
 <1461069238-31539-4-git-send-email-chris@chris-wilson.co.uk>
 <20160420091054.GL1990@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Hildenbrand <dahi@linux.vnet.ibm.com>, netdev@vger.kernel.org,
 intel-gfx@lists.freedesktop.org, linux-kernel@vger.kernel.org,
 dri-devel@lists.freedesktop.org,
 "Peter Zijlstra \(Intel\)" <peterz@infradead.org>,
 Daniel Vetter <daniel.vetter@intel.com>,
 Dan Williams <dan.j.williams@intel.com>, Yishai Hadas <yishaih@mellanox.com>,
 Ingo Molnar <mingo@kernel.org>, linux-rdma@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <20160420091054.GL1990@wotan.suse.de>
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

T24gV2VkLCBBcHIgMjAsIDIwMTYgYXQgMTE6MTA6NTRBTSArMDIwMCwgTHVpcyBSLiBSb2RyaWd1
ZXogd3JvdGU6Cj4gUmVhc29uIEkgYXNrIGlzIHNpbmNlIEkgbm90aWNlZCBhIHdoaWxlIGFnbyBh
IGxvdCBvZiBkcml2ZXJzCj4gd2VyZSB1c2luZyBpbmZvLT5maXguc21lbV9zdGFydCBhbmQgaW5m
by0+Zml4LnNtZW1fbGVuIGNvbnNpc3RlbnRseQo+IGZvciB0aGVpciBpb3JlbWFwJ2QgYXJlYXMg
aXQgbWlnaHQgbWFrZSBzZW5zZSBpbnN0ZWFkIHRvIGxldCB0aGUKPiBpbnRlcm5hbCBmcmFtZWJ1
ZmZlciAocmVnaXN0ZXJfZnJhbWVidWZmZXIoKSkgb3B0aW9uYWxseSBtYW5hZ2UgdGhlCj4gaW9y
ZW1hcF93YygpIGZvciBkcml2ZXJzLCBnaXZlbiB0aGF0IHRoaXMgaXMgcHJldHR5IGdlbmVyaWMg
c3R1ZmYuCgpBbGwgdGhhdCBsZWdhY3kgZmJkZXYgc3R1ZmYgaXMganVzdCBmb3IgbGVnYWN5IHN1
cHBvcnQsIGFuZCBJIHByZWZlciB0bwpoYXZlIHRoYXQgYXMgZHVtYiBhcyBwb3NzaWJsZS4gVGhl
cmUncyBiZWVuIHNvbWUgZGlzY3Vzc2lvbiBldmVuIGFyb3VuZApsaWZ0aW5nIHRoZSAia2ljayBv
dXQgZmlybXdhcmUgZmIgZHJpdmVyIiBvdXQgb2YgZmJkZXYsIHNpbmNlIHdlJ2QgbmVlZCBpdAp0
byBoYXZlIGEgc2ltcGxlIGRybSBkcml2ZXIgZm9yIGUuZy4gdWVmaS4KCkJ1dCBJIGRlZmluaXRl
bHkgZG9uJ3Qgd2FudCBhIGxlZ2FjeSBob3Jyb3Igc2hvdyBsaWtlIGZiZGV2IHRvCmF1dG9tYWdp
Y2FsbHkgdGFrZSBjYXJlIG9mIGRldmljZSBtYXBwaW5ncyBmb3IgZHJpdmVycy4KLURhbmllbAot
LSAKRGFuaWVsIFZldHRlcgpTb2Z0d2FyZSBFbmdpbmVlciwgSW50ZWwgQ29ycG9yYXRpb24KaHR0
cDovL2Jsb2cuZmZ3bGwuY2gKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX18KZHJpLWRldmVsIG1haWxpbmcgbGlzdApkcmktZGV2ZWxAbGlzdHMuZnJlZWRlc2t0
b3Aub3JnCmh0dHBzOi8vbGlzdHMuZnJlZWRlc2t0b3Aub3JnL21haWxtYW4vbGlzdGluZm8vZHJp
LWRldmVsCg==
