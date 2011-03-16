From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 17/17] net,act_police,rcu: remove rcu_barrier()
Date: Wed, 16 Mar 2011 11:13:11 +0800
Message-ID: <4D802AC7.8040801@cn.fujitsu.com>
References: <4D7F3610.6000809@cn.fujitsu.com>	
	<4D7F3B62.6000005@cn.fujitsu.com>
	<1300187052.10062.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        linux-decnet-user-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
        Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
        linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
        "Pekka Savola \(ipv6\)" <pekkas-UjJjq++bwZ7HOG6cAo2yLw@public.gmane.org>,
        =?UTF-8?B?VXdlIEtsZWluZS1Lw7ZuaWc=?= <u.kleine-koenig-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
        Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
        "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        Sridhar Samudrala <sri-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
        Vlad Yasevich <vladislav.yasevich-VXdhtT5mjnY@public.gmane.org>,
        Hagen Paul Pfeifer <hagen-GvnIQ6b/HdU@public.gmane.org>,
        "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
        Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
        Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Hideaki YOSHIF
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1300187052.10062.12.camel@edumazet-laptop>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

T24gMDMvMTUvMjAxMSAwNzowNCBQTSwgRXJpYyBEdW1hemV0IHdyb3RlOgo+IExlIG1hcmRpIDE1
IG1hcnMgMjAxMSDDoCAxODoxMSArMDgwMCwgTGFpIEppYW5nc2hhbiBhIMOpY3JpdCA6Cj4+Cj4+
IFRoZXJlIGlzIG5vIGNhbGxiYWNrIG9mIHRoaXMgbW9kdWxlIG1heWJlIHF1ZXVlZAo+PiBzaW5j
ZSB3ZSB1c2Uga2ZyZWVfcmN1KCksIHdlIGNhbiBzYWZlbHkgcmVtb3ZlIHRoZSByY3VfYmFycmll
cigpLgo+Pgo+PiBTaWduZWQtb2ZmLWJ5OiBMYWkgSmlhbmdzaGFuIDxsYWlqc0Bjbi5mdWppdHN1
LmNvbT4KPj4gLS0tCj4+ICBuZXQvc2NoZWQvYWN0X3BvbGljZS5jIHwgICAgMSAtCj4+ICAxIGZp
bGVzIGNoYW5nZWQsIDAgaW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbnMoLSkKPj4KPj4gZGlmZiAt
LWdpdCBhL25ldC9zY2hlZC9hY3RfcG9saWNlLmMgYi9uZXQvc2NoZWQvYWN0X3BvbGljZS5jCj4+
IGluZGV4IDA4M2IwOTEuLjIyZTNmOWIgMTAwNjQ0Cj4+IC0tLSBhL25ldC9zY2hlZC9hY3RfcG9s
aWNlLmMKPj4gKysrIGIvbmV0L3NjaGVkL2FjdF9wb2xpY2UuYwo+PiBAQCAtMzk3LDcgKzM5Nyw2
IEBAIHN0YXRpYyB2b2lkIF9fZXhpdAo+PiAgcG9saWNlX2NsZWFudXBfbW9kdWxlKHZvaWQpCj4+
ICB7Cj4+ICAJdGNmX3VucmVnaXN0ZXJfYWN0aW9uKCZhY3RfcG9saWNlX29wcyk7Cj4+IC0JcmN1
X2JhcnJpZXIoKTsgLyogV2FpdCBmb3IgY29tcGxldGlvbiBvZiBjYWxsX3JjdSgpJ3MgKHRjZl9w
b2xpY2VfZnJlZV9yY3UpICovCj4+ICB9Cj4+ICAKPj4gIG1vZHVsZV9pbml0KHBvbGljZV9pbml0
X21vZHVsZSk7Cj4gCj4gCj4gV2h5IGlzIGl0IGEgc2VwYXJhdGUgcGF0Y2gsIGFuZCBub3QgaW5j
bHVkZWQgaW4gcGF0Y2ggNS8xNyA/Cj4gCgpBIHNpbXBsZV9rZnJlZV9jYWxsYmFjaygpIGEgcGF0
Y2gsIGlmIGEgbW9kdWxlIGhhcyBtdWx0aXBsZSBzaW1wbGVfa2ZyZWVfY2FsbGJhY2soKXMsCiJy
Y3VfYmFycmllcigpIiBpbiBtb2R1bGVfZXhpdCBmdW5jdGlvbiBzaG91bGQgb25seSBiZSByZW1v
dmVkIGFmdGVyIGFsbApjYWxsYmFjaygpcyBhcmUgY29udmVydGVkIHRvIGtmcmVlX3JjdSgpLiBT
ZXBhcmF0ZSBwYXRjaGVzIG1ha2VzIHRoaW5ncwpjbGVhcmVyLgpfX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250
YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXgtZm91
bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz
