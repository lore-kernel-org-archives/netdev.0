From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [PATCH v2 0/3 net-next] Lockless netlink_lookup()
 with new concurrent hash table
Date: Fri, 1 Aug 2014 09:50:56 +0100
Message-ID: <20140801085056.GD16321@casper.infradead.org>
References: <cover.1406846586.git.tgraf@suug.ch>
 <20140731.223946.2222491319947824077.davem@davemloft.net>
 <20140731.224659.1839149761075616147.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org,
 paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, walpole-sKt6ljEC1JY3uPMLIKxrzw@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140731.224659.1839149761075616147.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

T24gMDcvMzEvMTQgYXQgMTA6NDZwbSwgRGF2aWQgTWlsbGVyIHdyb3RlOgo+IEZyb206IERhdmlk
IE1pbGxlciA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD4KPiBEYXRlOiBUaHUsIDMxIEp1bCAyMDE0IDIy
OjM5OjQ2IC0wNzAwIChQRFQpCj4gCj4gPiBMb29rcyBncmVhdCwgc2VyaWVzIGFwcGxpZWQsIHRo
YW5rcyEKPiAKPiBBY3R1YWxseSwgdGhpcyBuZWVkcyBtb3JlIHdvcmssIHJldmVydGVkOgo+IAo+
IG5ldC9uZXRmaWx0ZXIvbmZ0X2hhc2guYzogSW4gZnVuY3Rpb24g4oCYbmZ0X2hhc2hfZGVzdHJv
eeKAmToKPiBuZXQvbmV0ZmlsdGVyL25mdF9oYXNoLmM6MTgzOjM6IGVycm9yOiDigJhodOKAmSB1
bmRlY2xhcmVkIChmaXJzdCB1c2UgaW4gdGhpcyBmdW5jdGlvbikKPiBuZXQvbmV0ZmlsdGVyL25m
dF9oYXNoLmM6MTgzOjM6IG5vdGU6IGVhY2ggdW5kZWNsYXJlZCBpZGVudGlmaWVyIGlzIHJlcG9y
dGVkIG9ubHkgb25jZSBmb3IgZWFjaCBmdW5jdGlvbiBpdCBhcHBlYXJzIGluCgpTb3JyeSBhYm91
dCB0aGF0LiBSZXNlbmRpbmcuCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNoLm9yZwpodHRwOi8vb3Bl
bnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
