From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2927 tcp_ack+0xd55/0x1991()
Date: Wed, 1 Apr 2009 13:35:20 +0200
Message-ID: <20090401113520.GA2667@gentoox2.trippelsdorf.de>
References: <20090328045056.GA2394@gentoox2.trippelsdorf.de> <Pine.LNX.4.64.0903280930440.6696@wrl-59.cs.helsinki.fi> <20090328095514.GA2599@gentoox2.trippelsdorf.de> <Pine.LNX.4.64.0903301155150.30150@wrl-59.cs.helsinki.fi> <20090330164035.GA2652@gentoox2.trippelsdorf.de> <Pine.LNX.4.64.0903302137100.29272@wrl-59.cs.helsinki.fi> <20090331071018.GA2641@gentoox2.trippelsdorf.de> <Pine.LNX.4.64.0903311205070.30150@wrl-59.cs.helsinki.fi> <20090331184959.GA2725@gentoox2.trippelsdorf.de> <Pine.LNX.4.64.0904011352470.30150@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out-43.synserver.de ([217.119.50.43]:1247 "HELO
	smtp-out-43.synserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1759263AbZDALfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 07:35:32 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0904011352470.30150@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 01, 2009 at 02:09:11PM +0300, Ilpo J=E4rvinen wrote:
> On Tue, 31 Mar 2009, Markus Trippelsdorf wrote:
>=20
> > On Tue, Mar 31, 2009 at 12:16:51PM +0300, Ilpo J=E4rvinen wrote:
> > > On Tue, 31 Mar 2009, Markus Trippelsdorf wrote:
> > >=20
> > > > On Mon, Mar 30, 2009 at 09:52:55PM +0300, Ilpo J=E4rvinen wrote=
:
> > > > > On Mon, 30 Mar 2009, Markus Trippelsdorf wrote:
> > > > >=20
> > > > > > On Mon, Mar 30, 2009 at 07:01:22PM +0300, Ilpo J=E4rvinen w=
rote:
> > > > > > > On Sat, 28 Mar 2009, Markus Trippelsdorf wrote:
> > > > > > > > On Sat, Mar 28, 2009 at 10:29:58AM +0200, Ilpo J=E4rvin=
en wrote:
> > > > > > >=20
> > > > > > > ...And, let me guess, you're in X and therefore unable to=
 catch a final=20
> > > > > > > oops if any would be printed? It would be nice to get aro=
und that as well,=20
> > > > > > > either use serial/netconsole or hang in text mode while w=
aiting for the=20
> > > > > > > crash (should be too hard if you are able to setup the wo=
rkload first=20
> > > > > > > and then switch away from X and if reproducing takes abou=
t an hour)...
> > > > > >=20
> > > > > > OK, I will try this later.
> > > > >=20
> > > > > Lets hope that gives some clue where it ends up going boom (i=
f it is=20
> > > > > caused by TCP we certainly should see something more sensible=
 in console=20
> > > > > than just a hang)... ...I once again read through tcp commits=
 but just=20
> > > > > cannot find anything that could cause fackets_out miscount, n=
ot to speak=20
> > > > > of crash prone changes so we'll just have to wait and see...
> > > >=20
> > > > The machine hanged again this night and I took two pictures:
> > > > http://www.mypicx.com/uploadimg/1055813374_03302009_2.jpg
> > > > http://www.mypicx.com/uploadimg/1543678904_03302009_1.jpg
> > > >
> > > > But this time there was no tcp related warning in the logs.
> > >=20
> > > Right. If that oops would be hit often enough one can easily mix =
the=20
> > > warning with that hang though there is no relation (the fact that=
 final=20
> > > oops always goes unnoticed in X amplifies the effect).
> > >=20
> > > > I then pulled the lateset git changes, rebuild, rebooted and se=
tup the
> > > > workload again. The machine was still up and running in the mor=
ning=20
> > > > (~4 hours uptime). So it may well be that the issue was fixed w=
ith
> > > > the latest changes.
> > >=20
> > > Lets hope so, in any case if you still see hangs please get the f=
inal oops.
> > >=20
> > > > If it ever occurs again I will notify you.
> >=20
> > It happend again. In this case it took ~10 minutes from the warning=
 to
> > the final crash. I'm pretty sure there must be some kind of relatio=
n
> > between the two. How else could one explain that the machine crashe=
s just
> > minutes after _each_ instance of that WARNING?
>=20
> Here's my try #1... It should silence the warning (we would have seen=
=20
> a later warning in the console btw and finally an oops due to NULL=20
> dereference would you have been able to capture it) and hopefully doe=
sn't=20
> introduce any other problem of any kind. So far I did only compile=20
> test it.

Many thanks for the quick fix. I will try it here ASAP.=20

(Hopefully modesetting support for Radeon cards will be ready shortly,
so that I could capture oopses more easily...)
--=20
Markus
