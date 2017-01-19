From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [PATCH net-next] macb: Common code to enable ptp support for
 SAMA5Dx platforms.
Date: Thu, 19 Jan 2017 09:52:51 +0530
Message-ID: <CAFcVEC+fVUZzsJBZtbzxYw70zp7vyzdQ+bC97jGN-x--1bmBUA@mail.gmail.com>
References: <1484758673-8694-1-git-send-email-andrei.pistirica@microchip.com>
 <1c534b5a-25cb-a5d6-f87c-db9ed958a606@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: tbultel@pixelsurmer.com, Rafal Ozieblo <rafalo@cadence.com>,
 Boris Brezillon <boris.brezillon@free-electrons.com>, netdev@vger.kernel.org,
 Richard Cochran <richardcochran@gmail.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Andrei Pistirica <andrei.pistirica@microchip.com>,
 "michals@xilinx.com" <michals@xilinx.com>,
 Anirudha Sarangi <anirudh@xilinx.com>,
 Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
 Harini Katakam <harini.katakam@xilinx.com>,
 alexandre.belloni@free-electrons.com, David Miller <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1c534b5a-25cb-a5d6-f87c-db9ed958a606@atmel.com>
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

T24gV2VkLCBKYW4gMTgsIDIwMTcgYXQgMTE6MDIgUE0sIE5pY29sYXMgRmVycmUgPG5pY29sYXMu
ZmVycmVAYXRtZWwuY29tPiB3cm90ZToKPiBMZSAxOC8wMS8yMDE3IMOgIDA5OjU3LCBBbmRyZWkg
UGlzdGlyaWNhIGEgw6ljcml0IDoKPj4gVGhpcyBwYXRjaCBkb2VzIHRoZSBmb2xsb3dpbmc6Cj4+
IC0gYWRkIEdFTS1QVFAgaW50ZXJmYWNlCj4+IC0gcmVnaXN0ZXJzIGFuZCBiaXRmaWVsZHMgZm9y
IFRTVSBhcmUgbmFtZWQgYWNjb3JkaW5nIHRvIFNBTUE1RHggZGF0YSBzaGVldAo+PiAtIFBUUCBz
dXBwb3J0IGJhc2VkIG9uIHBsYXRmb3JtIGNhcGFiaWxpdHkKPgo+IFRoZSAkc3ViamVjdCB3aWxs
IGNlcnRhaW5seSBuZXZlciBtYXRjaCByZWFsaXR5LCBzYWRseSAiZW5hYmxlIHB0cAo+IHN1cHBv
cnQgZm9yIFNBTUE1RHggcGxhdGZvcm1zIi4gU28sIHlvdSdkIGJldHRlciBjaGFuZ2UgaXQuCj4g
KG5vICIuIiBhdCB0aGUgZW5kIEJUVykuCj4KPj4gU2lnbmVkLW9mZi1ieTogQW5kcmVpIFBpc3Rp
cmljYSA8YW5kcmVpLnBpc3RpcmljYUBtaWNyb2NoaXAuY29tPgo+PiAtLS0KPj4gVGhpcyBpcyBq
dXN0IHRoZSBjb21tb24gY29kZSBmb3IgR0VNLVBUUCBzdXBwb3J0LiBDb2RlIGlzIGJhc2VkIG9u
IHRoZSBjb21tZW50cwo+PiByZWxhdGVkIHRvIHRoZSBmb2xsb3dpbmcgcGF0Y2ggc2VyaWVzOgo+
PiAtIFtSRkMgUEFUQ0ggbmV0LW5leHQgdjEtdG8tNCAxLzJdIG1hY2I6IEFkZCAxNTg4IHN1cHBv
cnQgaW4gQ2FkZW5jZSBHRU0uCj4+IC0gW1JGQyBQQVRDSCBuZXQtbmV4dCB2MS10by00IDIvMl0g
bWFjYjogRW5hYmxlIDE1ODggc3VwcG9ydCBpbiBTQU1BNUR4IHBsYXRmb3Jtcy4KPj4KPj4gTm90
ZTogUGF0Y2ggb24gbmV0LW5leHQ6IEphbnVhcnkgMTguCj4+Cj4+IFJhZmFsL0hhcmluaSwgeW91
IGNhbiBjb250aW51ZSB0aGUgd29yayBmb3IgR01FLUdYTC4KClRoYW5rcyBBbmRyZWkuCgo8c25p
cD4KPgo+IE90aGVyd2lzZSwgSSdtIG9rYXkgd2l0aCB0aGUgcmVzdC4KPgo+IEkgc3VnZ2VzdCB0
byBwZW9wbGUgdGhhdCB3aWxsIGtlZXAgdGhlIGJhbGwgcm9sbGluZyBvbiB0aGlzIHRvcGljIHRv
Cj4gdGFrZSBhZHZhbnRhZ2Ugb2YgdGhlIGNodW5rcyBvZiBjb2RlIHRoYXQgQW5kcmVpIGRldmVs
b3BlZCB3aXRoIHRoZSBoZWxwCj4gb2YgUmljaGFyZCBhbmQgdGhlIGJlc3QgcHJhY3RpY2VzIGRp
c2N1c3NlZC4gSSB0aGluayBwYXJ0aWN1bGFybHksIGlmIGl0Cj4gbWFrZXMgc2Vuc2Ugd2l0aCBI
VywgYWJvdXQ6Cj4gLSBnZW1fcHRwX2RvX1tydF14c3RhbXAoYnAsIHNrYikgZGVyZWZlcmVuY2Ug
c2NoZW1lCj4gLSBnZW1fcHRwX2FkamZpbmUoKSByYXRpb25hbGUKPiAtIGdlbV9nZXRfcHRwX3Bl
ZXIoKSBpZiBuZWVkZWQKPgoKU3VyZSwgd2lsbCBwYXRjaCBvbiB0b3Agb2YgdGhpcy4KClJlZ2Fy
ZHMsCkhhcmluaQoKPiBSZWdhcmRzLAo+IC0tCj4gTmljb2xhcyBGZXJyZQoKX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KbGludXgtYXJtLWtlcm5lbCBtYWls
aW5nIGxpc3QKbGludXgtYXJtLWtlcm5lbEBsaXN0cy5pbmZyYWRlYWQub3JnCmh0dHA6Ly9saXN0
cy5pbmZyYWRlYWQub3JnL21haWxtYW4vbGlzdGluZm8vbGludXgtYXJtLWtlcm5lbAo=
