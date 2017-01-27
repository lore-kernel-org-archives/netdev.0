From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH net-next v2] macb: Common code to enable ptp support for
 MACB/GEM
Date: Fri, 27 Jan 2017 11:12:24 +0100
Message-ID: <1bf44464-6f85-64a9-a660-8d2c44015eb9@atmel.com>
References: <1484841375-11420-1-git-send-email-andrei.pistirica@microchip.com>
 <BN3PR07MB25160FCBCF19918C495F43B4C9770@BN3PR07MB2516.namprd07.prod.outlook.com>
 <CAFcVECLuWM65zXJWtMcwijZ1ZbtH0pvKnTUR=SJagPGHEr9amg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "tbultel@pixelsurmer.com" <tbultel@pixelsurmer.com>,
 "boris.brezillon@free-electrons.com" <boris.brezillon@free-electrons.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "alexandre.belloni@free-electrons.com" <alexandre.belloni@free-electrons.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "richardcochran@gmail.com" <richardcochran@gmail.com>,
 Andrei Pistirica <andrei.pistirica@microchip.com>,
 "michals@xilinx.com" <michals@xilinx.com>,
 "anirudh@xilinx.com" <anirudh@xilinx.com>,
 "punnaia@xilinx.com" <punnaia@xilinx.com>,
 "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
 "davem@davemloft.net" <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Harini Katakam <harinikatakamlinux@gmail.com>, Rafal Ozieblo
 <rafalo@cadence.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAFcVECLuWM65zXJWtMcwijZ1ZbtH0pvKnTUR=SJagPGHEr9amg@mail.gmail.com>
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

TGUgMjcvMDEvMjAxNyDDoCAwNjo0MiwgSGFyaW5pIEthdGFrYW0gYSDDqWNyaXQgOgo+IEhpIFJh
ZmFsLAo+IAo+IE9uIFRodSwgSmFuIDI2LCAyMDE3IGF0IDg6NDUgUE0sIFJhZmFsIE96aWVibG8g
PHJhZmFsb0BjYWRlbmNlLmNvbT4gd3JvdGU6Cj4+PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0t
LQo+Pj4gRnJvbTogQW5kcmVpIFBpc3RpcmljYSBbbWFpbHRvOmFuZHJlaS5waXN0aXJpY2FAbWlj
cm9jaGlwLmNvbV0KPj4+IFNlbnQ6IDE5IHN0eWN6bmlhIDIwMTcgMTY6NTYKPj4+IFN1YmplY3Q6
IFtQQVRDSCBuZXQtbmV4dCB2Ml0gbWFjYjogQ29tbW9uIGNvZGUgdG8gZW5hYmxlIHB0cCBzdXBw
b3J0IGZvciBNQUNCL0dFTQo+Pj4KPj4+Cj4+PiArc3RhdGljIGlubGluZSBib29sIGdlbV9oYXNf
cHRwKHN0cnVjdCBtYWNiICpicCkKPj4+ICt7Cj4+PiArICAgICByZXR1cm4gISEoYnAtPmNhcHMg
JiBNQUNCX0NBUFNfR0VNX0hBU19QVFApOwo+Pj4gK30KPj4gV2h5IGRvbid0IHlvdSB1c2UgaGFy
ZHdhcmUgY2FwYWJpbGl0aWVzIGhlcmU/IFdvdWxkIGl0IGJlIGJldHRlciB0byByZWFkIGl0IGZy
b20gaGFyZHdhcmUgaW5zdGVhZCBhZGRpbmcgaXQgdG8gbWFueSBjb25maWd1cmF0aW9uPwo+IAo+
IElmIHlvdSBhcmUgcmVmZXJyaW5nIHRvIFRTVSBiaXQgaW4gRENGRzUsIHRoZW4gd2Ugd2lsbCBi
ZSByZWx5aW5nIG9uCj4gQ2FkZW5jZSBJUCdzIGluZm9ybWF0aW9uIGlycmVzcGVjdGl2ZSBvZiB0
aGUgU29DIGNhcGFiaWxpdHkKPiBhbmQgd2hldGhlciB0aGUgUFRQIHN1cHBvcnQgd2FzIGFkZXF1
YXRlLgo+IEkgdGhpbmsgdGhlIGNhcGFiaWxpdHkgYXBwcm9hY2ggZ2l2ZXMgYmV0dGVyIGNvbnRy
b2wgYW5kCj4gaXQgaXMgbm90IHJlYWxseSBtdWNoIHRvIGFkZC4KClllcywgYWJzb2x1dGVseS4g
SW4gZmFjdCB3ZSBhbHJlYWR5IGhhZCB0aGlzIGRpc2N1c3Npb24gYW5kIGRlY2lkZWQgdGhhdAp0
aGlzIGNhcGFiaWxpdHkgc2NoZW1lIHdhcyBnaXZpbmcgbXVjaCBtb3JlIGNvbnRyb2wgYXQgbG93
IGNvc3QuCgpSZWdhcmRzLAotLSAKTmljb2xhcyBGZXJyZQoKX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX18KbGludXgtYXJtLWtlcm5lbCBtYWlsaW5nIGxpc3QK
bGludXgtYXJtLWtlcm5lbEBsaXN0cy5pbmZyYWRlYWQub3JnCmh0dHA6Ly9saXN0cy5pbmZyYWRl
YWQub3JnL21haWxtYW4vbGlzdGluZm8vbGludXgtYXJtLWtlcm5lbAo=
