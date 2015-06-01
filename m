From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [net-next RFC 05/14] route: Per route tunnel metadata
 with RTA_TUNNEL
Date: Tue, 2 Jun 2015 01:26:08 +0200
Message-ID: <20150601232608.GA18435@pox.localdomain>
References: <cover.1433167295.git.tgraf@suug.ch>
 <3b333ab393de268323c1eaa1d18169ec9c36f86b.1433167296.git.tgraf@suug.ch>
 <556C8D95.7030008@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, marcelo.leitner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org,
 daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
 kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
 tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Robert Shearman <rshearma-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <556C8D95.7030008-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org>
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

T24gMDYvMDEvMTUgYXQgMDU6NTFwbSwgUm9iZXJ0IFNoZWFybWFuIHdyb3RlOgo+IE9uIDAxLzA2
LzE1IDE1OjI3LCBUaG9tYXMgR3JhZiB3cm90ZToKPiA+SW50cm9kdWNlcyBhIG5ldyBOZXRsaW5r
IGF0dHJpYnV0ZSBSVEFfVFVOTkVMIHdoaWNoIGFsbG93cyByb3V0ZXMKPiA+dG8gc2V0IHR1bm5l
bCB0cmFuc21pdCBtZXRhZGF0YSBhbmQgc3BlY2lmeSB0aGUgdHVubmVsIGVuZHBvaW50IG9yCj4g
PnR1bm5lbCBpZCBvbiBhIHBlciByb3V0ZSBiYXNpcy4gVGhlIHJvdXRlIG11c3QgcG9pbnQgdG8g
YSB0dW5uZWwKPiA+ZGV2aWNlIHdoaWNoIHVuZGVyc3RhbmRzIHBlciBza2IgdHVubmVsIG1ldGFk
YXRhIGFuZCBoYXMgYmVlbiBwdXQKPiA+aW50byB0aGUgcmVzcGVjdGl2ZSBtb2RlLgo+IAo+IFdl
J3ZlIGJlZW4gZGlzY3Vzc2luZyBzb21ldGhpbmcgc2ltaWxhciBmb3IgdGhlIHB1cnBvc2VzIG9m
IElQIG92ZXIgTVBMUywKPiBidXQgbW9zdCBvZiB0aGUgYXR0cmlidXRlcyBmb3IgSVAgdHVubmVs
cyBhcmVuJ3QgcmVsZXZhbnQgZm9yIE1QTFMuIEl0IGJlCj4gZ3JlYXQgaWYgd2UgY2FuIGNvbWUg
dXAgd2l0aCBzb21ldGhpbmcgZ2VuZXJhbCBlbm91Z2ggdGhhdCBjYW4gc2VydmUgYm90aAo+IHB1
cnBvc2VzLiBJJ3ZlIGp1c3Qgc2VudCBhIHBhdGNoIHNlcmllcyAoIltSRkMgbmV0LW5leHQgMC8z
XSBJUCBpbXBvc2l0aW9uCj4gb2YgcGVyLW5oIE1QTFMgZW5jYXAiKSB3aGljaCBJIGJlbGlldmUg
d291bGQgYWxsb3cgdGhpcy4KCk5pY2UhIE9uIGEgZmlyc3QgZ2xhbmNlLCB5b3VyIHNlcmllcyBs
b29rcyBsaWtlIGFuIGV4Y2VsbGVudCBjb21wbGVtZW50CnRvIHRoaXMgc2VyaWVzLiBJJ2xsIGNv
bW1lbnQgZGlyZWN0bHkgaW4geW91ciBzZXJpZXMuCl9fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNoLm9y
ZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
