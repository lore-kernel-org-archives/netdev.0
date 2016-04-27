From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] taskstats: fix nl parsing in
 accounting/getdelays.c
Date: Wed, 27 Apr 2016 17:49:53 +0200
Message-ID: <5720DFA1.3080503@6wind.com>
References: <5720DED8.4090706@6wind.com>
 <1461772077-3216-1-git-send-email-nicolas.dichtel@6wind.com>
Reply-To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org,
 herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org,
 netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org,
 kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
To: bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1461772077-3216-1-git-send-email-nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
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

TGUgMjcvMDQvMjAxNiAxNzo0NywgTmljb2xhcyBEaWNodGVsIGEgw6ljcml0IDoKPiBUaGUgdHlw
ZSBUQVNLU1RBVFNfVFlQRV9OVUxMIHNob3VsZCBhbHdheXMgYmUgaWdub3JlZC4KPiAKPiBXaGVu
IGp1bXBpbmcgdG8gdGhlIG5leHQgYXR0cmlidXRlLCBvbmx5IHRoZSBsZW5ndGggb2YgdGhlIGN1
cnJlbnQKPiBhdHRyaWJ1dGUgc2hvdWxkIGJlIGFkZGVkLCBub3QgdGhlIGxlbmd0aCBvZiBhbGwg
bmVzdGVkIGF0dHJpYnV0ZXMuCj4gVGhpcyBsYXN0IGJ1ZyB3YXMgbm90IHZpc2libGUgYmVmb3Jl
IGNvbW1pdCA4MGRmNTU0Mjc1YzIsIGJlY2F1c2UgdGhlCj4ga2VybmVsIGRpZG4ndCBwdXQgbW9y
ZSB0aGFuIHR3byBuZXN0ZWQgYXR0cmlidXRlcy4KPiAKPiBGaXhlczogYTNiYWY2NDljYTljICgi
W1BBVENIXSBwZXItdGFzay1kZWxheS1hY2NvdW50aW5nOiBkb2N1bWVudGF0aW9uIikKPiBGaXhl
czogODBkZjU1NDI3NWMyICgidGFza3N0YXRzOiB1c2UgdGhlIGxpYm5sIEFQSSB0byBhbGlnbiBu
bGF0dHIgb24gNjQtYml0IikKPiBTaWduZWQtb2ZmLWJ5OiBOaWNvbGFzIERpY2h0ZWwgPG5pY29s
YXMuZGljaHRlbEA2d2luZC5jb20+ClBsZWFzZSwgZHJvcCB0aGlzIHZlcnNpb24uIEkgZmF0Zmlu
Z2VyZWQgbXkgcmViYXNlLgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52
c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
