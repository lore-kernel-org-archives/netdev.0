From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] OpenBSD Networking-related randomization port
Date: Fri, 28 Jan 2005 13:34:08 -0800
Message-ID: <20050128133408.49021343@dxpl.pdx.osdl.net>
References: <1106932637.3778.92.camel@localhost.localdomain>
	<20050128100229.5c0e4ea1@dxpl.pdx.osdl.net>
	<1106937110.3864.5.camel@localhost.localdomain>
	<20050128105217.1dc5ef42@dxpl.pdx.osdl.net>
	<1106944492.3864.30.camel@localhost.localdomain>
	<20050128124517.36aa5e05.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lorenzo =?ISO-8859-1?B?SGVybuFuZGV6IEdhcmPtYS1IaWVycm8=?=
	<lorenzo@gnu.org>, linux-kernel@vger.kernel.org, chrisw@osdl.org,
	netdev@oss.sgi.com, arjan@infradead.org, hlein@progressive-comp.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262747AbVA1VeG@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050128124517.36aa5e05.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Jan 2005 12:45:17 -0800
"David S. Miller" <davem@davemloft.net> wrote:

> On Fri, 28 Jan 2005 21:34:52 +0100
> Lorenzo Hern=E1ndez Garc=EDa-Hierro <lorenzo@gnu.org> wrote:
>=20
> > Attached the new patch following Arjan's recommendations.
>=20
> No SMP protection on the SBOX, better look into that.
> The locking you'll likely need to add will make this
> routine serialize many networking operations which is
> one thing we've been trying to avoid.
>=20

per-cpu would be the way to go here.

--=20
Stephen Hemminger	<shemminger@osdl.org>
