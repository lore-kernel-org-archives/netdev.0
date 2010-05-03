From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgb and e1000: Use new function for
	copybreak tests
Date: Mon, 3 May 2010 13:43:01 -0700
Message-ID: <m2z9929d2391005031343yab3aa87amc3811252493dcddb@mail.gmail.com>
References: <1272847591.30040.15.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	LKML <linux-kernel@vger.kernel.org>, John Ronciak <john.ronciak@intel.com>
To: Joe Perches <joe@perches.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1272847591.30040.15.camel@Joe-Laptop.home>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

T24gU3VuLCBNYXkgMiwgMjAxMCBhdCAxNzo0NiwgSm9lIFBlcmNoZXMgPGpvZUBwZXJjaGVzLmNv
bT4gd3JvdGU6Cj4gVGhlcmUgYXBwZWFycyB0byBiZSBhbiBvZmYtYnktMSBkZWZlY3QgaW4gdGhl
IG1heGltdW0gcGFja2V0IHNpemUKPiBjb3BpZWQgd2hlbiBjb3B5YnJlYWsgaXMgc3BlaWZpZWQg
aW4gdGhlc2UgbW9kdWxlcy4KPgo+IFRoZSBjb3B5YnJlYWsgbW9kdWxlIHBhcmFtcyBhcmUgc3Bl
Y2lmaWVkIGFzOgo+ICJNYXhpbXVtIHNpemUgb2YgcGFja2V0IHRoYXQgaXMgY29waWVkIHRvIGEg
bmV3IGJ1ZmZlciBvbiByZWNlaXZlIgo+Cj4gVGhlIHRlc3RzIGFyZSBjaGFuZ2VkIGZyb20gIjwg
Y29weWJyZWFrIiB0byAiPD0gY29weWJyZWFrIgo+IGFuZCBtb3ZlZCBpbnRvIG5ldyBzdGF0aWMg
ZnVuY3Rpb25zIGZvciByZWFkYWJpbGl0eS4KPgo+IFNpZ25lZC1vZmYtYnk6IEpvZSBQZXJjaGVz
IDxqb2VAcGVyY2hlcy5jb20+Cj4gLS0tCj4gwqBkcml2ZXJzL25ldC9lMTAwMC9lMTAwMF9tYWlu
LmMgfCDCoCA0NyArKysrKysrKysrKysrKysrKysrKy0tLS0tLS0tLS0tLS0tLQo+IMKgZHJpdmVy
cy9uZXQvaXhnYi9peGdiX21haW4uYyDCoCB8IMKgIDUyICsrKysrKysrKysrKysrKysrKysrKysr
LS0tLS0tLS0tLS0tLS0tLQo+IMKgMiBmaWxlcyBjaGFuZ2VkLCA1OCBpbnNlcnRpb25zKCspLCA0
MSBkZWxldGlvbnMoLSkKPgoKVGhhbmtzIEpvZSwgSSBoYXZlIGFkZGVkIHRoZSBwYXRjaCB0byBt
eSBxdWV1ZSBvZiBwYXRjaGVzLgoKLS0gCkNoZWVycywKSmVmZgoKLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCkUxMDAw
LWRldmVsIG1haWxpbmcgbGlzdApFMTAwMC1kZXZlbEBsaXN0cy5zb3VyY2Vmb3JnZS5uZXQKaHR0
cHM6Ly9saXN0cy5zb3VyY2Vmb3JnZS5uZXQvbGlzdHMvbGlzdGluZm8vZTEwMDAtZGV2ZWwKVG8g
bGVhcm4gbW9yZSBhYm91dCBJbnRlbCYjMTc0OyBFdGhlcm5ldCwgdmlzaXQgaHR0cDovL2NvbW11
bml0aWVzLmludGVsLmNvbS9jb21tdW5pdHkvd2lyZWQK
