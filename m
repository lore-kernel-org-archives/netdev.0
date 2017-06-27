From: Dave Airlie <airlied@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH v2 1/1] e1000e: Undo e1000e_pm_freeze if
 __e1000_shutdown fails
Date: Wed, 28 Jun 2017 05:28:42 +1000
Message-ID: <CAPM=9tzdpEDoMNYj7Z_ZM3Z0JsCpjfNW1Z+y-1p5z3HssJ5aaw@mail.gmail.com>
References: <20170531.110833.1362264472730468352.davem@davemloft.net>
 <20170531155043.3596-1-jani.nikula@intel.com>
 <20170531155043.3596-2-jani.nikula@intel.com>
 <20170602.141426.713378366601051907.davem@davemloft.net>
 <1496781986.86439.3.camel@intel.com>
 <309B89C4C689E141A5FF6A0C5FB2118B8C61D137@ORSMSX101.amr.corp.intel.com>
 <20170620084958.7fxdn57p3o6eexbj@phenom.ffwll.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "daniel.vetter@ffwll.ch" <daniel.vetter@ffwll.ch>
To: "Brown, Aaron F" <aaron.f.brown@intel.com>,
 "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
 David Miller <davem@davemloft.net>,
 "Nikula, Jani" <jani.nikula@intel.com>, "Ursulin,
 Tvrtko" <tvrtko.ursulin@intel.com>,
 "intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "jani.nikula@linux.intel.com" <jani.nikula@linux.intel.com>,
 "chris@chris-wilson.co.uk" <chris@chris-wilson.co.uk>, "Ertman,
 David M" <david.m.ertman@intel.com>,
 "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "airlied@gmail.com" <airlied@gmail.com>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <20170620084958.7fxdn57p3o6eexbj@phenom.ffwll.local>
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

