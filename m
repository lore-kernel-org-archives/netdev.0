From: Joe Stringer <joe-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH net-next v11 5/6] openvswitch: add layer 3
 flow/port support
Date: Wed, 10 Aug 2016 10:17:30 -0700
Message-ID: <CAPWQB7F4bSMUhzoCJhEk5bP7V_yOTvBQwDmzCXb6Jpa72ov76g@mail.gmail.com>
References: <1467827996-32547-6-git-send-email-simon.horman@netronome.com>
 <CAOrHB_BYD40ZkWbU0dvhPOCcaCVgooksOUkejxyFoagyoiBTNw@mail.gmail.com>
 <20160713073152.GC29661@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_A1ri6fouFH0H4KpEqg1icCmz+U1tcgn-5BoryX5pb1gw@mail.gmail.com>
 <20160718045025.GA2490@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_C3Hq-V4uPWLELSc2VMywjYSnKiFJ4VJQDnPpCu7s1Xkw@mail.gmail.com>
 <20160720000243.GA4688@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_CUPCfAPKfoco9GghiAZ=QyEqxpd90uo3NvEtG9STXMVA@mail.gmail.com>
 <20160808151716.GA8477@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_BYtGsWPSs2pxTjPajqFEP=5YySmqjc93NbdtY96-dYfw@mail.gmail.com>
 <20160810102043.GE5451@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20160810102043.GE5451-ucRxlxcrRFEsysjaEhV7d2ey4e3TpSOZIxS8c3vjKQDk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

T24gMTAgQXVndXN0IDIwMTYgYXQgMDM6MjAsIFNpbW9uIEhvcm1hbiA8c2ltb24uaG9ybWFuQG5l
dHJvbm9tZS5jb20+IHdyb3RlOgo+IE9uIFR1ZSwgQXVnIDA5LCAyMDE2IGF0IDA4OjQ3OjQwQU0g
LTA3MDAsIHByYXZpbiBzaGVsYXIgd3JvdGU6Cj4+IE9uIE1vbiwgQXVnIDgsIDIwMTYgYXQgODox
NyBBTSwgU2ltb24gSG9ybWFuIDxzaW1vbi5ob3JtYW5AbmV0cm9ub21lLmNvbT4gd3JvdGU6Cj4+
ID4gTGlnaHQgdGVzdGluZyBzZWVtcyB0byBpbmRpY2F0ZSB0aGF0IGl0IHdvcmtzIGZvciBHU08g
c2ticwo+PiA+IHJlY2VpdmVkIG92ZXIgYm90aCBMMyBhbmQgTDIgR1JFIHR1bm5lbHMgYnkgT3ZT
IHdpdGggYm90aAo+PiA+IElQLWluLU1QTFMgYW5kIElQICh3aXRob3V0IE1QTFMpIHBheWxvYWRz
Lgo+PiA+Cj4+Cj4+IFRoYW5rcyBmb3IgdGVzdGluZyBpdC4gQ2FuIHlvdSBhbHNvIGFkZCB0aG9z
ZSB0ZXN0cyB0byBPVlMga21vZCB0ZXN0IHN1aXRlPwo+PiAuLgo+Cj4gU3VyZSwgSSB3aWxsIGxv
b2sgaW50byBkb2luZyB0aGF0Lgo+IEFtIEkgY29ycmVjdCBpbiB0aGlua2luZyBKb2UgU3RyaW5n
ZXIgaXMgdGhlIGJlc3QgcGVyc29uIHRvIGNvbnRhY3QgaWYKPiBJIHJ1biBpbnRvIHRyb3VibGUg
dGhlcmU/CgpTdXJlLiBUaGUgYmFzaWNzIG9mIHJ1bm5pbmcgdGhlIHRlc3RzIGlzIGRvY3VtZW50
ZWQgaGVyZToKaHR0cHM6Ly9naXRodWIuY29tL29wZW52c3dpdGNoL292cy9ibG9iL21hc3Rlci9J
TlNUQUxMLm1kI2RhdGFwYXRoLXRlc3RpbmcKCllvdSBzaG91bGQgYmUgYWJsZSB0byBnZXQgYSBn
b29kIGZlZWwgZm9yIGhvdyB0byBhZGQgdGVzdHMgYnkgcGVydXNpbmcKdGhlIGNvbW1pdHMgdG8g
dGVzdHMvc3lzdGVtLXt0cmFmZmljLGttb2QtbWFjcm9zfS5hdCBpbiB0aGUgT1ZTIHNvdXJjZQp0
cmVlLgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpkZXYg
bWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNoLm9yZy9t
YWlsbWFuL2xpc3RpbmZvL2Rldgo=
