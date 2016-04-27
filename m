From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 9/9] taskstats: use the libnl API to
 align nlattr on 64-bit
Date: Wed, 27 Apr 2016 09:29:11 +0200
Message-ID: <57206A47.2010906@6wind.com>
References: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
 <1461339084-3849-10-git-send-email-nicolas.dichtel@6wind.com>
 <57201287.80002@gmail.com>
Reply-To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org,
 herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org,
 linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
To: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <57201287.80002-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

TGUgMjcvMDQvMjAxNiAwMzoxNCwgQmFsYmlyIFNpbmdoIGEgw6ljcml0IDoKPiAKPiAKPiBPbiAy
My8wNC8xNiAwMTozMSwgTmljb2xhcyBEaWNodGVsIHdyb3RlOgo+PiBHb2FsIG9mIHRoaXMgcGF0
Y2ggaXMgdG8gdXNlIHRoZSBuZXcgbGlibmwgQVBJIHRvIGFsaWduIG5ldGxpbmsgYXR0cmlidXRl
Cj4+IHdoZW4gbmVlZGVkLgo+PiBUaGUgbGF5b3V0IG9mIHRoZSBuZXRsaW5rIG1lc3NhZ2Ugd2ls
bCBiZSBhIGJpdCBkaWZmZXJlbnQgYWZ0ZXIgdGhlIHBhdGNoLAo+PiBiZWNhdXNlIHRoZSBwYWRh
dHRyIChUQVNLU1RBVFNfVFlQRV9TVEFUUykgd2lsbCBiZSBpbnNpZGUgdGhlIG5lc3RlZAo+PiBh
dHRyaWJ1dGUgaW5zdGVhZCBvZiBiZWZvcmUgaXQuCj4+Cj4+IFNpZ25lZC1vZmYtYnk6IE5pY29s
YXMgRGljaHRlbCA8bmljb2xhcy5kaWNodGVsQDZ3aW5kLmNvbT4KPiAKPiBUaGUgbGF5b3V0IHdp
bGwgY2hhbmdlL2JyZWFrIHVzZXIgc3BhY2UgLS0gSSd2ZSBub3QgdGVzdGVkIHRoZSBwYXRjaCB0
aG91Z2guLgpTaWdoLgoKSSBxdW90ZSBEYXZpZDoKIkFsbCB1c2Vyc3BhY2UgY29tcG9uZW50cyB1
c2luZyBuZXRsaW5rIHNob3VsZCBhbHdheXMgaWdub3JlIGF0dHJpYnV0ZXMKdGhleSBkbyBub3Qg
cmVjb2duaXplIGluIGR1bXBzLgoKVGhpcyBpcyBvbmUgb2YgdGhlIG1vc3QgYmFzaWMgcHJpbmNp
cGxlcyBvZiBuZXRsaW5rIgoKRG8geW91IGhhdmUgc29tZSBwb2ludGVycyBzbyBJIGNhbiBtYWRl
IHNvbWUgdGVzdHM/CgoKUmVnYXJkcywKTmljb2xhcwpfX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5v
cmcKaHR0cDovL29wZW52c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
