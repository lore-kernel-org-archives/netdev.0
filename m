From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v2 net-next 0/9] set addr_assign_type when inheriting a
 dev_addr
Date: Tue, 03 Sep 2013 09:38:10 +0200
Message-ID: <87mwnuqrrx.fsf@nemi.mork.no>
References: <1377878932-26881-1-git-send-email-bjorn@mork.no>
 <20130831.225057.1874268263797742541.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: devel@driverdev.osuosl.org, jiri@resnulli.us,
 libertas-dev@lists.infradead.org, j@w1.fi, netdev@vger.kernel.org,
 linux-wireless@vger.kernel.org, linville@tuxdriver.com,
 stephen@networkplumber.org, forest@alittletooquiet.net,
 gregkh@linuxfoundation.org, kaber@trash.net, dan.carpenter@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20130831.225057.1874268263797742541.davem@davemloft.net> (David
 Miller's message of "Sat, 31 Aug 2013 22:50:57 -0400 (EDT)")
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

RGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0PiB3cml0ZXM6Cgo+IEZyb206IEJqw7hy
biBNb3JrIDxiam9ybkBtb3JrLm5vPgo+IERhdGU6IEZyaSwgMzAgQXVnIDIwMTMgMTg6MDg6NDMg
KzAyMDAKPgo+PiBDb3B5aW5nIHRoZSBkZXZfYWRkciBmcm9tIGEgcGFyZW50IGRldmljZSBpcyBh
biBvcGVyYXRpb24KPj4gY29tbW9uIHRvIGEgbnVtYmVyIG9mIGRyaXZlcnMuIFRoZSBhZGRyX2Fz
c2lnbl90eXBlIHNob3VsZAo+PiBiZSB1cGRhdGVkIGFjY29yZGluZ2x5LCBlaXRoZXIgYnkgcmV1
c2luZyB0aGUgdmFsdWUgZnJvbQo+PiB0aGUgc291cmNlIGRldmljZSBvciBleHBsaWNpdGx5IGlu
ZGljYXRpbmcgdGhhdCB0aGUgYWRkcmVzcwo+PiBpcyBzdG9sZW4gYnkgc2V0dGluZyBhZGRyX2Fz
c2lnbl90eXBlIHRvIE5FVF9BRERSX1NUT0xFTi4KPj4gCj4+IFRoaXMgcGF0Y2ggc2V0IGFkZHMg
YSBoZWxwZXIgY29weWluZyBib3RoIHRoZSBkZXZfYWRkciBhbmQKPj4gdGhlIGFkZHJfYXNzaWdu
X3R5cGUsIGFuZCB1c2UgdGhpcyBoZWxwZXIgaW4gZHJpdmVycyB3aGljaAo+PiBkb24ndCBjdXJy
ZW50bHkgc2V0IHRoZSBhZGRyX2Fzc2lnbl90eXBlLiBVc2luZyBORVRfQUREUl9TVE9MRU4KPj4g
bWlnaHQgYmUgbW9yZSBhcHByb3ByaWF0ZSBpbiBzb21lIG9mIHRoZXNlIGNhc2VzLiAgUGxlYXNl
Cj4+IGxldCBtZSBrbm93LCBhbmQgSSdsbCB1cGRhdGUgdGhlIHBhdGNoIGFjY29yZGluZ2x5Lgo+
PiAKPj4gQ2hhbmdlcyBpbiB2MjoKPj4gIC0gYXNzdW1pbmcgYWRkcl9sZW4gPT0gRVRIX0FMRU4g
dG8gYWxsb3cgb3B0aW1pemVkIG1lbWNweQo+PiAgLSBkcm9wcGVkIHRoZSB2dDY2NTYgcGF0Y2gg
ZHVlIHRvIGFkZHJfbGVuIGJlaW5nIHVuc2V0IGluIHRoYXQgZHJpdmVyCj4KPiBMb29rcyBnb29k
LCBzZXJpZXMgYXBwbGllZCwgdGhhbmtzLgoKVGhhbmtzLiAgQnV0IGl0IGRvZXNuJ3QgbG9vayBs
aWtlIGl0IGVuZGVkIHVwIGluIG5ldC1uZXh0PyAgT3IgYW0gSQptaXNzaW5nIHNvbWV0aGluZyAo
YWdhaW4pPwoKCkJqw7hybgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fXwpkZXZlbCBtYWlsaW5nIGxpc3QKZGV2ZWxAbGludXhkcml2ZXJwcm9qZWN0Lm9yZwpo
dHRwOi8vZHJpdmVyZGV2LmxpbnV4ZHJpdmVycHJvamVjdC5vcmcvbWFpbG1hbi9saXN0aW5mby9k
cml2ZXJkZXYtZGV2ZWwK
