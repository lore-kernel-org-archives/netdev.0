From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Make-wifi-fast] OpenWRT wrong adjustment of fq_codel
 defaults (Was: fq_codel_drop vs a udp flood)
Date: Mon, 16 May 2016 07:23:02 -0700
Message-ID: <1463408582.18194.84.camel@edumazet-glaptop3.roam.corp.google.com>
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
 <CACiydbJWY7xK1tj1Q-umdSNkTy9V+HYQ6SeOxihMASwr1zcApg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Rajkumar Manoharan <rmanohar@codeaurora.org>,
 make-wifi-fast@lists.bufferbloat.net,
 =?UTF-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>,
 ath10k <ath10k@lists.infradead.org>,
 "codel@lists.bufferbloat.net" <codel@lists.bufferbloat.net>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 OpenWrt Development List <openwrt-devel@lists.openwrt.org>,
 Felix Fietkau <nbd@nbd.name>
To: Roman Yeryomin <leroi.lists@gmail.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <CACiydbJWY7xK1tj1Q-umdSNkTy9V+HYQ6SeOxihMASwr1zcApg@mail.gmail.com>
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

T24gTW9uLCAyMDE2LTA1LTE2IGF0IDExOjE0ICswMzAwLCBSb21hbiBZZXJ5b21pbiB3cm90ZToK
Cj4gU28sIHZlcnkgY2xvc2UgdG8gImFzIGJlZm9yZSI6IDkwME1icHMgVURQLCA3NTAgVENQLgo+
IEJ1dCBzdGlsbCwgSSB3YXMgZXhwZWN0aW5nIHBlcmZvcm1hbmNlIGltcHJvdmVtZW50cyBmcm9t
IGxhdGVzdCBhdGgxMGsKPiBjb2RlLCBub3QgcmVncmVzc2lvbnMuCj4gSSBrbm93IHRoYXQgaHcg
aXMgY2FwYWJsZSBvZiA4MDBNYnBzIFRDUCwgd2hpY2ggSSdtIHRhcmdldGluZy4KCk9uZSBmbG93
IGNhbiByZWFjaCA4MDBNYnBzLgoKVG8gZ2V0IHRoaXMsIGEgc2ltcGxlIHBmaWZvIGlzIGVub3Vn
aC4KCkJ1dCBfaWZfIHlvdSBhbHNvIHdhbnQgdG8gZ2V0IGRlY2VudCByZXN1bHRzIHdpdGggaHVu
ZHJlZHMgb2YgZmxvd3MKdW5kZXIgc3RyZXNzLCB5b3UgbmVlZCBzb21ldGhpbmcgZWxzZSwgYW5k
IEkgZG8gbm90IHNlZSBob3cgJ3NvbWV0aGluZycKZWxzZSB3b3VsZCBjb21lIGZvciBmcmVlLgoK
WW91IHdpbGwgc2VlIHNvbWUgJ3JlZ3Jlc3Npb25zJyBiZWNhdXNlIG9mIGFkZGl0aW9uYWwgY3B1
IGNvc3RzLCB1bmxlc3MKeW91IGhhdmUgZW5vdWdoIGNwdSBjeWNsZXMgYW5kIEtCIG9mIG1lbW9y
eSB0byBidXJuIGZvciBmcmVlLgoKSWYgeW91ciBnb2FsIGlzIHRvIGdldCBtYXggdGhyb3VnaHB1
dCBvbiBhIHNpbmdsZSBUQ1AgZmxvdywgaW4gYSBjbGVhbgplbnYgYW4gY2hlYXAgaGFyZHdhcmUs
IHlvdSBhYnNvbHV0ZWx5IHNob3VsZCBzdGljayB0byBwZmlmby4gTm90aGluZwpjb3VsZCBiZWF0
IHBmaWZvICh3ZWxsLCBwZmlmbyBjb3VsZCBiZSBpbXByb3ZlZCB1c2luZyBsb2NrbGVzcwppbXBs
ZW1lbnRhdGlvbiwgYnV0IHRoYXQgd291bGQgbWF0dGVyIGlmIHlvdSBoYXZlIGRpZmZlcmVudCBj
cHVzCnF1ZXVlaW5nIGFuZCBkZXF1ZXVlaW5nIHBhY2tldHMpCgpCdXQgSSBndWVzcyB5b3VyIGlz
c3VlcyBtb3N0bHkgY29tZSBmcm9tIGEgdG9vIHNtYWxsIHBhY2tldCBsaW1pdHMsIG9yCnRvIGJp
ZyBUQ1Agd2luZG93cy4KCkJhc2ljYWxseSwgaWYgeW91IHRlc3QgYSBzaW5nbGUgVENQIGZsb3cs
IGZxX2NvZGVsIHNob3VsZCBiZWhhdmUgbGlrZSBhCnBmaWZvLCB1bmxlc3MgbWF5YmUgeW91ciBr
ZXJuZWwgaGFzIGEgdmVyeSBzbG93IGt0aW1lX2dldF9ucygpCmltcGxlbWVudGF0aW9uIFsxXQoK
SWYgeW91IHNldCBhIGxpbWl0IG9mIDEwMjQgcGFja2V0cyBvbiBwZmlmbywgeW91J2xsIGhhdmUg
dGhlIHNhbWUgYW1vdW50Cm9mIGRyb3BzIGFuZCBsb3dlciBUQ1AgdGhyb3VnaHB1dC4KClsxXSBX
ZSBwcm9iYWJseSBzaG91bGQgaGF2ZSBhIHNlbGYtdGVzdCB0byBoYXZlIGFuIGVzdGltYXRpb24g
b2YKa3RpbWVfZ2V0X25zKCkgY29zdAoKCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fXwpDb2RlbCBtYWlsaW5nIGxpc3QKQ29kZWxAbGlzdHMuYnVmZmVyYmxv
YXQubmV0Cmh0dHBzOi8vbGlzdHMuYnVmZmVyYmxvYXQubmV0L2xpc3RpbmZvL2NvZGVsCg==
