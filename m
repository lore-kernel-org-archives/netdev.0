From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] e1000e: Undo e1000e_pm_freeze if
 __e1000_shutdown fails
Date: Fri, 02 Jun 2017 14:14:26 -0400 (EDT)
Message-ID: <20170602.141426.713378366601051907.davem@davemloft.net>
References: <20170531.110833.1362264472730468352.davem@davemloft.net>
 <20170531155043.3596-1-jani.nikula@intel.com>
 <20170531155043.3596-2-jani.nikula@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: daniel.vetter@ffwll.ch, intel-gfx@lists.freedesktop.org,
 bruce.w.allan@intel.com, linux-kernel@vger.kernel.org,
 davidx.m.ertman@intel.com, intel-wired-lan@lists.osuosl.org,
 dri-devel@lists.freedesktop.org, netdev@vger.kernel.org,
 jeffrey.t.kirsher@intel.com
To: jani.nikula@intel.com
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
In-Reply-To: <20170531155043.3596-2-jani.nikula@intel.com>
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

RnJvbTogSmFuaSBOaWt1bGEgPGphbmkubmlrdWxhQGludGVsLmNvbT4KRGF0ZTogV2VkLCAzMSBN
YXkgMjAxNyAxODo1MDo0MyArMDMwMAoKPiBGcm9tOiBDaHJpcyBXaWxzb24gPGNocmlzQGNocmlz
LXdpbHNvbi5jby51az4KPiAKPiBBbiBlcnJvciBkdXJpbmcgc3VzcGVuZCAoZTEwMGVfcG1fc3Vz
cGVuZCksCiAuLi4KPiBsZWFkIHRvIGNvbXBsZXRlIGZhaWx1cmU6CiAuLi4KPiBUaGUgdW53aW5k
IGZhaWx1cmVzIHN0ZW1zIGZyb20gY29tbWl0IDI4MDAyMDk5OTRmOCAoImUxMDAwZTogUmVmYWN0
b3IgUE0KPiBmbG93cyIpLCBidXQgaXQgbWF5IGJlIGEgbGF0ZXIgcGF0Y2ggdGhhdCBpbnRyb2R1
Y2VkIHRoZSBub24tcmVjb3ZlcmFibGUKPiBiZWhhdmlvdXIuCj4gCj4gRml4ZXM6IDI4MDAyMDk5
OTRmOCAoImUxMDAwZTogUmVmYWN0b3IgUE0gZmxvd3MiKQo+IEJ1Z3ppbGxhOiBodHRwczovL2J1
Z3MuZnJlZWRlc2t0b3Aub3JnL3Nob3dfYnVnLmNnaT9pZD05OTg0Nwo+IENjOiBUdnJ0a28gVXJz
dWxpbiA8dHZydGtvLnVyc3VsaW5AaW50ZWwuY29tPgo+IENjOiBKZWZmIEtpcnNoZXIgPGplZmZy
ZXkudC5raXJzaGVyQGludGVsLmNvbT4KPiBDYzogRGF2ZSBFcnRtYW4gPGRhdmlkeC5tLmVydG1h
bkBpbnRlbC5jb20+Cj4gQ2M6IEJydWNlIEFsbGFuIDxicnVjZS53LmFsbGFuQGludGVsLmNvbT4K
PiBDYzogaW50ZWwtd2lyZWQtbGFuQGxpc3RzLm9zdW9zbC5vcmcKPiBDYzogbmV0ZGV2QHZnZXIu
a2VybmVsLm9yZwo+IFNpZ25lZC1vZmYtYnk6IENocmlzIFdpbHNvbiA8Y2hyaXNAY2hyaXMtd2ls
c29uLmNvLnVrPgo+IFtKYW5pOiBiaWtlc2hlZCByZXBhaW50ZWRdCj4gU2lnbmVkLW9mZi1ieTog
SmFuaSBOaWt1bGEgPGphbmkubmlrdWxhQGludGVsLmNvbT4KCkplZmYsIHBsZWFzZSBtYWtlIHN1
cmUgdGhpcyBnZXRzIHN1Ym1pdHRlZCB0byBtZSBzb29uLgoKVGhhbmtzLgpfX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpJbnRlbC1nZnggbWFpbGluZyBsaXN0
CkludGVsLWdmeEBsaXN0cy5mcmVlZGVza3RvcC5vcmcKaHR0cHM6Ly9saXN0cy5mcmVlZGVza3Rv
cC5vcmcvbWFpbG1hbi9saXN0aW5mby9pbnRlbC1nZngK
