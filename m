From: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
Subject: RE: [net-next v4 2/8] dpaa_eth: add support for DPAA Ethernet
Date: Tue, 3 Nov 2015 09:37:22 +0000
Message-ID: <BL2PR03MB545ED95392F5CB88EC06B11E62B0@BL2PR03MB545.namprd03.prod.outlook.com>
References: <1446485500-9782-1-git-send-email-madalin.bucur@freescale.com>
 <1446485500-9782-3-git-send-email-madalin.bucur@freescale.com>
 <1446537357.21216.49.camel@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
 Roy Pledge <roy.pledge@freescale.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "ppc@mindchasers.com" <ppc@mindchasers.com>,
 Liberman Igal <Igal.Liberman@freescale.com>,
 Scott Wood <scottwood@freescale.com>, "joe@perches.com" <joe@perches.com>,
 "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1446537357.21216.49.camel@transmode.se>
Content-Language: en-US
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQo+IEZyb206IEpvYWtpbSBUamVybmx1bmQgW21h
aWx0bzpqb2FraW0udGplcm5sdW5kQHRyYW5zbW9kZS5zZV0KPiAKPiBPbiBNb24sIDIwMTUtMTEt
MDIgYXQgMTk6MzEgKzAyMDAsIE1hZGFsaW4gQnVjdXIgd3JvdGU6Cj4gPiArICAgICAgIGlmICh1
bmxpa2VseShmZF9zdGF0dXMgJiBGTV9GRF9TVEFUX1JYX0VSUk9SUykgIT0gMCkgewo+ID4gKyAg
ICAgICAgICAgICAgIGlmIChuZXRfcmF0ZWxpbWl0KCkpCj4gPiArICAgICAgICAgICAgICAgICAg
ICAgICBuZXRpZl93YXJuKHByaXYsIGh3LCBuZXRfZGV2LCAiRkQgc3RhdHVzID0KPiAweCUwOHhc
biIsCj4gPiArICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGZkX3N0YXR1cyAmIEZN
X0ZEX1NUQVRfUlhfRVJST1JTKTsKPiA+ICsKPiA+ICsgICAgICAgICAgICAgICBwZXJjcHVfc3Rh
dHMtPnJ4X2Vycm9ycysrOwo+ID4gKyAgICAgICAgICAgICAgIGdvdG8gX3JlbGVhc2VfZnJhbWU7
Cj4gPiArICAgICAgIH0KPiAKPiBJIGNhbm5vdCBmaW5kIGFueSBkZXRhaWxlZCBlcnJvciBhY2Nv
dW50aW5nKG1heWJlIEkgYW0gbm90IGxvb2tpbmcgaGFyZAo+IGVub3VnaCkgYnV0IEkKPiB3b3Vs
ZCBhcHByZWNpYXRlIGlmIGJvdGggVFggYW5kIFJYIGVycm9ycyB3aGVyZSBiZXR0ZXIKPiBhY2Nv
dW50ZWQocnhfbGVuZ3RoX2Vycm9ycywgcnhfZnJhbWVfZXJyb3JzLAo+IHJ4X2NyY19lcnJvcnMs
IHJ4X2ZpZm9fZXJyb3JzIGV0Yy4pLiBUaGlzIGhhcyBoZWxwZWQgbWUgbWFueSB0aW1lcyBpbiB0
aGUKPiBwYXN0IGRpYWdub3NpbmcKPiBib2FyZCBIVyBwcm9ibGVtcy4KPiAKPiAgSm9ja2UKCkhp
IEpvY2tlLAoKVGhlcmUgYXJlIHNvbWUgZXJyb3IgY291bnRlcnMgZXhwb3J0ZWQgdGhyb3VnaCBl
dGh0b29sICh1c2VkIHRvIGJlIGRlYnVnZnMpLgpGTWFuIEhXIHByb3ZpZGVzIG1vcmUgZGVidWcg
aW5mb3JtYXRpb24gdGhhbiB3ZSBjdXJyZW50bHkgZXhwb3J0LCB0aGF0IHdpbGwgYmUKaW1wcm92
ZWQgaW4gdGhlIGZ1dHVyZSBidXQgZ2l2ZW4gdGhlIGN1cnJlbnQgcHJpb3JpdHkgb2YgaGF2aW5n
IGEgY29kZWJhc2UgYXMKc21hbGwgYW5kIHJldmlld2FibGUgYXMgcG9zc2libGUgd2UgaGFkIHRv
IGRyb3Agc29tZSB0aGluZ3MgZnJvbSB0aGUgaW5pdGlhbApzdWJtaXNzaW9uLgoKTWFkYWxpbgpf
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpMaW51eHBwYy1k
ZXYgbWFpbGluZyBsaXN0CkxpbnV4cHBjLWRldkBsaXN0cy5vemxhYnMub3JnCmh0dHBzOi8vbGlz
dHMub3psYWJzLm9yZy9saXN0aW5mby9saW51eHBwYy1kZXY=
