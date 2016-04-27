From: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 9/9] taskstats: use the libnl API to
 align nlattr on 64-bit
Date: Wed, 27 Apr 2016 11:14:47 +1000
Message-ID: <57201287.80002@gmail.com>
References: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
 <1461339084-3849-10-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org,
 herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org,
 linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
To: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1461339084-3849-10-git-send-email-nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
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

CgpPbiAyMy8wNC8xNiAwMTozMSwgTmljb2xhcyBEaWNodGVsIHdyb3RlOgo+IEdvYWwgb2YgdGhp
cyBwYXRjaCBpcyB0byB1c2UgdGhlIG5ldyBsaWJubCBBUEkgdG8gYWxpZ24gbmV0bGluayBhdHRy
aWJ1dGUKPiB3aGVuIG5lZWRlZC4KPiBUaGUgbGF5b3V0IG9mIHRoZSBuZXRsaW5rIG1lc3NhZ2Ug
d2lsbCBiZSBhIGJpdCBkaWZmZXJlbnQgYWZ0ZXIgdGhlIHBhdGNoLAo+IGJlY2F1c2UgdGhlIHBh
ZGF0dHIgKFRBU0tTVEFUU19UWVBFX1NUQVRTKSB3aWxsIGJlIGluc2lkZSB0aGUgbmVzdGVkCj4g
YXR0cmlidXRlIGluc3RlYWQgb2YgYmVmb3JlIGl0Lgo+IAo+IFNpZ25lZC1vZmYtYnk6IE5pY29s
YXMgRGljaHRlbCA8bmljb2xhcy5kaWNodGVsQDZ3aW5kLmNvbT4KClRoZSBsYXlvdXQgd2lsbCBj
aGFuZ2UvYnJlYWsgdXNlciBzcGFjZSAtLSBJJ3ZlIG5vdCB0ZXN0ZWQgdGhlIHBhdGNoIHRob3Vn
aC4uCgpCYWxiaXIgU2luZ2guCiAKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX18KZGV2IG1haWxpbmcgbGlzdApkZXZAb3BlbnZzd2l0Y2gub3JnCmh0dHA6Ly9v
cGVudnN3aXRjaC5vcmcvbWFpbG1hbi9saXN0aW5mby9kZXYK
