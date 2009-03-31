From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2927 tcp_ack+0xd55/0x1991()
Date: Tue, 31 Mar 2009 09:10:18 +0200
Message-ID: <20090331071018.GA2641@gentoox2.trippelsdorf.de>
References: <20090327211202.GA10014@gentoox2.trippelsdorf.de> <Pine.LNX.4.64.0903280031080.5904@wrl-59.cs.helsinki.fi> <20090328045056.GA2394@gentoox2.trippelsdorf.de> <Pine.LNX.4.64.0903280930440.6696@wrl-59.cs.helsinki.fi> <20090328095514.GA2599@gentoox2.trippelsdorf.de> <Pine.LNX.4.64.0903301155150.30150@wrl-59.cs.helsinki.fi> <20090330164035.GA2652@gentoox2.trippelsdorf.de> <Pine.LNX.4.64.0903302137100.29272@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, corbet@lwn.net
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762284AbZCaGKz@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0903302137100.29272@wrl-59.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 30, 2009 at 09:52:55PM +0300, Ilpo J=E4rvinen wrote:
> On Mon, 30 Mar 2009, Markus Trippelsdorf wrote:
>=20
> > On Mon, Mar 30, 2009 at 07:01:22PM +0300, Ilpo J=E4rvinen wrote:
> > > On Sat, 28 Mar 2009, Markus Trippelsdorf wrote:
> > > > On Sat, Mar 28, 2009 at 10:29:58AM +0200, Ilpo J=E4rvinen wrote=
:
> > >=20
> > > ...And, let me guess, you're in X and therefore unable to catch a=
 final=20
> > > oops if any would be printed? It would be nice to get around that=
 as well,=20
> > > either use serial/netconsole or hang in text mode while waiting f=
or the=20
> > > crash (should be too hard if you are able to setup the workload f=
irst=20
> > > and then switch away from X and if reproducing takes about an hou=
r)...
> >=20
> > OK, I will try this later.
>=20
> Lets hope that gives some clue where it ends up going boom (if it is=20
> caused by TCP we certainly should see something more sensible in cons=
ole=20
> than just a hang)... ...I once again read through tcp commits but jus=
t=20
> cannot find anything that could cause fackets_out miscount, not to sp=
eak=20
> of crash prone changes so we'll just have to wait and see...

The machine hanged again this night and I took two pictures:
http://www.mypicx.com/uploadimg/1055813374_03302009_2.jpg
http://www.mypicx.com/uploadimg/1543678904_03302009_1.jpg

But this time there was no tcp related warning in the logs.

I then pulled the lateset git changes, rebuild, rebooted and setup the
workload again. The machine was still up and running in the morning=20
(~4 hours uptime). So it may well be that the issue was fixed with
the latest changes. If it ever occurs again I will notify you.

Thanks for your assistance so far,

--=20
Markus
