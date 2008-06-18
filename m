From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 10903] New: ssh connections hang with 2.6.26-rc5
Date: Wed, 18 Jun 2008 13:39:13 +0200
Message-ID: <200806181339.13898.mb@bu3sch.de>
References: <bug-10903-10286@http.bugzilla.kernel.org/> <1213773887.3803.158.camel@johannes.berg> <200806181334.10654.didier@raboud.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Ilpo =?utf-8?q?J=C3=A4rvinen?= <ilpo.jarvinen-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Didier Raboud <didier-efQUOpnRmEvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200806181334.10654.didier-efQUOpnRmEvQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 18 June 2008 13:34:06 Didier Raboud wrote:
> Le mercredi 18 juin 2008 09:24:47 Johannes Berg, vous avez =C3=A9crit=
=C2=A0:
> > > > > > > > > http://bugzilla.kernel.org/show_bug.cgi?id=3D10903
> > > > > > > > >
> > > > > > > > >            Summary: ssh connections hang with 2.6.26-=
rc5
> >
> > Andrew Prince reported a similar problem and said he bisected it  t=
o
> > davem's =EF=BB=BF608961a5eca8d3c6bd07172febc27b5559408c5d ("mac8021=
1: Use
> > skb_header_cloned() on TX path.") which made no sense to me so I ma=
rked
> > the report as 'to investigate when I have more time'.
> >
> > > > and I got the attached "soft lockup".
> >
> > Attached where? I can't find it in the bug either.
> >
> > johannes
>=20
> Hi,=20
>=20
> for unknown reasons, my mail doesn't appear in the mailing list archi=
ves and=20
> the big attachment has visibly been stripped.
>=20
> You'll find the "soft lockup" there:
>=20
> http://raboud.homelinux.org/~didier/kernel/tcpdump_oops.jpg

The soft lockup most likely is a followup-oops to a previous one that
locked up the machine.
Can you try to reproduce and capture the screen before waiting 61 secon=
ds
for the watchdog to trigger. There should be another oops before that (=
you see
the last two lines of it on this picture)

--=20
Greetings Michael.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
