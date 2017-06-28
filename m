From: Daniel Vetter <daniel.vetter@ffwll.ch>
Subject: Re: [Intel-wired-lan] [PATCH v2 1/1] e1000e: Undo e1000e_pm_freeze if
 __e1000_shutdown fails
Date: Wed, 28 Jun 2017 07:35:03 +0200
Message-ID: <CAKMK7uHLdQ_Jd+h95d9kUxNPoy5Z3nP9r85GPraYcc52_Fk8bw@mail.gmail.com>
References: <20170531.110833.1362264472730468352.davem@davemloft.net>
 <20170531155043.3596-1-jani.nikula@intel.com>
 <20170531155043.3596-2-jani.nikula@intel.com>
 <20170602.141426.713378366601051907.davem@davemloft.net>
 <1496781986.86439.3.camel@intel.com>
 <309B89C4C689E141A5FF6A0C5FB2118B8C61D137@ORSMSX101.amr.corp.intel.com>
 <20170620084958.7fxdn57p3o6eexbj@phenom.ffwll.local>
 <CAPM=9tzdpEDoMNYj7Z_ZM3Z0JsCpjfNW1Z+y-1p5z3HssJ5aaw@mail.gmail.com>
 <1498596665.3244.2.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Ursulin, Tvrtko" <tvrtko.ursulin@intel.com>, "Nikula,
 Jani" <jani.nikula@intel.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, "Ertman,
 David M" <david.m.ertman@intel.com>, "Brown,
 Aaron F" <aaron.f.brown@intel.com>, David Miller <davem@davemloft.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <1498596665.3244.2.camel@intel.com>
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

T24gVHVlLCBKdW4gMjcsIDIwMTcgYXQgMTA6NTEgUE0sIEplZmYgS2lyc2hlcgo8amVmZnJleS50
LmtpcnNoZXJAaW50ZWwuY29tPiB3cm90ZToKPiBUaGlzIHdhcyBzdWJtaXR0ZWQgYW5kIGFjY2Vw
dGVkIGludG8gRGF2aWQgTWlsbGVyJ3MgbmV0LW5leHQgdHJlZS4gIEkgY2FuCj4gc2VlIGlmIERh
dmUgY2FuIHB1bGwgaXQgaW50byBoaXMgbmV0IHRyZWUuICBET2VzIHN0YWJsZSBuZWVkIHRvIHBp
Y2sgdGhpcwo+IHVwIGFzIHdlbGw/CgpOYWggaWYgaXQgbGFuZGVkIHNvbWV3aGVyZSBhdCBsZWFz
dCBJJ20gaGFwcHksIHdlIGNhbiBjYXJyeSB0aGUgZml4dXAKZm9yIGEgd2hpbGUgbG9uZ2VyIGxv
Y2FsbHkuCgpUaGFua3MsIERhbmllbAotLSAKRGFuaWVsIFZldHRlcgpTb2Z0d2FyZSBFbmdpbmVl
ciwgSW50ZWwgQ29ycG9yYXRpb24KKzQxICgwKSA3OSAzNjUgNTcgNDggLSBodHRwOi8vYmxvZy5m
ZndsbC5jaApfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpk
cmktZGV2ZWwgbWFpbGluZyBsaXN0CmRyaS1kZXZlbEBsaXN0cy5mcmVlZGVza3RvcC5vcmcKaHR0
cHM6Ly9saXN0cy5mcmVlZGVza3RvcC5vcmcvbWFpbG1hbi9saXN0aW5mby9kcmktZGV2ZWwK
