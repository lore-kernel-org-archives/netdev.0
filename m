From: Fabio Coatti <fabio.coatti@gmail.com>
Subject: Re: 3.7.10 kernel crash
Date: Tue, 02 Apr 2013 11:16:55 +0200
Message-ID: <1426784.IFBeqasnTm@calvin>
References: <CADpTngWo_c0MHNwYEFwSR_9KQrWKrOVgQSze+rZc4Ze9Rj2hsw@mail.gmail.com> <CADpTngW8RTVX28bVJQe5tV_ccc+FNOJezeQbczXFudy+7bMRDQ@mail.gmail.com> <1364474147.3261.1.camel@thor.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Peter Hurley <peter@hurleysoftware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364474147.3261.1.camel@thor.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In data gioved=EC 28 marzo 2013 08:35:47, Peter Hurley ha scritto:
> [ +cc Matt Carlson, Michael Chan, netdev because this is a tg3-relate=
d oops]
> On Thu, 2013-03-28 at 09:31 +0100, Fabio Coatti wrote:
> > 2013/3/27 Fabio Coatti <fabio.coatti@gmail.com>:
> > > Hi all,
> > > we are experiencing crashes on some servers, right now running 3.=
7.10;
> > > I've been able to get only screenshots from dying server that I
> > > attached below. Probably we can exclude hardware issues, as it
> > > happened on two different servers.
> >=20
> > Further information: those crashes seems to happen only when the
> > machine is heavily loaded (process, network and so on). We have see=
n
> > this pattern several times.
>=20
> I would recommend capturing the entire oops text (it will likely be
> necessary anyway for someone to properly identify and fix the cause).
>=20
> If the machine has a 2nd network port, then use netconsole on that
> interface. If not, set up a serial console or try to get 50-line VGA


Ok, I'll try to get better oopes. However, this is going to be tricky, =
as the=20
machine is remotely administered (via HP iLO) and uses all network inte=
rfaces=20
(BTW, I'm not even sure to be able to get a network driver related cras=
h using=20
netconsole approach). So far, no success in using a different resolutio=
n for=20
boot console.
Anyway, I'll try to find a way to capture all the messages.

Many thanks for the answer!



--
=46abio
