From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: Re: OpenWRT wrong adjustment of fq_codel defaults (Was:
 fq_codel_drop vs a udp flood)
Date: Mon, 16 May 2016 02:27:09 +0300
Message-ID: <CACiydbLCOoX7QexKNw_H0rjdH26j-wxJUj7Z23cmzXteo-e-MQ@mail.gmail.com>
References: <CAA93jw6QLyx9EaS+ntB0D3duoysu_Z-UYyQfHnRa=pfqPDfWOw@mail.gmail.com>
 <1462125592.5535.194.camel@edumazet-glaptop3.roam.corp.google.com>
 <865DA393-262D-40B6-A9D3-1B978CD5F6C6@gmail.com>
 <1462128385.5535.200.camel@edumazet-glaptop3.roam.corp.google.com>
 <C5D365DA-18EE-446E-9D25-41F48B1C583E@gmail.com>
 <1462136140.5535.219.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACiydbKUu11=zWitkDha0ddgk1-G_Z4-e1+=9ky776VktF5HHg@mail.gmail.com>
 <1462201620.5535.250.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACiydbKeKUENncrc-NmYRcku-DGVeGqqzYMqsCqKdxPsR7yUOQ@mail.gmail.com>
 <1462205669.5535.254.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACiydbL26Jj3EcEL4EmqaH=1Dm-Q0dpVwoWxqUSZ7ry10bRgeg@mail.gmail.com>
 <1462464776.13075.18.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACiydbJYrFRMJvSHM6tJYWR8vmgV3xxnSUQsb-h5WcnLW=KXoQ@mail.gmail.com>
 <1462476207.13075.20.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160506114243.4eb4f95e@redhat.com>
 <20160506144740.210901f5@redhat.com>
 <CACiydbL3qZrvZ4a_OUXiN0dp7qdqOktaQdAUdfOpKkZ1OfEZbA@mail.gmail.com>
 <CACiydb+A_vFNdp7tbw67Rnp+kHwt5GsLa+Su+pO8YmOZYp_KHg@mail.gmail.com>
 <CAA93jw4XeMSxiTLHWZ2b=F9ni7wz9RpkWDdhTh99gn4Mf1aWjA@mail.gmail.com>
 <CACiydbLcYe=2VLb3W9i-i2FGALwxJK=oO8RcZWjmj3YPGObK3Q@mail.gmail.com>
 <1463353661.18194.50.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: make-wifi-fast@lists.bufferbloat.net,
 =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
 ath10k <ath10k@lists.infradead.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "codel@lists.bufferbloat.net" <codel@lists.bufferbloat.net>,
 Jonathan Morton <chromatix99@gmail.com>,
 OpenWrt Development List <openwrt-devel@lists.openwrt.org>,
 Felix Fietkau <nbd@nbd.name>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1463353661.18194.50.camel@edumazet-glaptop3.roam.corp.google.com>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
 <mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
 <mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Errors-To: codel-bounces@lists.bufferbloat.net
Sender: "Codel" <codel-bounces@lists.bufferbloat.net>
List-Id: netdev.vger.kernel.org

T24gMTYgTWF5IDIwMTYgYXQgMDI6MDcsIEVyaWMgRHVtYXpldCA8ZXJpYy5kdW1hemV0QGdtYWls
LmNvbT4gd3JvdGU6Cj4gT24gTW9uLCAyMDE2LTA1LTE2IGF0IDAxOjM0ICswMzAwLCBSb21hbiBZ
ZXJ5b21pbiB3cm90ZToKPgo+PiBxZGlzYyBmcV9jb2RlbCA4MDAzOiBwYXJlbnQgOjMgbGltaXQg
MTAyNHAgZmxvd3MgMTYgcXVhbnR1bSAxNTE0Cj4+IHRhcmdldCA4MC4wbXMgY2VfdGhyZXNob2xk
IDMydXMgaW50ZXJ2YWwgMTAwLjBtcyBlY24KPj4gIFNlbnQgMTYwMTI3MTE2OCBieXRlcyAxMDU3
NzA2IHBrdCAoZHJvcHBlZCAxNDIyMzA0LCBvdmVybGltaXRzIDAgcmVxdWV1ZXMgMTcpCj4+ICBi
YWNrbG9nIDE1NDEyNTJiIDEwMThwIHJlcXVldWVzIDE3Cj4+ICAgbWF4cGFja2V0IDE1MTQgZHJv
cF9vdmVybGltaXQgMTQyMjMwNCBuZXdfZmxvd19jb3VudCAzNSBlY25fbWFyayAwCj4+ICAgbmV3
X2Zsb3dzX2xlbiAwIG9sZF9mbG93c19sZW4gMQo+Cj4gV2h5IGRvIHlvdSBoYXZlIGNlX3RocmVz
aG9sZCBzZXQgPyBZb3UgcmVhbGx5IHNob3VsZCBub3QgKGV2ZW4gaWYgaXQKPiBkb2VzIG5vdCBt
YXR0ZXIgZm9yIHRoZSBraW5kIG9mIHRyYWZmaWMgeW91IGhhdmUgYXQgdGhpcyBtb21lbnQpCgpO
byBpZGVhLCBpdCB3YXMgdGhlcmUgYWx3YXlzLiBIb3cgZG8gSSB1bnNldCBpdD8gU2V0dGluZyBp
dCB0byAwIGRvZXNuJ3QgaGVscC4KCj4gSWYgeW91ciBleHBlY3RlZCBsaW5rIHNwZWVkIGlzIGFy
b3VuZCAxR2Jwcywgb3IgODAsMDAwIHBhY2tldHMgcGVyCj4gc2Vjb25kLCB0aGVuIHlvdSBoYXZl
IHRvIHVuZGVyc3RhbmQgdGhhdCAxMDI0IHBhY2tldHMgbGltaXQgaXMgYWJvdXQgMTIKPiBtcyBh
dCBtb3N0Lgo+Cj4gRXZlbiBpZiB0aGUgcXVldWUgaXMgZnVsbCwgbWF4IHNvam91cm4gdGltZSBv
ZiBhIHBhY2tldCB3b3VsZCBiZSAxMiBtcy4KPgo+IEkgcmVhbGx5IGRvIG5vdCBzZWUgaG93ICd0
YXJnZXQgODAgbXMnIGNvdWxkIGJlIGhpdC4KCldlbGwsIGFzIEkgc2FpZCwgSSd2ZSB0cmllZCBk
aWZmZXJlbnQgb3B0aW9ucy4gTmVpdGhlciB0YXJnZXQgMjBtcyAoYXMKRGF2ZSBwcm9wb3NlZCkg
bm90IDEybXMgc2F2ZSB0aGUgc2l0dWF0aW9uLgoKPiBZb3UgYmFzaWNhbGx5IGhhdmUgRlEsIHdp
dGggbm8gQ29kZWwgZWZmZWN0LCBidXQgd2l0aCB0aGUgYXNzb2NpYXRlZAo+IGNvc3Qgb2YgQ29k
ZWwgKGhhdmluZyB0byB0YWtlIHRpbWVzdGFtcHMpCj4KPgo+Cl9fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fCkNvZGVsIG1haWxpbmcgbGlzdApDb2RlbEBsaXN0
cy5idWZmZXJibG9hdC5uZXQKaHR0cHM6Ly9saXN0cy5idWZmZXJibG9hdC5uZXQvbGlzdGluZm8v
Y29kZWwK
