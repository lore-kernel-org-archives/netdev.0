From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] OpenBSD Networking-related randomization port
Date: Sat, 29 Jan 2005 09:05:44 +0100
Message-ID: <1106985945.4174.60.camel@laptopd505.fenrus.org>
References: <1106932637.3778.92.camel@localhost.localdomain>
	 <20050128100229.5c0e4ea1@dxpl.pdx.osdl.net>
	 <1106937110.3864.5.camel@localhost.localdomain>
	 <20050128105217.1dc5ef42@dxpl.pdx.osdl.net>
	 <1106944492.3864.30.camel@localhost.localdomain>
	 <1106945266.7776.41.camel@laptopd505.fenrus.org>
	 <1106950369.3864.45.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Chris Wright <chrisw@osdl.org>, netdev@oss.sgi.com,
        Hank Leininger <hlein@progressive-comp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Lorenzo =?ISO-8859-1?Q?Hern=E1ndez_?= =?ISO-8859-1?Q?Garc=EDa-Hierro?= <lorenzo@gnu.org>
In-Reply-To: <1106950369.3864.45.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-01-28 at 23:12 +0100, Lorenzo Hern=C3=A1ndez Garc=C3=ADa-Hie=
rro
wrote:
> El vie, 28-01-2005 a las 21:47 +0100, Arjan van de Ven escribi=C3=B3:
> > as for obsd_get_random_long().. would it be possible to use the
> > get_random_int() function from the patches I posted the other day? Th=
ey
> > use the existing random.c infrastructure instead of making a copy...
>=20
> As seen at
>  the functions at obsd_rand.c so we wouldn't need to add more maintenan=
ce overhead, I hope you can understand why I want it like that

I actually DON'T understand that.=20
What you say kinda sorta makes sense if you're an external patch. But if
you are inside the kernel (that was the goal of this patch, right?) then
the argument is actually entirely the wrong way around...
