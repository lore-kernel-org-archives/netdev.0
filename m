From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH 02/19] io-mapping: Specify mapping size for
 io_mapping_map_wc()
Date: Wed, 20 Apr 2016 20:58:44 +0200
Message-ID: <20160420185844.GQ1990@wotan.suse.de>
References: <1461177750-20187-1-git-send-email-chris@chris-wilson.co.uk>
 <1461177750-20187-3-git-send-email-chris@chris-wilson.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Airlie <airlied@linux.ie>, intel-gfx@lists.freedesktop.org,
 linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>,
 "Peter Zijlstra \(Intel\)" <peterz@infradead.org>,
 "Luis R . Rodriguez" <mcgrof@kernel.org>, dri-devel@lists.freedesktop.org,
 netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
 Daniel Vetter <daniel.vetter@intel.com>,
 Dan Williams <dan.j.williams@intel.com>, Yishai Hadas <yishaih@mellanox.com>,
 David Hildenbrand <dahi@linux.vnet.ibm.com>
To: Chris Wilson <chris@chris-wilson.co.uk>
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <1461177750-20187-3-git-send-email-chris@chris-wilson.co.uk>
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

T24gV2VkLCBBcHIgMjAsIDIwMTYgYXQgMDc6NDI6MTNQTSArMDEwMCwgQ2hyaXMgV2lsc29uIHdy
b3RlOgo+IFRoZSBpb3JlbWFwKCkgaGlkZGVuIGJlaGluZCB0aGUgaW9fbWFwcGluZ19tYXBfd2Mo
KSBjb252ZW5pZW5jZSBoZWxwZXIKPiBjYW4gYmUgdXNlZCBmb3IgcmVtYXBwaW5nIG11bHRpcGxl
IHBhZ2VzLiBFeHRlbmQgdGhlIGhlbHBlciBzbyB0aGF0Cj4gZnV0dXJlIGNhbGxlcnMgY2FuIHVz
ZSBpdCBmb3IgbGFyZ2VyIHJhbmdlcy4KPiAKPiBTaWduZWQtb2ZmLWJ5OiBDaHJpcyBXaWxzb24g
PGNocmlzQGNocmlzLXdpbHNvbi5jby51az4KPiBDYzogVHZydGtvIFVyc3VsaW4gPHR2cnRrby51
cnN1bGluQGludGVsLmNvbT4KPiBDYzogRGFuaWVsIFZldHRlciA8ZGFuaWVsLnZldHRlckBpbnRl
bC5jb20+Cj4gQ2M6IEphbmkgTmlrdWxhIDxqYW5pLm5pa3VsYUBsaW51eC5pbnRlbC5jb20+Cj4g
Q2M6IERhdmlkIEFpcmxpZSA8YWlybGllZEBsaW51eC5pZT4KPiBDYzogWWlzaGFpIEhhZGFzIDx5
aXNoYWloQG1lbGxhbm94LmNvbT4KPiBDYzogRGFuIFdpbGxpYW1zIDxkYW4uai53aWxsaWFtc0Bp
bnRlbC5jb20+Cj4gQ2M6IEluZ28gTW9sbmFyIDxtaW5nb0BrZXJuZWwub3JnPgo+IENjOiAiUGV0
ZXIgWmlqbHN0cmEgKEludGVsKSIgPHBldGVyekBpbmZyYWRlYWQub3JnPgo+IENjOiBEYXZpZCBI
aWxkZW5icmFuZCA8ZGFoaUBsaW51eC52bmV0LmlibS5jb20+Cj4gQ2M6IEx1aXMgUi4gUm9kcmln
dWV6IDxtY2dyb2ZAa2VybmVsLm9yZz4KPiBDYzogaW50ZWwtZ2Z4QGxpc3RzLmZyZWVkZXNrdG9w
Lm9yZwo+IENjOiBkcmktZGV2ZWxAbGlzdHMuZnJlZWRlc2t0b3Aub3JnCj4gQ2M6IG5ldGRldkB2
Z2VyLmtlcm5lbC5vcmcKPiBDYzogbGludXgtcmRtYUB2Z2VyLmtlcm5lbC5vcmcKPiBDYzogbGlu
dXgta2VybmVsQHZnZXIua2VybmVsLm9yZwoKV2UgaGF2ZSAyIGNhbGxlcnMgdG9kYXksIGluIHRo
ZSBmdXR1cmUsIGNhbiB5b3UgZW52aXNpb24KdGhpcyBBUEkgZ2V0dGluZyBtb3JlIG9wdGlvbnM/
IElmIHNvLCBpbiBvcmRlciB0byBhdm9pZCB0aGUKcGFpbiBvZiBjb2xsYXRlcmFsIGV2b2x1dGlv
bnMgSSBjYW4gc3VnZ2VzdCBhIGRlc2NyaXB0b3IKYmVpbmcgcGFzc2VkIHdpdGggdGhlIHJlcXVp
cmVkIHNldHRpbmdzIC8gb3B0aW9ucy4gVGhpcyBsZXRzCnlvdSBldm9sdmUgdGhlIEFQSSB3aXRo
b3V0IG5lZWRpbmcgdG8gZ28gaW4gYW5kIG1vZGlmeQpvbGQgdXNlcnMuIElmIHlvdSBjaG9vc2Ug
bm90IHRvIHRoYXQncyBmaW5lIHRvbywganVzdApmaWd1cmVkIEknZCBjaGltZSBpbiB3aXRoIHRo
YXQgYXMgSSd2ZSBzZWVuIHRoZSBwYWluCndpdGggb3RoZXIgQVBJcywgYW5kIEknbSBwdXR0aW5n
IGFuIGVuZCB0byB0aGUgbmVlZGxlc3MKc2V0IG9mIGNvbGxhdGVyYWwgZXZvbHV0aW9ucyB0aGlz
IHdheS4KCk90aGVyIHRoYW4gdGhhdCBwb3NzaWJsZSBBUEkgb3B0aW1pemF0aW9uOgoKUmV2aWV3
ZWQtYnk6IEx1aXMgUi4gUm9kcmlndWV6IDxtY2dyb2ZAa2VybmVsLm9yZz4KCiAgTHVpcwpfX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpJbnRlbC1nZnggbWFp
bGluZyBsaXN0CkludGVsLWdmeEBsaXN0cy5mcmVlZGVza3RvcC5vcmcKaHR0cHM6Ly9saXN0cy5m
cmVlZGVza3RvcC5vcmcvbWFpbG1hbi9saXN0aW5mby9pbnRlbC1nZngK
