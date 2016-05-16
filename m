From: David Lang <david@lang.hm>
Subject: Re: [Make-wifi-fast] OpenWRT wrong adjustment of fq_codel
 defaults (Was: fq_codel_drop vs a udp flood)
Date: Mon, 16 May 2016 01:46:25 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1605160127430.1574@nftneq.ynat.uz>
References: <CAA93jw6QLyx9EaS+ntB0D3duoysu_Z-UYyQfHnRa=pfqPDfWOw@mail.gmail.com>
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
 <alpine.DEB.2.02.1605160110270.1574@nftneq.ynat.uz>
 <CACiydbL_dfBU=8m=gSSiR6HwdVU+z2WMeQMjP+boNhGe19_7Sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: make-wifi-fast@lists.bufferbloat.net,
 =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
 ath10k <ath10k@lists.infradead.org>,
 "codel@lists.bufferbloat.net" <codel@lists.bufferbloat.net>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 OpenWrt Development List <openwrt-devel@lists.openwrt.org>,
 Felix Fietkau <nbd@nbd.name>
To: Roman Yeryomin <leroi.lists@gmail.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <CACiydbL_dfBU=8m=gSSiR6HwdVU+z2WMeQMjP+boNhGe19_7Sg@mail.gmail.com>
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

T24gTW9uLCAxNiBNYXkgMjAxNiwgUm9tYW4gWWVyeW9taW4gd3JvdGU6Cgo+IE9uIDE2IE1heSAy
MDE2IGF0IDExOjEyLCBEYXZpZCBMYW5nIDxkYXZpZEBsYW5nLmhtPiB3cm90ZToKPj4gT24gTW9u
LCAxNiBNYXkgMjAxNiwgUm9tYW4gWWVyeW9taW4gd3JvdGU6Cj4+Cj4+PiBPbiA2IE1heSAyMDE2
IGF0IDIyOjQzLCBEYXZlIFRhaHQgPGRhdmUudGFodEBnbWFpbC5jb20+IHdyb3RlOgo+Pj4+Cj4+
Pj4gT24gRnJpLCBNYXkgNiwgMjAxNiBhdCAxMTo1NiBBTSwgUm9tYW4gWWVyeW9taW4gPGxlcm9p
Lmxpc3RzQGdtYWlsLmNvbT4KPj4+PiB3cm90ZToKPj4+Pj4KPj4+Pj4gT24gNiBNYXkgMjAxNiBh
dCAyMTo0MywgUm9tYW4gWWVyeW9taW4gPGxlcm9pLmxpc3RzQGdtYWlsLmNvbT4gd3JvdGU6Cj4+
Pj4+Pgo+Pj4+Pj4gT24gNiBNYXkgMjAxNiBhdCAxNTo0NywgSmVzcGVyIERhbmdhYXJkIEJyb3Vl
ciA8YnJvdWVyQHJlZGhhdC5jb20+Cj4+Pj4+PiB3cm90ZToKPj4+Pj4+Pgo+Pj4+Pj4+Cj4+Pgo+
Pj4+IFRoYXQgaXMgdG9vIGxvdyBhIGxpbWl0LCBhbHNvLCBmb3Igbm9ybWFsIHVzZS4gQW5kOgo+
Pj4+IGZvciB0aGUgcHVycG9zZSBvZiB0aGlzIHBhcnRpY3VsYXIgVURQIHRlc3QsIGZsb3dzIDE2
IGlzIG9rLCBidXQgbm90Cj4+Pj4gaWRlYWwuCj4+Pgo+Pj4KPj4+IEkgcGxheWVkIHdpdGggZGlm
ZmVyZW50IGNvbWJpbmF0aW9ucywgaXQgZG9lc24ndCBtYWtlIGFueQo+Pj4gKHNpZ25pZmljYW50
KSBkaWZmZXJlbmNlOiAyMC0zME1icHMsIG5vdCBtb3JlLgo+Pj4gV2hhdCBudW1iZXJzIHdvdWxk
IHlvdSBwcm9wb3NlPwo+Pgo+Pgo+PiBIb3cgbWFueSBkaWZmZXJlbnQgZmxvd3MgZGlkIHlvdSBo
YXZlIGdvaW5nIGF0IG9uY2U/IEkgYmVsaWV2ZSB0aGF0IHRoZQo+PiByZWFzb24gZm9yIGhpZ2hl
ciBudW1iZXJzIGlzbid0IGZvciB0aHJvdWdocHV0LCBidXQgdG8gYWxsb3cgZm9yIG1vcmUgZmxv
d3MKPj4gdG8gYmUgaXNvbGF0ZWQgZnJvbSBlYWNoIG90aGVyLiBJZiB5b3UgaGF2ZSB0b28gZmV3
IGJ1Y2tldHMsIGRpZmZlcmVudCBmbG93cwo+PiB3aWxsIGVuZCB1cCBiZWluZyBjb21iaW5lZCBp
bnRvIG9uZSBidWNrZXQgc28gdGhhdCBvbmUgd2lsbCBhZmZlY3QgdGhlIG90aGVyCj4+IG1vcmUu
Cj4KPiBJJ20gdGVzdGluZyB3aXRoIG9uZSBmbG93LCBJIG5ldmVyIHNhdyBiaWdnZXIgcGVyZm9y
bWFuY2Ugd2l0aCBtb3JlCj4gZmxvd3MgKGUuZy4gLVA4IHRvIGlwZXJmMykuCgpUaGUgaXNzdWUg
aXNuJ3QgcGVyZm9ybWFuY2UsIGl0J3MgaXNvbGF0aW5nIGEgRE5TIHJlcXVlc3QgZnJvbSBhIFZv
SVAgZmxvdyAKZnJvbSBhIHN0cmVhbWluZyB2aWRlbyBmbG93IGZyb20gYSBEVkQgaW1hZ2UgZG93
bmxvYWQuCgpUaGUgcXVlc3Rpb24gaXMgaG93IG1hbnkgYnVja2V0cyBkbyB5b3UgbmVlZCB0byBo
YXZlIHRvIGlzb2xhdGUgdGhlc2UgaW4gCnByYWN0aWNlPyBpdCBkZXBlbmRzIGhvdyBtYW55IGZs
b3dzIHlvdSBoYXZlLiBUaGUgZGVmYXVsdCB3YXMgMTAyNCBidWNrZXRzLCBidXQgCmdvdCBjaGFu
Z2VkIHRvIDEyOCBmb3IgbG93IG1lbW9yeSBkZXZpY2VzLCBhbmQgdGhhdCBsb3dlciB2YWx1ZSBn
b3QgbWFkZSBpbnRvIAp0aGUgZGVmYXVsdCwgZXZlbiBmb3IgZGV2aWNlcyB3aXRoIGxvdHMgb2Yg
bWVtb3J5LgoKSSdtIHdvbmRlcmluZyBpZiBpbnN0ZWFkIG9mIHRyeWluZyB0byBzaXplIHRoaXMg
YmFzZWQgb24gZGV2aWNlIG1lbW9yeSwgY2FuIGl0IApiZSByZXNpemFibGUgb24gdGhlIGZseSBh
bmQgZ3JvdyBpZiB0b28gbWFueSBmbG93cy9jb2xsaXNpb25zIGFyZSBkZXRlY3RlZD8KCkRhdmlk
IExhbmcKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KQ29k
ZWwgbWFpbGluZyBsaXN0CkNvZGVsQGxpc3RzLmJ1ZmZlcmJsb2F0Lm5ldApodHRwczovL2xpc3Rz
LmJ1ZmZlcmJsb2F0Lm5ldC9saXN0aW5mby9jb2RlbAo=
