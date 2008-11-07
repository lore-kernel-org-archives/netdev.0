From: Dave Hudson <linux-kernel@blueteddy.net>
Subject: Re: time for TCP ECN defaulting to on?
Date: Fri, 07 Nov 2008 11:18:39 +0000
Message-ID: <4914240F.7050701@blueteddy.net>
References: <6278d2220811040632u7a36d68ekad5de517fd0671bb@mail.gmail.com> <alpine.DEB.1.10.0811052316210.10993@uplift.swm.pp.se> <20081105.151015.206163697.davem@davemloft.net> <alpine.DEB.1.10.0811070529550.10993@uplift.swm.pp.se> <Pine.LNX.4.64.0811070931190.23284@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mikael Abrahamsson <swmike@swm.pp.se>,
	David Miller <davem@davemloft.net>, daniel.blueman@gmail.com,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, linux-net@vger.kernel.org
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0811070931190.23284@wrl-59.cs.helsinki.fi>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ilpo J=E4rvinen wrote:
> On Fri, 7 Nov 2008, Mikael Abrahamsson wrote:
>=20
> And about somebody earlier claiming that they'll get an impressions t=
hat=20
> Linux stack is broken (if such people even know that there's some net=
work=20
> stack in Linux :-))... I'm rather sure those isp supports etc. put a =
blaim=20
> on us anyway even when loads of counterproof would exists because it'=
s=20
> just cheaper to do nothing and blaim linux instead. Also some claims=20
> asserted by incompetent people easily start to live among random foru=
ms;=20
> an example from the previous incident: "since disabling timestamps he=
lps,=20
> it must be that timestamps are broken" (and somebody even "more cluef=
ul"=20
> added that they got enabled for 2.6.27?!?), needless to say, neither=20
> holds.

Not all of the routers in question (the ones that crash, block packets=20
or otherwise misbehave) are provided by ISPs - in fact a huge number of=
=20
them are and have been sold retail.  Over time most of those boxes will=
=20
get replaced with ones that don't have the problem because most=20
(probably all major) SOHO router suppliers now test that they don't=20
break with ECN so eventually there will be a point where enabling ECN b=
y=20
default will make a lot of sense (there will be too few broken routers=20
to care about).

What I do believe (having spent a lot of years writing embedded device=20
and router code - and no, not the ones that crash ;-)) is that if you=20
enable a feature that causes just 1% of users to have an out-of-the-box=
=20
problem you'll see a seriously disproportionate response from end users=
=2E=20
  Most people (and engineers are not "most people" :-)) will blame the=20
new thing that they've just added or changed, not the old thing that wa=
s=20
broken to begin with (it's human nature not to truly understand cause=20
and effect).

Whether we like it or not there's currently a known problem deploying=20
ECN on a wide scale - it has been sufficient to stop pretty-much=20
everyone from enabling it by default so far.


Regards,
Dave


