From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Mon, 15 Sep 2008 16:42:46 -0300
Message-ID: <20080915164246.6ea1698d@tux>
References: <20080819213417.45133573@tux>
	<Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
	<20080822183224.2d52f16c@tux>
	<20080822.143709.65615512.davem@davemloft.net>
	<20080823111446.06a350a2@tux>
	<Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
	<20080824163843.33b4f890@tux>
	<Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0809112140250.26799@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Sep 2008 13:16:19 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> Ok.

Sep 15 09:22:38 teleporto vmunix: 600 RC00 T=3D4 D337POOIM YE3CD=3D3[R=3D=
93.812DT1210624LN4 O=3Dx0PE=3Dx0TL5 D0D RT=3DC NOPEE[ ye]]
Sep 15 09:53:49 teleporto vmunix: 6DO IPT:I=3Dt0OT A=3Dff:ff:ff:05:36:b=
50:0SC13192522DT25252525LN4 O=3Dx0PE=3Dx0TL12I=3D
=46POOTPST51 P=3D31 IDW650RS00 C Y RP0

	This strange kernel messages are normal or is this clearly something b=
uggy? This is logged whenever the connection=20
is stalled.

	Anyway, I'm 50% almost sure that it's something related to ntpd adjust=
ing time. I do not mean that whenever ntpd syncs=20
the time, the connection is stalled but I need a few more weeks to assu=
re this.

	Basically without ntpd, everything is fine, but when ntpd is running, =
the stall happens. Maybe the kernel gets confused when=20
ntpd changes the time? It shouldn't happen of course. I'll reply in a f=
ew weeks. Thanks.


--=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
