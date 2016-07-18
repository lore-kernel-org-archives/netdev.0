From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [RFC PATCH 00/30] Kernel NET policy
Date: Mon, 18 Jul 2016 20:14:15 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F07712C19852@SHSMSX103.ccr.corp.intel.com>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
 <20160718151841.GA19066@breakpoint.cc>
 <20160718154512.GK5871@two.firstfloor.org>
 <CAM_iQpVRfoC0e43Pbsw8Q3RsyDDnMZeGu=oS0iVvAfMNwz6DeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	"Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	"Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	John Stultz <john.stultz@linaro.org>,
	Alex Duyck <aduyck@mirantis.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"decot@googlers.com" <decot@googlers.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpVRfoC0e43Pbsw8Q3RsyDDnMZeGu=oS0iVvAfMNwz6DeA@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DQoNCj4gDQo+IE9uIE1vbiwgSnVsIDE4LCAyMDE2IGF0IDg6NDUgQU0sIEFuZGkgS2xlZW4gPGFu
ZGlAZmlyc3RmbG9vci5vcmc+IHdyb3RlOg0KPiA+PiBJdCBzZWVtcyBzdHJhbmdlIHRvIG1lIHRv
IGFkZCBzdWNoIHBvbGljaWVzIHRvIHRoZSBrZXJuZWwuDQo+ID4+IEFkZG1pdHRpbmdseSwgZG9j
dW1lbnRhdGlvbiBvZiBzb21lIHNldHRpbmdzIGlzIG5vbi1leGlzdGVudCBhbmQgb25lDQo+ID4+
IG5lZWRzIHZhcmlvdXMgZGlmZmVyZW50IHRvb2xzIHRvIHNldCB0aGlzIChzeXNjdGwsIHByb2Nm
cywgc3lzZnMsIGV0aHRvb2wsIGV0YykuDQo+ID4NCj4gPiBUaGUgcHJvYmxlbSBpcyB0aGF0IGRp
ZmZlcmVudCBhcHBsaWNhdGlvbnMgbmVlZCBkaWZmZXJlbnQgcG9saWNpZXMuDQo+ID4NCj4gPiBU
aGUgb25seSBlbnRpdHkgd2hpY2ggY2FuIGVmZmljaWVudGx5IG5lZ290aWF0ZSBiZXR3ZWVuIGRp
ZmZlcmVudA0KPiA+IGFwcGxpY2F0aW9ucycgY29uZmxpY3RpbmcgcmVxdWVzdHMgaXMgdGhlIGtl
cm5lbC4gQW5kIHRoYXQgaXMgcHJldHR5DQo+ID4gbXVjaCB0aGUgYmFzaWMgam9iIGRlc2NyaXB0
aW9uIG9mIGEga2VybmVsOiBtdWx0aXBsZXggaGFyZHdhcmUNCj4gPiBlZmZpY2llbnRseSBiZXR3
ZWVuIGRpZmZlcmVudCB1c2Vycy4NCj4gPg0KPiA+IFNvIHllcyB0aGUgdXNlciBzcGFjZSB0dW5p
bmcgYXBwcm9hY2ggd29ya3MgZm9yIHNpbXBsZSBjYXNlcyAoIm9ubHkNCj4gPiBydW4gd29ya2xv
YWRzIHRoYXQgcmVxdWlyZSB0aGUgc2FtZSB0dW5pbmciKSwgYnV0IGlzIHVsdGltYXRlbHkgbm90
DQo+ID4gdmVyeSBpbnRlcmVzdGluZyBub3Igc2NhbGFibGUuDQo+IA0KPiBJIGRvbid0IHJlYWQg
dGhlIGNvZGUgeWV0LCBqdXN0IHRoZSBjb3ZlciBsZXR0ZXIuDQo+IA0KPiBXZSBoYXZlIGdsb2Jh
bCB0dW5pbmdzLCBwZXItbmV0d29yay1uYW1lc3BhY2UgdHVuaW5ncywgcGVyLXNvY2tldCB0dW5p
bmdzLg0KPiBJdCBpcyBzdGlsbCB1bmNsZWFyIHdoeSB5b3UgY2FuJ3QganVzdCBwdXQgZGlmZmVy
ZW50IGFwcGxpY2F0aW9ucyBpbnRvIGRpZmZlcmVudA0KPiBuYW1lc3BhY2VzL2NvbnRhaW5lcnMg
dG8gZ2V0IGRpZmZlcmVudCBwb2xpY2llcy4NCg0KSW4gTkVUIHBvbGljeSwgd2UgZG8gcGVyIHF1
ZXVlIHR1bmluZ3MuDQoNCg0KVGhhbmtzLA0KS2FuDQo=
