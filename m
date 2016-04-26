From: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH net-next 3/8] fs/quota: use nla_put_u64_64bit()
Date: Tue, 26 Apr 2016 14:37:07 +0200
Message-ID: <20160426123707.GE27612@quack2.suse.cz>
References: <1461657978-13360-1-git-send-email-nicolas.dichtel@6wind.com>
 <1461657978-13360-4-git-send-email-nicolas.dichtel@6wind.com>
 <20160426110848.GD27612@quack2.suse.cz>
 <571F5FBE.8050900@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, sd-y1jBWg8GRStKuXlAQpz2QA@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, lars.ellenberg-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org,
 jack-IBi9RG/b67k@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, philipp.reisner-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
To: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <571F5FBE.8050900-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
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

T24gVHVlIDI2LTA0LTE2IDE0OjMxOjU4LCBOaWNvbGFzIERpY2h0ZWwgd3JvdGU6Cj4gTGUgMjYv
MDQvMjAxNiAxMzowOCwgSmFuIEthcmEgYSDDqWNyaXQgOgo+ID4gT24gVHVlIDI2LTA0LTE2IDEw
OjA2OjEzLCBOaWNvbGFzIERpY2h0ZWwgd3JvdGU6Cj4gPj4gU2lnbmVkLW9mZi1ieTogTmljb2xh
cyBEaWNodGVsIDxuaWNvbGFzLmRpY2h0ZWxANndpbmQuY29tPgo+ID4gCj4gPiBPSywgc28gSSBz
b21ld2hhdCBtaXNzIGEgZGVzY3JpcHRpb24gb2Ygd2hhdCB3aWxsIHRoaXMgZG8gdG8gdGhlIG5l
dGxpbmsKPiA+IG1lc3NhZ2Ugc28gdGhhdCBJIGNhbiBqdWRnZSB3aGV0aGVyIHRoZSBjaGFuZ2Ug
aXMgZmluZSBmb3IgdGhlIHVzZXJzcGFjZQo+ID4gY291bnRlcnBhcnQgcGFyc2luZyB0aGVzZSBt
ZXNzYWdlcy4gQUZBSVUgdGhpcyBjaGFuZ2VzIHRoZSBtZXNzYWdlIGZvcm1hdAo+ID4gYnkgYWRk
aW5nIGEgUVVPVEFfTkxfQV9QQUQgZmllbGQgYmVmb3JlIGVhY2ggNjQtYml0IGZpZWxkIHdoaWNo
IG5lZWRzIGFuCj4gPiBhbGlnbm1lbnQsIGFtIEkgZ3Vlc3NpbmcgcmlnaHQ/IFRodXMgd2hlbiB0
aGUgdXNlcnNwYWNlIGNvdW50ZXJwYXJ0IHVzZXMKPiA+IGdlbmxtc2dfcGFyc2UoKSBpdCBzaG91
bGQganVzdCBzaWxlbnRseSBpZ25vcmUgdGhlc2UgYXR0cmlidXRlcyBpZiBJIHJlYWQKPiA+IHRo
ZSBkb2N1bWVudGF0aW9uIHJpZ2h0LiBEaWQgSSB1bmRlcnN0YW5kIHRoaXMgY29ycmVjdGx5Pwo+
IFllcywgdGhhdCdzIGl0LgoKT0ssIHRoZW4gZmVlbCBmcmVlIHRvIGFkZDoKCkFja2VkLWJ5OiBK
YW4gS2FyYSA8amFja0BzdXNlLmN6PgoKdG8gdGhlIHF1b3RhIHBhdGNoLgoKCQkJCQkJCQlIb256
YQoKLS0gCkphbiBLYXJhIDxqYWNrQHN1c2UuY29tPgpTVVNFIExhYnMsIENSCl9fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2
QG9wZW52c3dpdGNoLm9yZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8v
ZGV2Cg==
