From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH v2 1/1] e1000e: Undo
 e1000e_pm_freeze if __e1000_shutdown fails
Date: Wed, 7 Jun 2017 01:07:33 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C61D137@ORSMSX101.amr.corp.intel.com>
References: <20170531.110833.1362264472730468352.davem@davemloft.net>
 <20170531155043.3596-1-jani.nikula@intel.com>
 <20170531155043.3596-2-jani.nikula@intel.com>
 <20170602.141426.713378366601051907.davem@davemloft.net>
 <1496781986.86439.3.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "daniel.vetter@ffwll.ch" <daniel.vetter@ffwll.ch>,
 "intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Ertman,
 David M" <david.m.ertman@intel.com>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>, David Miller
 <davem@davemloft.net>, "Nikula, Jani" <jani.nikula@intel.com>
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
In-Reply-To: <1496781986.86439.3.camel@intel.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.freedesktop.org/mailman/options/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <https://lists.freedesktop.org/archives/intel-gfx>
List-Post: <mailto:intel-gfx@lists.freedesktop.org>
List-Help: <mailto:intel-gfx-request@lists.freedesktop.org?subject=help>
List-Subscribe: <https://lists.freedesktop.org/mailman/listinfo/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=subscribe>
Errors-To: intel-gfx-bounces@lists.freedesktop.org
Sender: "Intel-gfx" <intel-gfx-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

