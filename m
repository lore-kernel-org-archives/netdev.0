From: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v5] net/usb: add sierra_net.c driver
Date: Tue, 27 Apr 2010 18:19:07 -0700
Message-ID: <1272417547.6202.0.camel@Linuxdev4-laptop>
References: <1272415711.10975.3.camel@Linuxdev4-laptop>
	 <20100427.180732.121248582.davem@davemloft.net>
	 <20100427.181149.179278301.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org" <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Rory Filer <rfiler-usJ8hg9QsBLWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100427.181149.179278301.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-04-27 at 18:11 -0700, David Miller wrote:
> From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Date: Tue, 27 Apr 2010 18:07:32 -0700 (PDT)
>=20
> > From: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
> > Date: Tue, 27 Apr 2010 17:48:31 -0700
> >=20
> >> Subject: [PATCH v5] net/usb: add sierra_net.c driver
> >=20
> > Applied, although I had to manually remove the stray extra
> > newline at the end of drivers/net/usb/sierra_net.c which GIT
> > complains about when the patch is applied.
>=20
> I also had to fix up the following warning during the build:
>=20
> drivers/net/usb/sierra_net.c: In function =E2=80=98sierra_net_parse_l=
si=E2=80=99:
> drivers/net/usb/sierra_net.c:365: warning: format =E2=80=98%u=E2=80=99=
 expects type =E2=80=98unsigned int=E2=80=99, but argument 7 has type =E2=
=80=98long unsigned int=E2=80=99
>=20
> "size_t" objects must use the "z" format specifier, so "%zu" is what
> should have been used here.
Sorry, my mistake.
Thank you very much, David.
Elina

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
