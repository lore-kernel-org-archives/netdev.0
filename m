From: Peter Rosin <peda@axentia.se>
Subject: Re: [v12, 7/8] base: soc: introduce soc_device_match() interface
Date: Wed, 21 Sep 2016 10:25:08 +0200
Message-ID: <aa53da4f-205d-cfa1-c85c-00e82e928bbc@axentia.se>
References: <1474441040-11946-1-git-send-email-yangbo.lu@nxp.com>
 <1474441040-11946-8-git-send-email-yangbo.lu@nxp.com>
 <1474444574.270880035@f136.i.mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Mark Rutland <mark.rutland@arm.com>, ulf.hansson@linaro.org,
 Xiaobo Xie <xiaobo.xie@nxp.com>, Minghuan Lian <minghuan.lian@nxp.com>,
 linux-i2c@vger.kernel.org, linux-clk@vger.kernel.org,
 Qiang Zhao <qiang.zhao@nxp.com>, Russell King <linux@arm.linux.org.uk>,
 Bhupesh Sharma <bhupesh.sharma@freescale.com>, Joerg Roedel <joro@8bytes.org>,
 Jochen Friedrich <jochen@scram.de>,
 Claudiu Manoil <claudiu.manoil@freescale.com>, devicetree@vger.kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Scott Wood <oss@buserror.net>,
 Rob Herring <robh+dt@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>,
 linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
 linux-mmc@vger.kernel.org, linux-kernel@vger.kernel.org,
 Leo Li <leoyang.li@nxp.com>, iommu@lists.linux-foundation.org,
 Kumar Gala <galak@codeaurora.org>, linuxppc-dev@lists.ozlabs.org
To: Alexander Shiyan <shc_work@mail.ru>, Yangbo Lu <yangbo.lu@nxp.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1474444574.270880035@f136.i.mail.ru>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

T24gMjAxNi0wOS0yMSAwOTo1NiwgQWxleGFuZGVyIFNoaXlhbiB3cm90ZToKPj4g0KHRgNC10LTQ
sCwgMjEg0YHQtdC90YLRj9Cx0YDRjyAyMDE2LCA5OjU3ICswMzowMCDQvtGCIFlhbmdibyBMdSA8
eWFuZ2JvLmx1QG54cC5jb20+Ogo+Pgo+PiBGcm9tOiBBcm5kIEJlcmdtYW5uIDwgYXJuZEBhcm5k
Yi5kZSA+Cj4+Cj4+IFdlIGtlZXAgcnVubmluZyBpbnRvIGNhc2VzIHdoZXJlIGRldmljZSBkcml2
ZXJzIHdhbnQgdG8ga25vdyB0aGUgZXhhY3QKPj4gdmVyc2lvbiBvZiB0aGUgYSBTb0MgdGhleSBh
cmUgY3VycmVudGx5IHJ1bm5pbmcgb24uIEluIHRoZSBwYXN0LCB0aGlzIGhhcwo+PiB1c3VhbGx5
IGJlZW4gZG9uZSB0aHJvdWdoIGEgdmVuZG9yIHNwZWNpZmljIEFQSSB0aGF0IGNhbiBiZSBjYWxs
ZWQgYnkgYQo+PiBkcml2ZXIsIG9yIGJ5IGRpcmVjdGx5IGFjY2Vzc2luZyBzb21lIGtpbmQgb2Yg
dmVyc2lvbiByZWdpc3RlciB0aGF0IGlzCj4+IG5vdCBwYXJ0IG9mIHRoZSBkZXZpY2UgaXRzZWxm
IGJ1dCB0aGF0IGJlbG9uZ3MgdG8gYSBnbG9iYWwgcmVnaXN0ZXIgYXJlYQo+PiBvZiB0aGUgY2hp
cC4KPiAuLi4KPj4gK2NvbnN0IHN0cnVjdCBzb2NfZGV2aWNlX2F0dHJpYnV0ZSAqc29jX2Rldmlj
ZV9tYXRjaCgKPj4gK2NvbnN0IHN0cnVjdCBzb2NfZGV2aWNlX2F0dHJpYnV0ZSAqbWF0Y2hlcykK
Pj4gK3sKPj4gK2ludCByZXQgPSAwOwo+PiArCj4+ICtpZiAoIW1hdGNoZXMpCj4+ICtyZXR1cm4g
TlVMTDsKPj4gKwo+PiArd2hpbGUgKCFyZXQpIHsKPj4gK2lmICghKG1hdGNoZXMtPm1hY2hpbmUg
fHwgbWF0Y2hlcy0+ZmFtaWx5IHx8Cj4+ICsgICAgICBtYXRjaGVzLT5yZXZpc2lvbiB8fCBtYXRj
aGVzLT5zb2NfaWQpKQo+PiArYnJlYWs7Cj4+ICtyZXQgPSBidXNfZm9yX2VhY2hfZGV2KCZzb2Nf
YnVzX3R5cGUsIE5VTEwsICh2b2lkICopbWF0Y2hlcywKPj4gKyAgICAgICBzb2NfZGV2aWNlX21h
dGNoX29uZSk7Cj4+ICtpZiAoIXJldCkKPj4gK21hdGNoZXMrKzsKPiAKPiBTbywgd2hhdCBoYXBw
ZW4gaWYgbmV4dCAibWF0Y2hlcyIgKGFmdGVyIGluY3JlbWVudCkgd2lsbCBiZSBOVUxMPwoKQSBj
cmFzaD8KCj4gSSB0aGluayB5b3Ugc2hvdWxkIHVzZSB3aGlsZShtYXRjaGVzKSBhdCB0aGUgc3Rh
cnQgb2YgdGhpcyBwcm9jZWR1cmUuCgoqYXJyZ2gqCgoqSWYqIG1hdGNoZXMgd3JhcCwgeW91IGlu
ZGVlZCBoYXZlICpiaWcqIHByb2JsZW1zLiAqRWxzZXdoZXJlKgoKSGludDogUGxlYXNlIHJlYWQg
dGhlIHJldmlldyBjb21tZW50cyBvbiB0aGUgcHJldmlvdXMgdmVyc2lvbiBvZiB0aGlzCnNlcmll
cyBbMV0gYmVmb3JlIGNvbW1lbnRpbmcgZnVydGhlci4KCkNoZWVycywKUGV0ZXIKClsxXSBodHRw
czovL3d3dy5tYWlsLWFyY2hpdmUuY29tL25ldGRldkB2Z2VyLmtlcm5lbC5vcmcvbXNnMTI2NjE3
Lmh0bWwKCgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18K
bGludXgtYXJtLWtlcm5lbCBtYWlsaW5nIGxpc3QKbGludXgtYXJtLWtlcm5lbEBsaXN0cy5pbmZy
YWRlYWQub3JnCmh0dHA6Ly9saXN0cy5pbmZyYWRlYWQub3JnL21haWxtYW4vbGlzdGluZm8vbGlu
dXgtYXJtLWtlcm5lbAo=
