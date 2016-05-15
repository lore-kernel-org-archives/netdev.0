From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: OpenWRT wrong adjustment of fq_codel defaults (Was:
 fq_codel_drop vs a udp flood)
Date: Sun, 15 May 2016 16:07:41 -0700
Message-ID: <1463353661.18194.50.camel@edumazet-glaptop3.roam.corp.google.com>
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
 <20160506114243.4eb4f95e@redhat.com> <20160506144740.210901f5@redhat.com>
 <CACiydbL3qZrvZ4a_OUXiN0dp7qdqOktaQdAUdfOpKkZ1OfEZbA@mail.gmail.com>
 <CACiydb+A_vFNdp7tbw67Rnp+kHwt5GsLa+Su+pO8YmOZYp_KHg@mail.gmail.com>
 <CAA93jw4XeMSxiTLHWZ2b=F9ni7wz9RpkWDdhTh99gn4Mf1aWjA@mail.gmail.com>
 <CACiydbLcYe=2VLb3W9i-i2FGALwxJK=oO8RcZWjmj3YPGObK3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: make-wifi-fast@lists.bufferbloat.net,
 =?UTF-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>,
 ath10k <ath10k@lists.infradead.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "codel@lists.bufferbloat.net" <codel@lists.bufferbloat.net>,
 Jonathan Morton <chromatix99@gmail.com>,
 OpenWrt Development List <openwrt-devel@lists.openwrt.org>,
 Felix Fietkau <nbd@nbd.name>
To: Roman Yeryomin <leroi.lists@gmail.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <CACiydbLcYe=2VLb3W9i-i2FGALwxJK=oO8RcZWjmj3YPGObK3Q@mail.gmail.com>
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

T24gTW9uLCAyMDE2LTA1LTE2IGF0IDAxOjM0ICswMzAwLCBSb21hbiBZZXJ5b21pbiB3cm90ZToK
Cj4gcWRpc2MgZnFfY29kZWwgODAwMzogcGFyZW50IDozIGxpbWl0IDEwMjRwIGZsb3dzIDE2IHF1
YW50dW0gMTUxNAo+IHRhcmdldCA4MC4wbXMgY2VfdGhyZXNob2xkIDMydXMgaW50ZXJ2YWwgMTAw
LjBtcyBlY24KPiAgU2VudCAxNjAxMjcxMTY4IGJ5dGVzIDEwNTc3MDYgcGt0IChkcm9wcGVkIDE0
MjIzMDQsIG92ZXJsaW1pdHMgMCByZXF1ZXVlcyAxNykKPiAgYmFja2xvZyAxNTQxMjUyYiAxMDE4
cCByZXF1ZXVlcyAxNwo+ICAgbWF4cGFja2V0IDE1MTQgZHJvcF9vdmVybGltaXQgMTQyMjMwNCBu
ZXdfZmxvd19jb3VudCAzNSBlY25fbWFyayAwCj4gICBuZXdfZmxvd3NfbGVuIDAgb2xkX2Zsb3dz
X2xlbiAxCgpXaHkgZG8geW91IGhhdmUgY2VfdGhyZXNob2xkIHNldCA/IFlvdSByZWFsbHkgc2hv
dWxkIG5vdCAoZXZlbiBpZiBpdApkb2VzIG5vdCBtYXR0ZXIgZm9yIHRoZSBraW5kIG9mIHRyYWZm
aWMgeW91IGhhdmUgYXQgdGhpcyBtb21lbnQpCgpJZiB5b3VyIGV4cGVjdGVkIGxpbmsgc3BlZWQg
aXMgYXJvdW5kIDFHYnBzLCBvciA4MCwwMDAgcGFja2V0cyBwZXIKc2Vjb25kLCB0aGVuIHlvdSBo
YXZlIHRvIHVuZGVyc3RhbmQgdGhhdCAxMDI0IHBhY2tldHMgbGltaXQgaXMgYWJvdXQgMTIKbXMg
YXQgbW9zdC4KCkV2ZW4gaWYgdGhlIHF1ZXVlIGlzIGZ1bGwsIG1heCBzb2pvdXJuIHRpbWUgb2Yg
YSBwYWNrZXQgd291bGQgYmUgMTIgbXMuCgpJIHJlYWxseSBkbyBub3Qgc2VlIGhvdyAndGFyZ2V0
IDgwIG1zJyBjb3VsZCBiZSBoaXQuCgpZb3UgYmFzaWNhbGx5IGhhdmUgRlEsIHdpdGggbm8gQ29k
ZWwgZWZmZWN0LCBidXQgd2l0aCB0aGUgYXNzb2NpYXRlZApjb3N0IG9mIENvZGVsIChoYXZpbmcg
dG8gdGFrZSB0aW1lc3RhbXBzKQoKCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fXwpDb2RlbCBtYWlsaW5nIGxpc3QKQ29kZWxAbGlzdHMuYnVmZmVyYmxvYXQu
bmV0Cmh0dHBzOi8vbGlzdHMuYnVmZmVyYmxvYXQubmV0L2xpc3RpbmZvL2NvZGVsCg==
