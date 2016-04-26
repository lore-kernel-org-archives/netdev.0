From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 3/8] fs/quota: use nla_put_u64_64bit()
Date: Tue, 26 Apr 2016 14:31:58 +0200
Message-ID: <571F5FBE.8050900@6wind.com>
References: <1461657978-13360-1-git-send-email-nicolas.dichtel@6wind.com>
 <1461657978-13360-4-git-send-email-nicolas.dichtel@6wind.com>
 <20160426110848.GD27612@quack2.suse.cz>
Reply-To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, sd-y1jBWg8GRStKuXlAQpz2QA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
 lars.ellenberg-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org, jack-IBi9RG/b67k@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
 philipp.reisner-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
 drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
To: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20160426110848.GD27612-4I4JzKEfoa/jFM9bn6wA6Q@public.gmane.org>
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

TGUgMjYvMDQvMjAxNiAxMzowOCwgSmFuIEthcmEgYSDDqWNyaXQgOgo+IE9uIFR1ZSAyNi0wNC0x
NiAxMDowNjoxMywgTmljb2xhcyBEaWNodGVsIHdyb3RlOgo+PiBTaWduZWQtb2ZmLWJ5OiBOaWNv
bGFzIERpY2h0ZWwgPG5pY29sYXMuZGljaHRlbEA2d2luZC5jb20+Cj4gCj4gT0ssIHNvIEkgc29t
ZXdoYXQgbWlzcyBhIGRlc2NyaXB0aW9uIG9mIHdoYXQgd2lsbCB0aGlzIGRvIHRvIHRoZSBuZXRs
aW5rCj4gbWVzc2FnZSBzbyB0aGF0IEkgY2FuIGp1ZGdlIHdoZXRoZXIgdGhlIGNoYW5nZSBpcyBm
aW5lIGZvciB0aGUgdXNlcnNwYWNlCj4gY291bnRlcnBhcnQgcGFyc2luZyB0aGVzZSBtZXNzYWdl
cy4gQUZBSVUgdGhpcyBjaGFuZ2VzIHRoZSBtZXNzYWdlIGZvcm1hdAo+IGJ5IGFkZGluZyBhIFFV
T1RBX05MX0FfUEFEIGZpZWxkIGJlZm9yZSBlYWNoIDY0LWJpdCBmaWVsZCB3aGljaCBuZWVkcyBh
bgo+IGFsaWdubWVudCwgYW0gSSBndWVzc2luZyByaWdodD8gVGh1cyB3aGVuIHRoZSB1c2Vyc3Bh
Y2UgY291bnRlcnBhcnQgdXNlcwo+IGdlbmxtc2dfcGFyc2UoKSBpdCBzaG91bGQganVzdCBzaWxl
bnRseSBpZ25vcmUgdGhlc2UgYXR0cmlidXRlcyBpZiBJIHJlYWQKPiB0aGUgZG9jdW1lbnRhdGlv
biByaWdodC4gRGlkIEkgdW5kZXJzdGFuZCB0aGlzIGNvcnJlY3RseT8KWWVzLCB0aGF0J3MgaXQu
CgoKUmVnYXJkcywKTmljb2xhcwpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29w
ZW52c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
