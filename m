From: Arkadiusz Miskiewicz <arekm@maven.pl>
Subject: Re: htb and UDP packages bigger than 1500
Date: Tue, 11 Dec 2007 09:17:30 +0100
Message-ID: <200712110917.30945.arekm@maven.pl>
References: <20071211081929.GA2261@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.carme.maven.pl ([193.239.45.138]:13550 "EHLO
	main.carme.maven.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751735AbXLKIRi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 03:17:38 -0500
In-Reply-To: <20071211081929.GA2261@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 11 of December 2007, Jarek Poplawski wrote:
> On 10-12-2007 18:10, Arkadiusz Miskiewicz wrote:
> > Hello,
> >
> > I noticed that HTB doesn't properly limit traffic if someone sends =
UDP
> > packages bigger than 1500.
> >
> > Does HTB have some problems/known limits in this area?
> >
> > There is other traffic in that class and when I drop udp packets bi=
gger
> > than 1500 then remaining traffic is limited properly to correct val=
ue.
>
> Should work with proper "mtu" parameter (tc qdisc add htb help) or,
> for kernels >=3D 2.6.23, even without this. If this doesn't help,
> probably more information is required.

2.6.22 there. mtu wasn't specified at tc... Could you point to a git co=
mmit=20
which "fixes" the issue in 2.6.23 so I could backport it to my 2.6.22?

> Regards,
> Jarek P.

Thanks,
--=20
Arkadiusz Mi=B6kiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