T24gMjAgSnVuZSAyMDE3IGF0IDE4OjQ5LCBEYW5pZWwgVmV0dGVyIDxkYW5pZWxAZmZ3bGwuY2g+
IHdyb3RlOgo+IE9uIFdlZCwgSnVuIDA3LCAyMDE3IGF0IDAxOjA3OjMzQU0gKzAwMDAsIEJyb3du
LCBBYXJvbiBGIHdyb3RlOgo+PiA+IEZyb206IEludGVsLXdpcmVkLWxhbiBbbWFpbHRvOmludGVs
LXdpcmVkLWxhbi1ib3VuY2VzQG9zdW9zbC5vcmddIE9uIEJlaGFsZgo+PiA+IE9mIEplZmYgS2ly
c2hlcgo+PiA+IFNlbnQ6IFR1ZXNkYXksIEp1bmUgNiwgMjAxNyAxOjQ2IFBNCj4+ID4gVG86IERh
dmlkIE1pbGxlciA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD47IE5pa3VsYSwgSmFuaQo+PiA+IDxqYW5p
Lm5pa3VsYUBpbnRlbC5jb20+Cj4+ID4gQ2M6IFVyc3VsaW4sIFR2cnRrbyA8dHZydGtvLnVyc3Vs
aW5AaW50ZWwuY29tPjsgZGFuaWVsLnZldHRlckBmZndsbC5jaDsgaW50ZWwtCj4+ID4gZ2Z4QGxp
c3RzLmZyZWVkZXNrdG9wLm9yZzsgbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZzsKPj4gPiBq
YW5pLm5pa3VsYUBsaW51eC5pbnRlbC5jb207IGNocmlzQGNocmlzLXdpbHNvbi5jby51azsgRXJ0
bWFuLCBEYXZpZCBNCj4+ID4gPGRhdmlkLm0uZXJ0bWFuQGludGVsLmNvbT47IGludGVsLXdpcmVk
LWxhbkBsaXN0cy5vc3Vvc2wub3JnOyBkcmktCj4+ID4gZGV2ZWxAbGlzdHMuZnJlZWRlc2t0b3Au
b3JnOyBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyBhaXJsaWVkQGdtYWlsLmNvbQo+PiA+IFN1Ympl
Y3Q6IFJlOiBbSW50ZWwtd2lyZWQtbGFuXSBbUEFUQ0ggdjIgMS8xXSBlMTAwMGU6IFVuZG8KPj4g
PiBlMTAwMGVfcG1fZnJlZXplIGlmIF9fZTEwMDBfc2h1dGRvd24gZmFpbHMKPj4gPgo+PiA+IE9u
IEZyaSwgMjAxNy0wNi0wMiBhdCAxNDoxNCAtMDQwMCwgRGF2aWQgTWlsbGVyIHdyb3RlOgo+PiA+
ID4gRnJvbTogSmFuaSBOaWt1bGEgPGphbmkubmlrdWxhQGludGVsLmNvbT4KPj4gPiA+IERhdGU6
IFdlZCwgMzEgTWF5IDIwMTcgMTg6NTA6NDMgKzAzMDAKPj4gPiA+Cj4+ID4gPiA+IEZyb206IENo
cmlzIFdpbHNvbiA8Y2hyaXNAY2hyaXMtd2lsc29uLmNvLnVrPgo+PiA+ID4gPgo+PiA+ID4gPiBB
biBlcnJvciBkdXJpbmcgc3VzcGVuZCAoZTEwMGVfcG1fc3VzcGVuZCksCj4+ID4gPgo+PiA+ID4g
IC4uLgo+PiA+ID4gPiBsZWFkIHRvIGNvbXBsZXRlIGZhaWx1cmU6Cj4+ID4gPgo+PiA+ID4gIC4u
Lgo+PiA+ID4gPiBUaGUgdW53aW5kIGZhaWx1cmVzIHN0ZW1zIGZyb20gY29tbWl0IDI4MDAyMDk5
OTRmOCAoImUxMDAwZToKPj4gPiA+ID4gUmVmYWN0b3IgUE0KPj4gPiA+ID4gZmxvd3MiKSwgYnV0
IGl0IG1heSBiZSBhIGxhdGVyIHBhdGNoIHRoYXQgaW50cm9kdWNlZCB0aGUgbm9uLQo+PiA+ID4g
PiByZWNvdmVyYWJsZQo+PiA+ID4gPiBiZWhhdmlvdXIuCj4+ID4gPiA+Cj4+ID4gPiA+IEZpeGVz
OiAyODAwMjA5OTk0ZjggKCJlMTAwMGU6IFJlZmFjdG9yIFBNIGZsb3dzIikKPj4gPiA+ID4gQnVn
emlsbGE6IGh0dHBzOi8vYnVncy5mcmVlZGVza3RvcC5vcmcvc2hvd19idWcuY2dpP2lkPTk5ODQ3
Cj4+ID4gPiA+IENjOiBUdnJ0a28gVXJzdWxpbiA8dHZydGtvLnVyc3VsaW5AaW50ZWwuY29tPgo+
PiA+ID4gPiBDYzogSmVmZiBLaXJzaGVyIDxqZWZmcmV5LnQua2lyc2hlckBpbnRlbC5jb20+Cj4+
ID4gPiA+IENjOiBEYXZlIEVydG1hbiA8ZGF2aWR4Lm0uZXJ0bWFuQGludGVsLmNvbT4KPj4gPiA+
ID4gQ2M6IEJydWNlIEFsbGFuIDxicnVjZS53LmFsbGFuQGludGVsLmNvbT4KPj4gPiA+ID4gQ2M6
IGludGVsLXdpcmVkLWxhbkBsaXN0cy5vc3Vvc2wub3JnCj4+ID4gPiA+IENjOiBuZXRkZXZAdmdl
ci5rZXJuZWwub3JnCj4+ID4gPiA+IFNpZ25lZC1vZmYtYnk6IENocmlzIFdpbHNvbiA8Y2hyaXNA
Y2hyaXMtd2lsc29uLmNvLnVrPgo+PiA+ID4gPiBbSmFuaTogYmlrZXNoZWQgcmVwYWludGVkXQo+
PiA+ID4gPiBTaWduZWQtb2ZmLWJ5OiBKYW5pIE5pa3VsYSA8amFuaS5uaWt1bGFAaW50ZWwuY29t
Pgo+PiA+ID4KPj4gPiA+IEplZmYsIHBsZWFzZSBtYWtlIHN1cmUgdGhpcyBnZXRzIHN1Ym1pdHRl
ZCB0byBtZSBzb29uLgo+PiA+Cj4+ID4gRXhwZWN0IGl0IGxhdGVyIHRvbmlnaHQsIGp1c3QgZmlu
aXNoaW5nIHVwIHRlc3RpbmcuCj4+Cj4+IFRlc3RlZC1ieTogQWFyb24gQnJvd24gPGFhcm9uLmYu
YnJvd25AaW50ZWwuY29tPgo+Cj4gSG0sIEkgc2VlbSB0byBiZSBibGluZCwgYnV0IEkgY2FuJ3Qg
ZmluZCBpdCBhbnl3aGVyZSBpbiAtcmM2LiBEb2VzIHNvbWVvbmUKPiBoYXZlIHRoZSBzaGExIGZy
b20gTGludXMnIGdpdCBmb3IgdGhpcyBwYXRjaD8KCkd1eXMgdGhpcyBpcyBhIHByZXR0eSBzZXJp
b3VzIHJlZ3Jlc3Npb24sIGp1c3QgbGVmdCBibG93aW5nIGluIHRoZQp3aW5kLCBpcyBhbnlvbmUg
cmVzcG9uc2libGUgZm9yIGUxMDAwZT8KCkRhdmUuCl9fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fCmRyaS1kZXZlbCBtYWlsaW5nIGxpc3QKZHJpLWRldmVsQGxp
c3RzLmZyZWVkZXNrdG9wLm9yZwpodHRwczovL2xpc3RzLmZyZWVkZXNrdG9wLm9yZy9tYWlsbWFu
L2xpc3RpbmZvL2RyaS1kZXZlbAo=
