From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: r8169 - disable flow-control?
Date: Thu, 05 Mar 2009 21:08:48 +0000
Message-ID: <1236287329.3202.7.camel@achroite>
References: <1236281743.10409.17.camel@alkisg>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?=CE=86=CE=BB=CE=BA=CE=B7=CF=82_?=
	 =?UTF-8?Q?=CE=93=CE=B5=CF=89=CF=81=CE=B3=CF=8C=CF=80=CE=BF=CF=85=CE=BB?=
	 =?UTF-8?Q?=CE=BF=CF=82?= <alkisg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:38090 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751101AbZCEVIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 16:08:53 -0500
In-Reply-To: <1236281743.10409.17.camel@alkisg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-03-05 at 21:35 +0200, =CE=86=CE=BB=CE=BA=CE=B7=CF=82 =CE=93=
=CE=B5=CF=89=CF=81=CE=B3=CF=8C=CF=80=CE=BF=CF=85=CE=BB=CE=BF=CF=82 wrot=
e:
> Hello,
>=20
> Is there any way to disable flow control for NICs using the r8169
> driver?
>=20
> It would be really valuable in the following (sadly very common)
> scenario:
>  * r8169 gigabit NIC on the server
>  * unmanaged gigabit switch that supports flow control negotiation
>  * 100Mbps clients
>=20
> E.g. in LTSP labs, the server can send data at ~900Mbps with flow
> control off, but with flow control on the bandwidth drops to ~90Mbps.
> Detailed explanation of the problem:
> http://virtualthreads.blogspot.com/2006/02/beware-ethernet-flow-contr=
ol.html
>=20
> If the current code doesn't support it, would it be possible to add a
> module parameter for this?

Generally you should be able to control this using ethtool, not a modul=
e
parameter.  However r8169 does not implement this operation yet.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