PiBGcm9tOiBJbnRlbC13aXJlZC1sYW4gW21haWx0bzppbnRlbC13aXJlZC1sYW4tYm91bmNlc0Bv
c3Vvc2wub3JnXSBPbiBCZWhhbGYNCj4gT2YgSmVmZiBLaXJzaGVyDQo+IFNlbnQ6IFR1ZXNkYXks
IEp1bmUgNiwgMjAxNyAxOjQ2IFBNDQo+IFRvOiBEYXZpZCBNaWxsZXIgPGRhdmVtQGRhdmVtbG9m
dC5uZXQ+OyBOaWt1bGEsIEphbmkNCj4gPGphbmkubmlrdWxhQGludGVsLmNvbT4NCj4gQ2M6IFVy
c3VsaW4sIFR2cnRrbyA8dHZydGtvLnVyc3VsaW5AaW50ZWwuY29tPjsgZGFuaWVsLnZldHRlckBm
ZndsbC5jaDsgaW50ZWwtDQo+IGdmeEBsaXN0cy5mcmVlZGVza3RvcC5vcmc7IGxpbnV4LWtlcm5l
bEB2Z2VyLmtlcm5lbC5vcmc7DQo+IGphbmkubmlrdWxhQGxpbnV4LmludGVsLmNvbTsgY2hyaXNA
Y2hyaXMtd2lsc29uLmNvLnVrOyBFcnRtYW4sIERhdmlkIE0NCj4gPGRhdmlkLm0uZXJ0bWFuQGlu
dGVsLmNvbT47IGludGVsLXdpcmVkLWxhbkBsaXN0cy5vc3Vvc2wub3JnOyBkcmktDQo+IGRldmVs
QGxpc3RzLmZyZWVkZXNrdG9wLm9yZzsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsgYWlybGllZEBn
bWFpbC5jb20NCj4gU3ViamVjdDogUmU6IFtJbnRlbC13aXJlZC1sYW5dIFtQQVRDSCB2MiAxLzFd
IGUxMDAwZTogVW5kbw0KPiBlMTAwMGVfcG1fZnJlZXplIGlmIF9fZTEwMDBfc2h1dGRvd24gZmFp
bHMNCj4gDQo+IE9uIEZyaSwgMjAxNy0wNi0wMiBhdCAxNDoxNCAtMDQwMCwgRGF2aWQgTWlsbGVy
IHdyb3RlOg0KPiA+IEZyb206IEphbmkgTmlrdWxhIDxqYW5pLm5pa3VsYUBpbnRlbC5jb20+DQo+
ID4gRGF0ZTogV2VkLCAzMSBNYXkgMjAxNyAxODo1MDo0MyArMDMwMA0KPiA+DQo+ID4gPiBGcm9t
OiBDaHJpcyBXaWxzb24gPGNocmlzQGNocmlzLXdpbHNvbi5jby51az4NCj4gPiA+DQo+ID4gPiBB
biBlcnJvciBkdXJpbmcgc3VzcGVuZCAoZTEwMGVfcG1fc3VzcGVuZCksDQo+ID4NCj4gPiAgLi4u
DQo+ID4gPiBsZWFkIHRvIGNvbXBsZXRlIGZhaWx1cmU6DQo+ID4NCj4gPiAgLi4uDQo+ID4gPiBU
aGUgdW53aW5kIGZhaWx1cmVzIHN0ZW1zIGZyb20gY29tbWl0IDI4MDAyMDk5OTRmOCAoImUxMDAw
ZToNCj4gPiA+IFJlZmFjdG9yIFBNDQo+ID4gPiBmbG93cyIpLCBidXQgaXQgbWF5IGJlIGEgbGF0
ZXIgcGF0Y2ggdGhhdCBpbnRyb2R1Y2VkIHRoZSBub24tDQo+ID4gPiByZWNvdmVyYWJsZQ0KPiA+
ID4gYmVoYXZpb3VyLg0KPiA+ID4NCj4gPiA+IEZpeGVzOiAyODAwMjA5OTk0ZjggKCJlMTAwMGU6
IFJlZmFjdG9yIFBNIGZsb3dzIikNCj4gPiA+IEJ1Z3ppbGxhOiBodHRwczovL2J1Z3MuZnJlZWRl
c2t0b3Aub3JnL3Nob3dfYnVnLmNnaT9pZD05OTg0Nw0KPiA+ID4gQ2M6IFR2cnRrbyBVcnN1bGlu
IDx0dnJ0a28udXJzdWxpbkBpbnRlbC5jb20+DQo+ID4gPiBDYzogSmVmZiBLaXJzaGVyIDxqZWZm
cmV5LnQua2lyc2hlckBpbnRlbC5jb20+DQo+ID4gPiBDYzogRGF2ZSBFcnRtYW4gPGRhdmlkeC5t
LmVydG1hbkBpbnRlbC5jb20+DQo+ID4gPiBDYzogQnJ1Y2UgQWxsYW4gPGJydWNlLncuYWxsYW5A
aW50ZWwuY29tPg0KPiA+ID4gQ2M6IGludGVsLXdpcmVkLWxhbkBsaXN0cy5vc3Vvc2wub3JnDQo+
ID4gPiBDYzogbmV0ZGV2QHZnZXIua2VybmVsLm9yZw0KPiA+ID4gU2lnbmVkLW9mZi1ieTogQ2hy
aXMgV2lsc29uIDxjaHJpc0BjaHJpcy13aWxzb24uY28udWs+DQo+ID4gPiBbSmFuaTogYmlrZXNo
ZWQgcmVwYWludGVkXQ0KPiA+ID4gU2lnbmVkLW9mZi1ieTogSmFuaSBOaWt1bGEgPGphbmkubmlr
dWxhQGludGVsLmNvbT4NCj4gPg0KPiA+IEplZmYsIHBsZWFzZSBtYWtlIHN1cmUgdGhpcyBnZXRz
IHN1Ym1pdHRlZCB0byBtZSBzb29uLg0KPiANCj4gRXhwZWN0IGl0IGxhdGVyIHRvbmlnaHQsIGp1
c3QgZmluaXNoaW5nIHVwIHRlc3RpbmcuDQoNClRlc3RlZC1ieTogQWFyb24gQnJvd24gPGFhcm9u
LmYuYnJvd25AaW50ZWwuY29tPg0KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX18KSW50ZWwtZ2Z4IG1haWxpbmcgbGlzdApJbnRlbC1nZnhAbGlzdHMuZnJlZWRl
c2t0b3Aub3JnCmh0dHBzOi8vbGlzdHMuZnJlZWRlc2t0b3Aub3JnL21haWxtYW4vbGlzdGluZm8v
aW50ZWwtZ2Z4Cg==
