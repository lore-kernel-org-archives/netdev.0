From: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH 000/102] Convert drivers to explicit reset API
Date: Thu, 20 Jul 2017 22:32:49 +0200
Message-ID: <1687646.TMvigZNUOP__23329.3554898866$1500745025$gmane$org@phil>
References: <20170719152646.25903-1-p.zabel@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, Prashant Gaikwad <pgaikwad-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
 Peter Chen <Peter.Chen-3arQi8VN3Tc@public.gmane.org>, Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, Marc Dietrich <marvin24-Mmb7MZpHnFY@public.gmane.org>,
 Rakesh Iyer <riyer-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, Peter Meerwald-Stadler <pmeerw-jW+XmwGofnusTnJN9+BGXg@public.gmane.org>,
 linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Wim Van Sebroeck <wim-IQzOog9fTRqzQB+pC5nmwQ@public.gmane.org>,
 Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>, Xinliang Liu <z.liuxinliang-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
 Chanwoo Choi <cw00.choi-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
 Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>, Michael Turquette <mturquette-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
 Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>, Ohad Ben-Cohen <ohad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
 linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
 Vincent Abriou <vincent.abriou-qxv4g6HH51o@public.gmane.org>, Bin Liu <b-liu-l0cyMroinI0@public.gmane.org>,
 Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
To: Philipp Zabel <p.zabel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <nouveau-bounces-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>
In-Reply-To: <20170719152646.25903-1-p.zabel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.freedesktop.org/mailman/options/nouveau>,
 <mailto:nouveau-request-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.freedesktop.org/archives/nouveau>
List-Post: <mailto:nouveau-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>
List-Help: <mailto:nouveau-request-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org?subject=help>
List-Subscribe: <https://lists.freedesktop.org/mailman/listinfo/nouveau>,
 <mailto:nouveau-request-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org?subject=subscribe>
Errors-To: nouveau-bounces-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org
Sender: "Nouveau" <nouveau-bounces-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>
List-Id: netdev.vger.kernel.org

SGksCgo+ICAgY3J5cHRvOiByb2NrY2hpcDogZXhwbGljaXRseSByZXF1ZXN0IGV4Y2x1c2l2ZSBy
ZXNldCBjb250cm9sCj4gICBpaW86IGFkYzogcm9ja2NoaXBfc2FyYWRjOiBleHBsaWNpdGx5IHJl
cXVlc3QgZXhjbHVzaXZlIHJlc2V0IGNvbnRyb2wKPiAgIFBDSTogcm9ja2NoaXA6IGV4cGxpY2l0
bHkgcmVxdWVzdCBleGNsdXNpdmUgcmVzZXQgY29udHJvbAo+ICAgcGh5OiByb2NrY2hpcC1wY2ll
OiBleHBsaWNpdGx5IHJlcXVlc3QgZXhjbHVzaXZlIHJlc2V0IGNvbnRyb2wKPiAgIHBoeTogcm9j
a2NoaXAtdHlwZWM6IGV4cGxpY2l0bHkgcmVxdWVzdCBleGNsdXNpdmUgcmVzZXQgY29udHJvbAo+
ICAgcGh5OiByb2NrY2hpcC11c2I6IGV4cGxpY2l0bHkgcmVxdWVzdCBleGNsdXNpdmUgcmVzZXQg
Y29udHJvbAo+ICAgdGhlcm1hbDogcm9ja2NoaXA6IGV4cGxpY2l0bHkgcmVxdWVzdCBleGNsdXNp
dmUgcmVzZXQgY29udHJvbAoKZm9yIHRoZSBkcml2ZXItcmVsYXRlZCBSb2NrY2hpcCBjaGFuZ2Vz
CgpBY2tlZC1ieTogSGVpa28gU3R1ZWJuZXIgPGhlaWtvQHNudGVjaC5kZT4KX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTm91dmVhdSBtYWlsaW5nIGxpc3QK
Tm91dmVhdUBsaXN0cy5mcmVlZGVza3RvcC5vcmcKaHR0cHM6Ly9saXN0cy5mcmVlZGVza3RvcC5v
cmcvbWFpbG1hbi9saXN0aW5mby9ub3V2ZWF1Cg==
