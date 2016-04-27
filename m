From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 9/9] taskstats: use the libnl API to
 align nlattr on 64-bit
Date: Wed, 27 Apr 2016 17:46:32 +0200
Message-ID: <5720DED8.4090706@6wind.com>
References: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
 <1461339084-3849-10-git-send-email-nicolas.dichtel@6wind.com>
 <57201287.80002@gmail.com> <57206A47.2010906@6wind.com>
 <5720B0A2.1030405@gmail.com>
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
In-Reply-To: <5720B0A2.1030405-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

TGUgMjcvMDQvMjAxNiAxNDoyOSwgQmFsYmlyIFNpbmdoIGEgw6ljcml0IDoKW3NuaXBdCj4gUGxl
YXNlIHRyeQo+IAo+IGh0dHBzOi8vd3d3Lmtlcm5lbC5vcmcvZG9jL0RvY3VtZW50YXRpb24vYWNj
b3VudGluZy9nZXRkZWxheXMuYwpBIHBhdGNoIGZvbGxvd3MgdGhpcyBtYWlsIHRvIGZpeCB0aGF0
LgoKPiAKPiBpb3RvcCB1c2VzIGl0IGFzIHdlbGwuIE15IGNvbmNlcm4gaXMgQUJJIGJyZWFrYWdl
IG9mIHVzZXIgc3BhY2UuCk15IHRlc3QgaXMgb2sgaGVyZSwgSSBkaWRuJ3Qgc2VlIGEgcHJvYmxl
bS4KQ29kZSByZXZpZXcgKGZyb20gaGVyZSBodHRwOi8vcmVwby5vci5jei93L2lvdG9wLmdpdCkg
aXMgYWxzbyBvay4KCgpSZWdhcmRzLApOaWNvbGFzCl9fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNoLm9y
ZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
