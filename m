From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [Intel-wired-lan] [PATCH v2 1/1] e1000e: Undo
 e1000e_pm_freeze if __e1000_shutdown fails
Date: Tue, 20 Jun 2017 10:49:58 +0200
Message-ID: <20170620084958.7fxdn57p3o6eexbj@phenom.ffwll.local>
References: <20170531.110833.1362264472730468352.davem@davemloft.net>
 <20170531155043.3596-1-jani.nikula@intel.com>
 <20170531155043.3596-2-jani.nikula@intel.com>
 <20170602.141426.713378366601051907.davem@davemloft.net>
 <1496781986.86439.3.camel@intel.com>
 <309B89C4C689E141A5FF6A0C5FB2118B8C61D137@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 "Nikula, Jani" <jani.nikula@intel.com>,
 "daniel.vetter@ffwll.ch" <daniel.vetter@ffwll.ch>,
 "intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
 "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Ertman,
 David M" <david.m.ertman@intel.com>, David Miller <davem@davemloft.net>
To: "Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <309B89C4C689E141A5FF6A0C5FB2118B8C61D137@ORSMSX101.amr.corp.intel.com>
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

T24gV2VkLCBKdW4gMDcsIDIwMTcgYXQgMDE6MDc6MzNBTSArMDAwMCwgQnJvd24sIEFhcm9uIEYg
d3JvdGU6Cj4gPiBGcm9tOiBJbnRlbC13aXJlZC1sYW4gW21haWx0bzppbnRlbC13aXJlZC1sYW4t
Ym91bmNlc0Bvc3Vvc2wub3JnXSBPbiBCZWhhbGYKPiA+IE9mIEplZmYgS2lyc2hlcgo+ID4gU2Vu
dDogVHVlc2RheSwgSnVuZSA2LCAyMDE3IDE6NDYgUE0KPiA+IFRvOiBEYXZpZCBNaWxsZXIgPGRh
dmVtQGRhdmVtbG9mdC5uZXQ+OyBOaWt1bGEsIEphbmkKPiA+IDxqYW5pLm5pa3VsYUBpbnRlbC5j
b20+Cj4gPiBDYzogVXJzdWxpbiwgVHZydGtvIDx0dnJ0a28udXJzdWxpbkBpbnRlbC5jb20+OyBk
YW5pZWwudmV0dGVyQGZmd2xsLmNoOyBpbnRlbC0KPiA+IGdmeEBsaXN0cy5mcmVlZGVza3RvcC5v
cmc7IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc7Cj4gPiBqYW5pLm5pa3VsYUBsaW51eC5p
bnRlbC5jb207IGNocmlzQGNocmlzLXdpbHNvbi5jby51azsgRXJ0bWFuLCBEYXZpZCBNCj4gPiA8
ZGF2aWQubS5lcnRtYW5AaW50ZWwuY29tPjsgaW50ZWwtd2lyZWQtbGFuQGxpc3RzLm9zdW9zbC5v
cmc7IGRyaS0KPiA+IGRldmVsQGxpc3RzLmZyZWVkZXNrdG9wLm9yZzsgbmV0ZGV2QHZnZXIua2Vy
bmVsLm9yZzsgYWlybGllZEBnbWFpbC5jb20KPiA+IFN1YmplY3Q6IFJlOiBbSW50ZWwtd2lyZWQt
bGFuXSBbUEFUQ0ggdjIgMS8xXSBlMTAwMGU6IFVuZG8KPiA+IGUxMDAwZV9wbV9mcmVlemUgaWYg
X19lMTAwMF9zaHV0ZG93biBmYWlscwo+ID4gCj4gPiBPbiBGcmksIDIwMTctMDYtMDIgYXQgMTQ6
MTQgLTA0MDAsIERhdmlkIE1pbGxlciB3cm90ZToKPiA+ID4gRnJvbTogSmFuaSBOaWt1bGEgPGph
bmkubmlrdWxhQGludGVsLmNvbT4KPiA+ID4gRGF0ZTogV2VkLCAzMSBNYXkgMjAxNyAxODo1MDo0
MyArMDMwMAo+ID4gPgo+ID4gPiA+IEZyb206IENocmlzIFdpbHNvbiA8Y2hyaXNAY2hyaXMtd2ls
c29uLmNvLnVrPgo+ID4gPiA+Cj4gPiA+ID4gQW4gZXJyb3IgZHVyaW5nIHN1c3BlbmQgKGUxMDBl
X3BtX3N1c3BlbmQpLAo+ID4gPgo+ID4gPiAgLi4uCj4gPiA+ID4gbGVhZCB0byBjb21wbGV0ZSBm
YWlsdXJlOgo+ID4gPgo+ID4gPiAgLi4uCj4gPiA+ID4gVGhlIHVud2luZCBmYWlsdXJlcyBzdGVt
cyBmcm9tIGNvbW1pdCAyODAwMjA5OTk0ZjggKCJlMTAwMGU6Cj4gPiA+ID4gUmVmYWN0b3IgUE0K
PiA+ID4gPiBmbG93cyIpLCBidXQgaXQgbWF5IGJlIGEgbGF0ZXIgcGF0Y2ggdGhhdCBpbnRyb2R1
Y2VkIHRoZSBub24tCj4gPiA+ID4gcmVjb3ZlcmFibGUKPiA+ID4gPiBiZWhhdmlvdXIuCj4gPiA+
ID4KPiA+ID4gPiBGaXhlczogMjgwMDIwOTk5NGY4ICgiZTEwMDBlOiBSZWZhY3RvciBQTSBmbG93
cyIpCj4gPiA+ID4gQnVnemlsbGE6IGh0dHBzOi8vYnVncy5mcmVlZGVza3RvcC5vcmcvc2hvd19i
dWcuY2dpP2lkPTk5ODQ3Cj4gPiA+ID4gQ2M6IFR2cnRrbyBVcnN1bGluIDx0dnJ0a28udXJzdWxp
bkBpbnRlbC5jb20+Cj4gPiA+ID4gQ2M6IEplZmYgS2lyc2hlciA8amVmZnJleS50LmtpcnNoZXJA
aW50ZWwuY29tPgo+ID4gPiA+IENjOiBEYXZlIEVydG1hbiA8ZGF2aWR4Lm0uZXJ0bWFuQGludGVs
LmNvbT4KPiA+ID4gPiBDYzogQnJ1Y2UgQWxsYW4gPGJydWNlLncuYWxsYW5AaW50ZWwuY29tPgo+
ID4gPiA+IENjOiBpbnRlbC13aXJlZC1sYW5AbGlzdHMub3N1b3NsLm9yZwo+ID4gPiA+IENjOiBu
ZXRkZXZAdmdlci5rZXJuZWwub3JnCj4gPiA+ID4gU2lnbmVkLW9mZi1ieTogQ2hyaXMgV2lsc29u
IDxjaHJpc0BjaHJpcy13aWxzb24uY28udWs+Cj4gPiA+ID4gW0phbmk6IGJpa2VzaGVkIHJlcGFp
bnRlZF0KPiA+ID4gPiBTaWduZWQtb2ZmLWJ5OiBKYW5pIE5pa3VsYSA8amFuaS5uaWt1bGFAaW50
ZWwuY29tPgo+ID4gPgo+ID4gPiBKZWZmLCBwbGVhc2UgbWFrZSBzdXJlIHRoaXMgZ2V0cyBzdWJt
aXR0ZWQgdG8gbWUgc29vbi4KPiA+IAo+ID4gRXhwZWN0IGl0IGxhdGVyIHRvbmlnaHQsIGp1c3Qg
ZmluaXNoaW5nIHVwIHRlc3RpbmcuCj4gCj4gVGVzdGVkLWJ5OiBBYXJvbiBCcm93biA8YWFyb24u
Zi5icm93bkBpbnRlbC5jb20+CgpIbSwgSSBzZWVtIHRvIGJlIGJsaW5kLCBidXQgSSBjYW4ndCBm
aW5kIGl0IGFueXdoZXJlIGluIC1yYzYuIERvZXMgc29tZW9uZQpoYXZlIHRoZSBzaGExIGZyb20g
TGludXMnIGdpdCBmb3IgdGhpcyBwYXRjaD8KClRoYW5rcywgRGFuaWVsCi0tIApEYW5pZWwgVmV0
dGVyClNvZnR3YXJlIEVuZ2luZWVyLCBJbnRlbCBDb3Jwb3JhdGlvbgpodHRwOi8vYmxvZy5mZnds
bC5jaApfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpJbnRl
bC1nZnggbWFpbGluZyBsaXN0CkludGVsLWdmeEBsaXN0cy5mcmVlZGVza3RvcC5vcmcKaHR0cHM6
Ly9saXN0cy5mcmVlZGVza3RvcC5vcmcvbWFpbG1hbi9saXN0aW5mby9pbnRlbC1nZngK
