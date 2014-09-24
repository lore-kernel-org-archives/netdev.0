From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH net-next v2 0/5] netns: allow to identify peer netns
Date: Wed, 24 Sep 2014 18:31:51 +0200
Message-ID: <5422F1F7.8010308@6wind.com>
References: <1411478430-4989-1-git-send-email-nicolas.dichtel@6wind.com>	<CAHA+R7NnBJ=T3sukzzp-OD2am1nd318XbrXCX84LfSL=nu9ojw@mail.gmail.com>	<54228D87.3070309@6wind.com>	<CAHA+R7NfJYzCsZx0E9YVXKVCQbCm_thPSi+80tix8Z9nVA82Ug@mail.gmail.com>
	<CAHA+R7MVL=WpepRy8iz6iT6Kkq1RHG+b9TxJothP94ixyAj-3Q@mail.gmail.com>
Reply-To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Cong Wang <cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAHA+R7MVL=WpepRy8iz6iT6Kkq1RHG+b9TxJothP94ixyAj-3Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

TGUgMjQvMDkvMjAxNCAxODoxNSwgQ29uZyBXYW5nIGEgw6ljcml0IDoKPiBPbiBXZWQsIFNlcCAy
NCwgMjAxNCBhdCA5OjAxIEFNLCBDb25nIFdhbmcgPGN3YW5nQHR3b3BlbnNvdXJjZS5jb20+IHdy
b3RlOgo+Pgo+PiBBbmQgY2xlYXJseSB5b3UgbWlzc2VkIG15IHF1ZXN0aW9uIGFib3ZlOiBob3cg
ZG8geW91IGdldCBuZXRucyBpZAo+PiB3aXRob3V0IHNoYXJpbmcgL3Zhci9ydW4vbmV0bnMvID8K
Pgo+IE9LLCBJIGZvdW5kIGl0Ogo+Cj4+IElkcyBhcmUgc3RvcmVkIGluIHRoZSBwYXJlbnQgdXNl
ciBuYW1lc3BhY2UuIFRoZXNlIGlkcyBhcmUgdmFsaWQgb25seSBpbnNpZGUKPj4gdGhpcyB1c2Vy
IG5hbWVzcGFjZS4gVGhlIHVzZXIgY2FuIHJldHJpZXZlIHRoZXNlIGlkcyB2aWEgYSBuZXcgbmV0
bGluayBtZXNzYWdlcywKPj4gYnV0IG9ubHkgaWYgcGVlciBuZXRucyBhcmUgaW4gdGhlIHNhbWUg
dXNlciBuYW1lc3BhY2UuCj4KPiBTbyB5b3VyIGV4YW1wbGUgaXMgY29uZnVzaW5nLCBwZXJoYXBz
IHlvdSBuZWVkIHNvbWUgb3RoZXIgd2F5IHRvIHNob3cgdGhlIElEJ3MKPiBpbnN0ZWFkIG9mIGJp
bmRpbmcgdG8gaXAgbmV0bnMgb3V0cHV0IHdoaWNoIGlzIGJhc2ljYWxseSBscwo+IC92YXIvcnVu
L25ldG5zLy4gV2UgZG9uJ3QKPiB3YW50IGFuIGlubmVyIG5ldG5zIGtub3cgYW55dGhpbmcgb3V0
c2lkZSwgSU9XLCB3ZSBkb24ndCBzaGFyZSAvdmFyL3J1bi9uZXRucy8uCkhtbSwgbm90IHN1cmUg
dG8gdW5kZXJzdGFuZCB5b3UuIE15IHVzZWNhc2Ugc2hhcmVzIC92YXIvcnVuL25ldG5zLCBiZWNh
dXNlCnRoZXJlIGlzIG9ubHkgb25lIHVzZXIgbnMgYW5kIG9uZSBtb3VudCBucy4KCj4gSSB0aGlu
ayBpbiB0aGlzIGNhc2UgeW91ciBJRCdzIGFyZSBzdGlsbCBhdmFpbGFibGUsIGJ1dCBhcmVuJ3Qg
eW91Cj4gcHJvdmlkaW5nIGEgbmV3IHdheQo+IGZvciB0aGUgaW5uZXIgbmV0bnMgZGV2aWNlIHRv
IGVzY2FwZSB3aGljaCB3ZSBhcmUgdHJ5aW5nIHRvIGF2b2lkPwpJdCdzIHdoeSB0aGUgaWRzIGRl
cGVuZCBvbiB1c2VyIG5zLiBPbmx5IGlmIHVzZXIgbnMgYXJlIHRoZSBzYW1lIHdlIGFsbG93IHRv
CmdldCBhbiBpZCBmb3IgYSBwZWVyIG5ldG5zLgpfX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxp
c3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9y
Zy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=
