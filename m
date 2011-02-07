From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 28542] New: 3c59x.c: Regression since 2.6.36
 (incl.), for e. g., TCP stalls on receive
Date: Mon, 7 Feb 2011 15:09:19 -0800
Message-ID: <20110207150919.cd253b97.akpm@linux-foundation.org>
References: <bug-28542-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Jan Beulich <jbeulich@novell.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Neil Horman <nhorman@tuxdriver.com>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	for.poige+bugzilla.kernel.org@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33570 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755177Ab1BGXKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 18:10:23 -0500
In-Reply-To: <bug-28542-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Feb 2011 18:55:29 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=3D28542
>=20
>            Summary: 3c59x.c: Regression since 2.6.36 (incl.), for e. =
g.,
>                     TCP stalls on receive
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.36=E2=80=942.6.37
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: for.poige+bugzilla.kernel.org@gmail.com
>         Regression: Yes
>=20
>=20
> Dump of kernel source bz2 download being stalled:
> http://poige.livejournal.com/475372.html#cutid1 (see the bunch of ACK=
s
> #5555523).
>=20
> As a workaround I've just replaced drivers/net/3c59x.c with its forme=
r
> (2.6.35.11) version, the connectivity problems are gone now.
>=20

