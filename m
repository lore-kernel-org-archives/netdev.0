From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] OpenBSD Networking-related randomization port
Date: Sat, 29 Jan 2005 09:04:42 +0100
Message-ID: <1106985882.4174.58.camel@laptopd505.fenrus.org>
References: <1106932637.3778.92.camel@localhost.localdomain>
	 <20050128100229.5c0e4ea1@dxpl.pdx.osdl.net>
	 <1106937110.3864.5.camel@localhost.localdomain>
	 <20050128105217.1dc5ef42@dxpl.pdx.osdl.net>
	 <1106944492.3864.30.camel@localhost.localdomain>
	 <1106945266.7776.41.camel@laptopd505.fenrus.org>
	 <1106950369.3864.45.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@osdl.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Chris Wright <chrisw@osdl.org>, netdev@oss.sgi.com,
	Hank Leininger <hlein@progressive-comp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262874AbVA2IEx@vger.kernel.org>
To: Lorenzo =?ISO-8859-1?Q?Hern=E1ndez_?=
	 =?ISO-8859-1?Q?Garc=EDa-Hierro?= <lorenzo@gnu.org>
In-Reply-To: <1106950369.3864.45.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2005-01-28 at 23:12 +0100, Lorenzo Hern=C3=A1ndez Garc=C3=ADa-H=
ierro
wrote:
> El vie, 28-01-2005 a las 21:47 +0100, Arjan van de Ven escribi=C3=B3:
> > as for obsd_get_random_long().. would it be possible to use the
> > get_random_int() function from the patches I posted the other day? =
They
> > use the existing random.c infrastructure instead of making a copy..=
=2E
>=20
> As seen at
> http://www.kernel.org/pub/linux/kernel/people/arjan/execshield/00-ran=
domize-A0 you can suppose that there's=20


I actually meant
http://www.kernel.org/pub/linux/kernel/people/arjan/randomize/02-
randomize-infrastructure
which I posted for inclusion in the main kernel 2 or 3 days ago.
That's nice and stand alone to get a random value; we should be able to
share that.
