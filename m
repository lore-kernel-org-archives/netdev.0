From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [Cocci] [PATCH v2] coccinelle: api: check for propagation of
 error from platform_get_irq
Date: Sun, 27 Dec 2015 12:41:30 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1512271239460.2038@localhost6.localdomain6>
References: <1451157891-24881-1-git-send-email-Julia.Lawall@lip6.fr>
 <567EF188.7020203@cogentembedded.com>
 <alpine.DEB.2.02.1512262107340.2070@localhost6.localdomain6>
 <alpine.DEB.2.02.1512262123500.2070@localhost6.localdomain6>
 <567EF895.6080702@cogentembedded.com>
 <alpine.DEB.2.02.1512262156580.2070@localhost6.localdomain6>
 <567F9A29.50202@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-506290417-1451216492=:2038"
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
 Gilles Muller <Gilles.Muller@lip6.fr>, netdev@vger.kernel.org,
 Nicolas Palix <nicolas.palix@imag.fr>, kernel-janitors@vger.kernel.org,
 LKML <linux-kernel@vger.kernel.org>, dri-devel@lists.freedesktop.org,
 linux-spi@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>,
 Michal Marek <mmarek@suse.com>, linux-i2c@vger.kernel.org,
 Coccinelle <cocci@systeme.lip6.fr>, linux-media@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <567F9A29.50202@users.sourceforge.net>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: dri-devel-bounces@lists.freedesktop.org
Sender: "dri-devel" <dri-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-506290417-1451216492=:2038
Content-Type: TEXT/PLAIN; charset=windows-1252
Content-Transfer-Encoding: quoted-printable



On Sun, 27 Dec 2015, SF Markus Elfring wrote:

> > The error return value of platform_get_irq seems to often get dropped=
.
>=20
> How do you think about any more fine-tuning here?
>=20
> Commit message:
> * =85 of the platform_get_irq() function seems to get dropped too often=
.
>=20
> * Why do you concentrate on a single function name?
>   Do you plan to extend this source code analysis approach?
>=20
>=20
> > +@script:python r_report depends on report@
> > +j0 << r.j0;
> > +j1 << r.j1;
> > +@@
> > +
> > +msg =3D "Propagate return value of platform_get_irq around line %s."=
 % (j1[0].line)
>=20
> Are there more unchecked return values which are interesting
> for further considerations?
> https://cwe.mitre.org/data/definitions/252.html

The value is not unchecked.  I made a specific rule because the specific=20
problem is quite common.

julia
--8323328-506290417-1451216492=:2038
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KZHJpLWRldmVs
IG1haWxpbmcgbGlzdApkcmktZGV2ZWxAbGlzdHMuZnJlZWRlc2t0b3Aub3JnCmh0dHA6Ly9saXN0
cy5mcmVlZGVza3RvcC5vcmcvbWFpbG1hbi9saXN0aW5mby9kcmktZGV2ZWwK

--8323328-506290417-1451216492=:2038--
