From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] OpenBSD Networking-related randomization port
Date: Mon, 31 Jan 2005 21:11:41 +0100
Message-ID: <20050131201141.GA4879@elte.hu>
References: <1106932637.3778.92.camel@localhost.localdomain> <20050128100229.5c0e4ea1@dxpl.pdx.osdl.net> <1106937110.3864.5.camel@localhost.localdomain> <20050128105217.1dc5ef42@dxpl.pdx.osdl.net> <1106944492.3864.30.camel@localhost.localdomain> <1106945266.7776.41.camel@laptopd505.fenrus.org> <200501290915.j0T9FkVY012948@turing-police.cc.vt.edu> <20050131165025.GN18316@stusta.de> <1107192218.3754.86.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Adrian Bunk <bunk@stusta.de>, Valdis.Kletnieks@vt.edu,
	Arjan van de Ven <arjan@infradead.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Chris Wright <chrisw@osdl.org>, netdev@oss.sgi.com,
	Hank Leininger <hlein@progressive-comp.com>,
	"David S. Miller" <davem@redhat.com>, linux@horizon.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261353AbVAaUMk@vger.kernel.org>
To: Lorenzo =?iso-8859-1?Q?Hern=E1ndez_Garc=EDa-Hierro?=
	<lorenzo@gnu.org>
Content-Disposition: inline
In-Reply-To: <1107192218.3754.86.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Lorenzo Hern=E1ndez Garc=EDa-Hierro <lorenzo@gnu.org> wrote:

> > At least the three clause BSD license is GPL compatible.
>=20
> Yes, AFAIK :)
>=20
> I will try to follow Arjan's recommendations on using his functions
> instead of obsd ones, even if I think it should be alone in the
> current file. Also I will split up the patch.

could you please also react to this feedback:

  http://marc.theaimsgroup.com/?l=3Dlinux-kernel&m=3D110698371131630&w=3D=
2

to quote a couple of key points from that very detailed security
analysis:

" I'm not sure how the OpenBSD code is better in any way.  (Notice that
  it uses the same "half_md4_transform" as Linux; you just added anothe=
r
  copy.) Is there a design note on how the design was chosen? "

that mail also includes a much smaller patch to random.c.

( Obviously the more fundamental questions have to be solved prior
solving code-level problems, patch splitup and patch ordering - often
one ends up having a much smaller patch to work with, by thinking more
about the fundamentals. )

	Ingo
