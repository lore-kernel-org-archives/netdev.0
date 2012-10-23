From: =?utf-8?Q?Lothar_Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: Re: [PATCH v3 1/4] net/macb: fix truncate warnings
Date: Tue, 23 Oct 2012 14:00:44 +0200
Message-ID: <20614.34540.248020.471598@ipc1.ka-ro>
References: <1350931534-8416-1-git-send-email-manabian@gmail.com>
 <1350931534-8416-2-git-send-email-manabian@gmail.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B705B@saturn3.aculab.com>
 <20121023.044829.1915412359769438159.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: bgat@billgatliff.com, netdev@vger.kernel.org, manabian@gmail.com,
 nicolas.ferre@atmel.com, David.Laight@ACULAB.COM, egtvedt@samfundet.no,
 plagnioj@jcrosoft.com, linux-arm-kernel@lists.infradead.org,
 hskinnemoen@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20121023.044829.1915412359769438159.davem@davemloft.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

SGksCgpEYXZpZCBNaWxsZXIgd3JpdGVzOgo+IEZyb206ICJEYXZpZCBMYWlnaHQiIDxEYXZpZC5M
YWlnaHRAQUNVTEFCLkNPTT4KPiBEYXRlOiBUdWUsIDIzIE9jdCAyMDEyIDA5OjIxOjExICswMTAw
Cj4gCj4gPj4gV2hlbiBidWlsZGluZyBtYWNiIG9uIHg4Nl82NCB0aGUgZm9sbG93aW5nIHdhcm5p
bmdzIHNob3cgdXA6Cj4gPj4gICBkcml2ZXJzL25ldC9ldGhlcm5ldC9jYWRlbmNlL21hY2IuYzog
SW4gZnVuY3Rpb24gbWFjYl9pbnRlcnJ1cHQ6Cj4gPj4gICBkcml2ZXJzL25ldC9ldGhlcm5ldC9j
YWRlbmNlL21hY2IuYzo1NTY6NDogd2FybmluZzogbGFyZ2UgaW50ZWdlciBpbXBsaWNpdGx5IHRy
dW5jYXRlZCB0byB1bnNpZ25lZCB0eXBlIFstV292ZXJmbG93XQo+ID4gLi4uCj4gPj4gLQkJCW1h
Y2Jfd3JpdGVsKGJwLCBJRFIsIH4wVUwpOwo+ID4+ICsJCQltYWNiX3dyaXRlbChicCwgSURSLCAt
MSk7Cj4gPiAKPiA+IFNlZW1zIHdyb25nIHRvIGZpeCBhbiBlcnJvciB3aXRoIGFuIHVuc2lnbmVk
IHZhbHVlCj4gPiBieSB1c2luZyAtMS4KPiAKPiAtMSBpcyBlcXVhbGx5IGFuIHVuc2lnbmVkIHZh
bHVlIG9mIGFsbCAxJ3MgYW5kIGNvbXBsZXRlbHkgbGVnaXRpbWF0ZS4KPiBUaGUgY29ycmVjdGlv
biBiZWluZyBtYWRlIGhlcmUgaXMgb25lIG9mIHNpemUgbm90IHNpZ25lZG5lc3MuCj4gCllvdSBj
b3VsZCB1c2UgJ34wJyAod2l0aG91dCB0aGUgJ1VMJykuCgoKTG90aGFyIFdhw59tYW5uCi0tIApf
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
XwoKS2EtUm8gZWxlY3Ryb25pY3MgR21iSCB8IFBhc2NhbHN0cmHDn2UgMjIgfCBEIC0gNTIwNzYg
QWFjaGVuClBob25lOiArNDkgMjQwOCAxNDAyLTAgfCBGYXg6ICs0OSAyNDA4IDE0MDItMTAKR2Vz
Y2jDpGZ0c2bDvGhyZXI6IE1hdHRoaWFzIEthdXNzZW4KSGFuZGVsc3JlZ2lzdGVyZWludHJhZzog
QW10c2dlcmljaHQgQWFjaGVuLCBIUkIgNDk5NgoKd3d3Lmthcm8tZWxlY3Ryb25pY3MuZGUgfCBp
bmZvQGthcm8tZWxlY3Ryb25pY3MuZGUKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX18KCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fCmxpbnV4LWFybS1rZXJuZWwgbWFpbGluZyBsaXN0CmxpbnV4LWFy
bS1rZXJuZWxAbGlzdHMuaW5mcmFkZWFkLm9yZwpodHRwOi8vbGlzdHMuaW5mcmFkZWFkLm9yZy9t
YWlsbWFuL2xpc3RpbmZvL2xpbnV4LWFybS1rZXJuZWwK
