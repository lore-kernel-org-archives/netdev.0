From: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Subject: Re: [PATCH net-next v11 3/6] openvswitch: set skb
 protocol and mac_len when receiving on internal device
Date: Wed, 13 Jul 2016 16:17:36 +0900
Message-ID: <20160713071734.GA29661@penelope.isobedori.kobe.vergenet.net>
References: <1467827996-32547-1-git-send-email-simon.horman@netronome.com>
 <1467827996-32547-4-git-send-email-simon.horman@netronome.com>
 <CAOrHB_B2VDPcEe0B471J+XjmviAbTO0JRPTHiS7jHzF5V8uHZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: pravin shelar <pshelar-LZ6Gd1LRuIk@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAOrHB_B2VDPcEe0B471J+XjmviAbTO0JRPTHiS7jHzF5V8uHZg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

T24gVGh1LCBKdWwgMDcsIDIwMTYgYXQgMDE6NTI6MjVQTSAtMDcwMCwgcHJhdmluIHNoZWxhciB3
cm90ZToKPiBPbiBXZWQsIEp1bCA2LCAyMDE2IGF0IDEwOjU5IEFNLCBTaW1vbiBIb3JtYW4KPiA8
c2ltb24uaG9ybWFuQG5ldHJvbm9tZS5jb20+IHdyb3RlOgo+ID4gKiBTZXQgc2tiIHByb3RvY29s
IGJhc2VkIG9uIGNvbnRlbnRzIG9mIHBhY2tldC4gSSBoYXZlIG9ic2VydmVkIHRoaXMgaXMKPiA+
ICAgbmVjZXNzYXJ5IHRvIGdldCBhY3R1YWwgcHJvdG9jb2wgb2YgYSBwYWNrZXQgd2hlbiBpdCBp
cyBpbmplY3RlZCBpbnRvIGFuCj4gPiAgIGludGVybmFsIGRldmljZSBlLmcuIGJ5IGxpYm5ldCBp
biB3aGljaCBjYXNlIHNrYiBwcm90b2NvbCB3aWxsIGJlIHNldCB0bwo+ID4gICBFVEhfQUxMLgo+
ID4KPiBJIGFtIG5vdCBzdXJlIHdoYXQgZG8geW8gbWVhbiBieSBFVEhfQUxMLiBJIGNvdWxkIG5v
dCBmaW5kIGl0IGluIHRoZSBrZXJuZWwuCj4gYW55d2F5cywgQ2FuIHdlIGZpeCBsaWJuZXQgdG8g
c2V0IHNrYi0+cHJvdG9jb2wgZmllbGQgY29ycmVjdGx5PyBUaGUKPiBjaGFuZ2UgaXMgaW50cm9k
dWNpbmcgb3ZlcmhlYWQgZm9yIGV2ZXJ5IHBhY2tldCByZWNlaXZlZCBvbiBpbnRlcm5hbAo+IHBv
cnQuCgpJdCB3YXMgcXVpdGUgYSB3aGlsZSBhZ28gc2luY2UgSSB3cm90ZSB0aGlzIHBhdGNoIGFu
ZCBJIGRvbid0IHJlY2FsbCB3aGF0CkkgbWVhbnQgYnkgRVRIX0FMTC4KCkkgbm93IHBsYW4gdG8g
ZHJvcCB0aGlzIHBhdGNoLgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52
c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
