From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v11 5/6] openvswitch: add layer 3
 flow/port support
Date: Thu, 21 Jul 2016 17:39:51 +0200
Message-ID: <20160721173951.225f9379@griffin>
References: <1467827996-32547-1-git-send-email-simon.horman@netronome.com>
 <1467827996-32547-6-git-send-email-simon.horman@netronome.com>
 <CAOrHB_BYD40ZkWbU0dvhPOCcaCVgooksOUkejxyFoagyoiBTNw@mail.gmail.com>
 <20160713073152.GC29661@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_A1ri6fouFH0H4KpEqg1icCmz+U1tcgn-5BoryX5pb1gw@mail.gmail.com>
 <20160718045025.GA2490@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20160718045025.GA2490-ucRxlxcrRFEsysjaEhV7d2ey4e3TpSOZIxS8c3vjKQDk1uMJSBkQmQ@public.gmane.org>
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

T24gTW9uLCAxOCBKdWwgMjAxNiAxMzo1MDoyNyArMDkwMCwgU2ltb24gSG9ybWFuIHdyb3RlOgo+
IE9uIEZyaSwgSnVsIDE1LCAyMDE2IGF0IDAyOjA3OjM3UE0gLTA3MDAsIHByYXZpbiBzaGVsYXIg
d3JvdGU6Cj4gPiBJIHRoaW5rIHdlIHNob3VsZCBzZW5kIEwyIGhlYWRlciB3aXRoIGwyIGhlYWRl
ciBwdXNoZWQgb24gc2tiLiBUaGlzIGlzCj4gPiB3aGF0IE9WUyBleHBlY3QuIFRoZSBza2ItcHVz
aCBzaG91bGQgYmUgZG9uZSBmb3IgYWxsIGwyIHBhY2tldHMgcmF0aGVyCj4gPiB0aGFuIGZvciBw
YXJ0aWN1bGFyIHR5cGUgb2YgZGV2aWNlLgo+IAo+IFRoZSBmb2xsb3dpbmcgc2VlbXMgdG8gYWNo
aWV2ZSB0aGF0Lgo+IEppcmksIHdoYXQgZG8geW91IHRoaW5rPwo+IAo+IGRpZmYgLS1naXQgYS9u
ZXQvaXB2NC9pcF9ncmUuYyBiL25ldC9pcHY0L2lwX2dyZS5jCj4gaW5kZXggYTIwMjQ4MzU1ZGEw
Li5lZGJjMTA2OTBiNjAgMTAwNjQ0Cj4gLS0tIGEvbmV0L2lwdjQvaXBfZ3JlLmMKPiArKysgYi9u
ZXQvaXB2NC9pcF9ncmUuYwo+IEBAIC0yODEsMTAgKzI4MSw5IEBAIHN0YXRpYyBpbnQgX19pcGdy
ZV9yY3Yoc3RydWN0IHNrX2J1ZmYgKnNrYiwgY29uc3Qgc3RydWN0IHRubF9wdGtfaW5mbyAqdHBp
LAo+ICAJCQkJCSAgIHJhd19wcm90bywgZmFsc2UpIDwgMCkKPiAgCQkJZ290byBkcm9wOwo+ICAK
PiAtCQlpZiAodHVubmVsLT5kZXYtPnR5cGUgIT0gQVJQSFJEX05PTkUpCj4gKwkJaWYgKHR1bm5l
bC0+ZGV2LT50eXBlICE9IEFSUEhSRF9OT05FIHx8Cj4gKwkJICAgIHRwaS0+cHJvdG8gPT0gaHRv
bnMoRVRIX1BfVEVCKSkKPiAgCQkJc2tiX3BvcF9tYWNfaGVhZGVyKHNrYik7CgpUaGlzIGlzIHdy
b25nLiBUaGUgTUFDIGhlYWRlciBmb3IgQVJQSFJEX05PTkUgaW50ZXJmYWNlcyBpcyBudWxsLAp0
aGF0J3MgdGhlIG1lYW5pbmcgb2YgQVJQSFJEX05PTkUuIG1hY19oZWFkZXIgY2Fubm90IHBvaW50
IHRvIHRoZSBvdXRlcgpJUCBoZWFkZXIuIFRoYXQgd291bGQgYmUgQVJQSFJEX0lQR1JFLgoKIEpp
cmkKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KZGV2IG1h
aWxpbmcgbGlzdApkZXZAb3BlbnZzd2l0Y2gub3JnCmh0dHA6Ly9vcGVudnN3aXRjaC5vcmcvbWFp
bG1hbi9saXN0aW5mby9kZXYK
