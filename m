From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: Re: [PATCH] ixgbevf: delete unneeded call to pci_set_power_state
Date: Tue, 21 Jan 2014 20:47:17 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B7314262D@ORSMSX101.amr.corp.intel.com>
References: <1389114026-27854-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Julia.Lawall@lip6.fr" <Julia.Lawall@lip6.fr>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1389114026-27854-1-git-send-email-Julia.Lawall@lip6.fr>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T24gVHVlLCAyMDE0LTAxLTA3IGF0IDE4OjAwICswMTAwLCBKdWxpYSBMYXdhbGwgd3JvdGU6Cj4g
RnJvbTogSnVsaWEgTGF3YWxsIDxKdWxpYS5MYXdhbGxAbGlwNi5mcj4KPiAKPiBUaGlzIGRyaXZl
ciBkb2VzIG5vdCBuZWVkIHRvIGFkanVzdCB0aGUgcG93ZXIgc3RhdGUgb24gc3VzcGVuZCwgc28g
dGhlCj4gY2FsbCB0byBwY2lfc2V0X3Bvd2VyX3N0YXRlIGluIHRoZSByZXN1bWUgZnVuY3Rpb24g
aXMgYSBuby1vcC4gIERyb3AgaXQsIHRvCj4gbWFrZSB0aGUgY29kZSBtb3JlIHVuZGVyc3RhbmRh
YmxlLgo+IAo+IFNpZ25lZC1vZmYtYnk6IEp1bGlhIExhd2FsbCA8SnVsaWEuTGF3YWxsQGxpcDYu
ZnI+ClRlc3RlZC1ieTogUGhpbCBTY2htaXR0IDxwaGlsbGlwLmouc2NobWl0dEBpbnRlbC5jb20+
ClNpZ25lZC1vZmYtYnk6IEFhcm9uIEJyb3duIDxhYXJvbi5mLmJyb3duQGludGVsLmNvbT4KCj4g
LS0tCj4gIGRyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2l4Z2JldmYvaXhnYmV2Zl9tYWluLmMg
fCAgICAxIC0KPiAgMSBmaWxlIGNoYW5nZWQsIDEgZGVsZXRpb24oLSkKPiAKPiBkaWZmIC0tZ2l0
IGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaXhnYmV2Zi9peGdiZXZmX21haW4uYyBiL2Ry
aXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2l4Z2JldmYvaXhnYmV2Zl9tYWluLmMKPiBpbmRleCBh
NWQzMTY3Li41NzA5ZmIwIDEwMDY0NAo+IC0tLSBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVs
L2l4Z2JldmYvaXhnYmV2Zl9tYWluLmMKPiArKysgYi9kcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRl
bC9peGdiZXZmL2l4Z2JldmZfbWFpbi5jCj4gQEAgLTMyMjYsNyArMzIyNiw2IEBAIHN0YXRpYyBp
bnQgaXhnYmV2Zl9yZXN1bWUoc3RydWN0IHBjaV9kZXYgKnBkZXYpCj4gIAlzdHJ1Y3QgbmV0X2Rl
dmljZSAqbmV0ZGV2ID0gYWRhcHRlci0+bmV0ZGV2Owo+ICAJdTMyIGVycjsKPiAgCj4gLQlwY2lf
c2V0X3Bvd2VyX3N0YXRlKHBkZXYsIFBDSV9EMCk7Cj4gIAlwY2lfcmVzdG9yZV9zdGF0ZShwZGV2
KTsKPiAgCS8qCj4gIAkgKiBwY2lfcmVzdG9yZV9zdGF0ZSBjbGVhcnMgZGV2LT5zdGF0ZV9zYXZl
ZCBzbyBjYWxsCj4gCj4gLS0KPiBUbyB1bnN1YnNjcmliZSBmcm9tIHRoaXMgbGlzdDogc2VuZCB0
aGUgbGluZSAidW5zdWJzY3JpYmUgbmV0ZGV2IiBpbgo+IHRoZSBib2R5IG9mIGEgbWVzc2FnZSB0
byBtYWpvcmRvbW9Admdlci5rZXJuZWwub3JnCj4gTW9yZSBtYWpvcmRvbW8gaW5mbyBhdCAgaHR0
cDovL3ZnZXIua2VybmVsLm9yZy9tYWpvcmRvbW8taW5mby5odG1sCgoK
