From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Mon, 22 Sep 2008 13:13:39 -0300
Message-ID: <20080922131339.79abf28a@tux>
References: <20080819213417.45133573@tux>
	<20080826141812.589848a0@tux>
	<Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
	<20080828184919.611dd578@tux>
	<Pine.LNX.4.64.0808291045430.7971@wrl-59.cs.helsinki.fi>
	<20080830035650.42be37d7@tux>
	<Pine.LNX.4.64.0808301000180.12388@wrl-59.cs.helsinki.fi>
	<20080907051718.58bf133d@tux>
	<Pine.LNX.4.64.0809071341310.8991@wrl-59.cs.helsinki.fi>
	<20080908172043.0d25a427@tux>
	<Pine.LNX.4.64.0809100942370.24708@wrl-59.cs.helsinki.fi>
	<20080911143006.2f516569@tux>
	<Pine.LNX.4.64.0809112140250.26799@wrl-59.cs.helsinki.fi>
	<20080913203117.2a55ea2c@tux>
	<Pine.LNX.4.64.0809140722460.17271@wrl-59.cs.helsinki.fi>
	<20080916112411.062fa615@tux>
	<Pine.LNX.4.64.0809161726250.1034@wrl-59.cs.helsinki.fi>
	<20080918173554.1f874238@tux>
	<Pine.LNX.4.64.0809182349410.4742@wrl-59.cs.helsinki.fi>
	<20080922012338.694d30b0@tux>
	<Pine.LNX.4.64.0809221112140.1950@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0809221112140.1950@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 22 Sep 2008 14:22:12 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> It seems that next sensible step is to just obtain a full strace to s=
ee=20
> what actually took place during those long minutes if anything (it's=20
> better that you keep that log private and just use grep over it on=20
> request). ...A full strace might grow huge though. Also, for strace u=
se=20
> -tt instead of -t to get more accurate timestamps and add -T.
>=20
> When you get the stall next time, please also check that the processe=
s are=20
> actually sleeping instead of looping like crazy in some buggy userspa=
ce=20
> code :-) (obviously before resolving it with nmap).
>=20
> When using nmap to resolve, take note on exact timestamp (including=20
> seconds). E.g.,=20
> $ date > nmap.ts; nmap ...

	Thanks! Today I'm lucky. I got the stall fast. It seems that it
happens more frequently as more connections are made.

	What should I grep?

--=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
