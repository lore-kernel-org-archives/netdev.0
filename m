From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH net-next v2 0/5] netns: allow to identify peer netns
Date: Thu, 25 Sep 2014 10:53:28 +0200
Message-ID: <5423D808.7050800@6wind.com>
References: <1411478430-4989-1-git-send-email-nicolas.dichtel@6wind.com>	<CAHA+R7NnBJ=T3sukzzp-OD2am1nd318XbrXCX84LfSL=nu9ojw@mail.gmail.com>	<54228D87.3070309@6wind.com>	<CAHA+R7NfJYzCsZx0E9YVXKVCQbCm_thPSi+80tix8Z9nVA82Ug@mail.gmail.com>	<CAHA+R7MVL=WpepRy8iz6iT6Kkq1RHG+b9TxJothP94ixyAj-3Q@mail.gmail.com>	<5422F1F7.8010308@6wind.com>
	<CAHA+R7MM04ew=J8sHfSQERwoCAgEDfrGgtgRORqs3ePgtjVYWg@mail.gmail.com>
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
In-Reply-To: <CAHA+R7MM04ew=J8sHfSQERwoCAgEDfrGgtgRORqs3ePgtjVYWg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

TGUgMjQvMDkvMjAxNCAxODo0OCwgQ29uZyBXYW5nIGEgw6ljcml0IDoKPiBPbiBXZWQsIFNlcCAy
NCwgMjAxNCBhdCA5OjMxIEFNLCBOaWNvbGFzIERpY2h0ZWwKPiA8bmljb2xhcy5kaWNodGVsQDZ3
aW5kLmNvbT4gd3JvdGU6Cj4+PiBJIHRoaW5rIGluIHRoaXMgY2FzZSB5b3VyIElEJ3MgYXJlIHN0
aWxsIGF2YWlsYWJsZSwgYnV0IGFyZW4ndCB5b3UKPj4+IHByb3ZpZGluZyBhIG5ldyB3YXkKPj4+
IGZvciB0aGUgaW5uZXIgbmV0bnMgZGV2aWNlIHRvIGVzY2FwZSB3aGljaCB3ZSBhcmUgdHJ5aW5n
IHRvIGF2b2lkPwo+Pgo+PiBJdCdzIHdoeSB0aGUgaWRzIGRlcGVuZCBvbiB1c2VyIG5zLiBPbmx5
IGlmIHVzZXIgbnMgYXJlIHRoZSBzYW1lIHdlIGFsbG93IHRvCj4+IGdldCBhbiBpZCBmb3IgYSBw
ZWVyIG5ldG5zLgo+Cj4gVG9vIGxhdGUsIHVzZXJucyBpcyByZWxhdGl2ZWx5IG5ldywgcmVseWlu
ZyBvbiBpdCBicmVha3Mgb3VyIGV4aXN0aW5nCj4gYXNzdW1wdGlvbi4KPgpJIGRvbid0IGdldCB5
b3VyIHBvaW50LiBuZXRucyBoYXMgYmVlbiBhZGRlZCBpbiBrZXJuZWwgYWZ0ZXIgdXNlciBuczoK
YWNjZTI5MmM4MmQ0IHVzZXIgbmFtZXNwYWNlOiBhZGQgdGhlIGZyYW1ld29yayA9PiAyLjYuMjMK
NWYyNTZiZWNkODY4IFtORVRdOiBCYXNpYyBuZXR3b3JrIG5hbWVzcGFjZSBpbmZyYXN0cnVjdHVy
ZS4gPT4gMi42LjI0CgpJbiB0aGUga2VybmVsLCBlYWNoIG5ldG5zIGlzIGxpbmtlZCB3aXRoIGEg
dXNlciBucy4KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18K
Q29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9u
Lm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9j
b250YWluZXJz
