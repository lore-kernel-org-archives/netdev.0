From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 10/10] ieee802154: add at86rf230/rf231 spi driver
Date: Tue, 2 Jun 2009 00:33:48 +0400
Message-ID: <20090601203348.GC7143@doriath.ww600.siemens.net>
References: <1243868091-5315-3-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-4-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-5-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-6-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-7-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-8-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-9-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-10-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-11-git-send-email-dbaryshkov@gmail.com> <69e28c910906010921r56cf7017gc858cb7ba819c385@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org,
	maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org
To: =?iso-8859-1?Q?G=E1bor?= Stefanik <netrolller.3d-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <69e28c910906010921r56cf7017gc858cb7ba819c385-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 01, 2009 at 06:21:37PM +0200, G=E1bor Stefanik wrote:
> On Mon, Jun 1, 2009 at 4:54 PM, Dmitry Eremin-Solenikov
> <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > Add a driver handling AT86RF230/RF231 line of chips. Only basic
> > features are currently implemented (no extended mode operation, etc=
=2E)
> > Also the RF230 chip is not really supported yet.
> >
> > Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Signed-off-by: Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
> > ---
> > =A0drivers/ieee802154/Kconfig =A0 =A0 | =A0 =A05 +
> > =A0drivers/ieee802154/Makefile =A0 =A0| =A0 =A01 +
> > =A0drivers/ieee802154/at86rf230.c | =A0971 ++++++++++++++++++++++++=
++++++++++++++++
>=20
> Shouldn't this go into drivers/net/ieee802154 instead?

I thought about drivers/net as about ip (well, more or less) network
drivers. We have drivers/atm or drivers/bluetooth (and bluetooth is
802.15.1...). So we've used just drivers/ieee802154. If you say so,
we will move to drivers/net.

--=20
With best wishes
Dmitry

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
