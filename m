From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] sch_red: fix red_change
Date: Wed, 7 Dec 2011 23:57:48 +0100
Message-ID: <20111207225747.GA4758@nuttenaction>
References: <1322684749.2602.3.camel@edumazet-laptop>
 <20111130143642.7130aa2b@nehalam.linuxnetplumber.net>
 <1322773594.2750.28.camel@edumazet-laptop>
 <CAA93jw7wAL75pVrB-q+xGAcpQtiZz4iVW0Z2W9E8VGSyUFOo-w@mail.gmail.com>
 <1322776643.2750.45.camel@edumazet-laptop>
 <alpine.DEB.2.00.1112051221510.31705@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Dave Taht <dave.taht@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Thomas Graf <tgraf@infradead.org>,
	netdev <netdev@vger.kernel.org>, Jim Gettys <jg@freedesktop.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:44454 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755730Ab1LGW5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 17:57:50 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1112051221510.31705@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Ilpo J=E4rvinen | 2011-12-05 13:42:44 [+0200]:

>I disagree. If there's any slow starting flow that alone can fill the=20
>bottleneck, anything significantly larger than RTT just harms. RED is=20
>just "too slow" if you follow the recommended parametrization..
>
>In a core router you can probably get away with multiple RTTs, but nea=
r=20
>edge that is a grave mistake due to how slow-start behaves. With avera=
ge=20
>based on many RTTs, RED still estimates that the link has low load whi=
le=20
>congestion has escalated to higher dimensions due to slow start. As a=20
>result, RED graciously falls back to tail-drop once the physical queue=
=20
>runs out and the flows respond allowing the load to decrease. However,=
=20
>finally RED reaches a state where it starts to "pro-actively" react to=
 an=20
>"incipient congestion"?!? :-/ =3D> Problem is made worse by those extr=
a=20
>drops/marks happening too late.

But then one question Ilpo: drive IW10 or IW14 the behavior even worse?
Especially if n connections start almost simultanously? You did some an=
alysis
on this topic.


HGN
