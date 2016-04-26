From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 0/8] netlink: align attributes when
 needed (patchset #3)
Date: Tue, 26 Apr 2016 12:25:15 -0400 (EDT)
Message-ID: <20160426.122515.1389035390419695445.davem@davemloft.net>
References: <1461657978-13360-1-git-send-email-nicolas.dichtel@6wind.com>
 <20160426115427.GB20950@soda.linbit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, sd-y1jBWg8GRStKuXlAQpz2QA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
 jack-IBi9RG/b67k@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, philipp.reisner-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org,
 johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
To: lars.ellenberg-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20160426115427.GB20950-w1SgEEioFePxa46PmUWvFg@public.gmane.org>
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

RnJvbTogTGFycyBFbGxlbmJlcmcgPGxhcnMuZWxsZW5iZXJnQGxpbmJpdC5jb20+CkRhdGU6IFR1
ZSwgMjYgQXByIDIwMTYgMTM6NTQ6MjcgKzAyMDAKCj4gT24gVHVlLCBBcHIgMjYsIDIwMTYgYXQg
MTA6MDY6MTBBTSArMDIwMCwgTmljb2xhcyBEaWNodGVsIHdyb3RlOgo+PiAKPj4gVGhpcyBpcyB0
aGUgY29udGludWF0aW9uIChzZXJpZXMgIzMpIG9mIHRoZSB3b3JrIGRvbmUgdG8gYWxpZ24gbmV0
bGluawo+PiBhdHRyaWJ1dGVzIHdoZW4gdGhlc2UgYXR0cmlidXRlcyBjb250YWluIHNvbWUgNjQt
Yml0IGZpZWxkcy4KPj4gCj4+IEl0J3MgdGhlIGxhc3QgcGF0Y2hzZXQgZnJvbSB3aGF0IEkndmUg
c2Vlbi4KPj4gCj4+IFRoZSBsYXN0IHVzZXIgb2YgbmxhX3B1dF91NjQoKSBpcyBibG9jay9kcmJk
LiBUaGlzIG1vZHVsZSBkb2VzIG5vdCB1c2UKPj4gc3RhbmRhcmQgbmV0bGluayBBUEkgKHNlZSBh
bGwgdGhlIHN0dWZmIGluIGluY2x1ZGUvbGludXgvZ2VubF9tYWdpY19zdHJ1Y3QuaAo+PiBhbmQg
aW5jbHVkZS9saW51eC9nZW5sX21hZ2ljX2Z1bmMuaCkuIEkgZGlkbid0IG1vZGlmeSBpdCBiZWNh
dXNlIGl0J3Mgc2VlbXMKPj4gaGFyZCB0byBkbyBpdCB3aGl0aG91dCB0ZXN0aW5nIGFuZCBmdWxs
eSB1bmRlcnN0YW5kaW5nIHRoZSBjb250ZXh0Cj4gCj4gU29tZXRoaW5nIGxpa2UgdGhpcyBzaG91
bGQganVzdCB3b3JrLgoKVW5mb3J0dW5hdGVseSB3ZSBoYWQgcHJvYmxlbXMgdXNpbmcgdW5zcGVj
LCB0aGF0J3Mgd2h5IGFuIGV4cGxpY2l0IG5ldwpwYWRkaW5nIGF0dHJpYnV0ZSBpcyBhZGRlZCBm
b3IgZWFjaCBuZXRsaW5rIGF0dHJpYnV0ZSBzZXQuCl9fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNoLm9y
ZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
