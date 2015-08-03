From: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2] openvswitch: Fix L4 checksum handling when
 dealing with IP fragments
Date: Mon, 3 Aug 2015 10:10:56 -0700
Message-ID: <CALnjE+r3sQXQ-Viw6goVY0Mb0EhFggGzR5TYkQHGUbg8tKFJ2Q@mail.gmail.com>
References: <20150803165654.GA16892@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Glenn Griffin <ggriffin.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20150803165654.GA16892-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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

T24gTW9uLCBBdWcgMywgMjAxNSBhdCA5OjU2IEFNLCBHbGVubiBHcmlmZmluIDxnZ3JpZmZpbi5r
ZXJuZWxAZ21haWwuY29tPiB3cm90ZToKPiBvcGVudnN3aXRjaCBtb2RpZmllcyB0aGUgTDQgY2hl
Y2tzdW0gb2YgYSBwYWNrZXQgd2hlbiBtb2RpZnlpbmcKPiB0aGUgaXAgYWRkcmVzcy4gV2hlbiBh
biBJUCBwYWNrZXQgaXMgZnJhZ21lbnRlZCBvbmx5IHRoZSBmaXJzdAo+IGZyYWdtZW50IGNvbnRh
aW5zIGFuIEw0IGhlYWRlciBhbmQgY2hlY2tzdW0uIFByaW9yIHRvIHRoaXMgY2hhbmdlCj4gb3Bl
bnZzd2l0Y2ggd291bGQgbW9kaWZ5IGFsbCBmcmFnbWVudHMsIG1vZGlmeWluZyBhcHBsaWNhdGlv
biBkYXRhCj4gaW4gbm9uLWZpcnN0IGZyYWdtZW50cywgY2F1c2luZyBjaGVja3N1bSBmYWlsdXJl
cyBpbiB0aGUKPiByZWFzc2VtYmxlZCBwYWNrZXQuCj4KPiBTaWduZWQtb2ZmLWJ5OiBHbGVubiBH
cmlmZmluIDxnZ3JpZmZpbi5rZXJuZWxAZ21haWwuY29tPgoKTG9va3MgZ29vZC4KQWNrZWQtYnk6
IFByYXZpbiBCIFNoZWxhciA8cHNoZWxhckBuaWNpcmEuY29tPgoKVGhpcyBwYXRjaCBuZWVkcyB0
byBiZSBiYWNrcG9ydGVkIHRvIHN0YWJsZSBicmFuY2hlcy4KClRoYW5rcy4KX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KZGV2IG1haWxpbmcgbGlzdApkZXZA
b3BlbnZzd2l0Y2gub3JnCmh0dHA6Ly9vcGVudnN3aXRjaC5vcmcvbWFpbG1hbi9saXN0aW5mby9k
ZXYK
