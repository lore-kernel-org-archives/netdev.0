From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: ax25 rose Re: kernel panic linux-2.6.27-rc7
Date: Sun, 5 Oct 2008 22:33:45 +0200
Message-ID: <20081005203345.GA2526@ami.dom.local>
References: <20081002194845.GB2664@ami.dom.local> <20081003073418.GA5235@ff.dom.local> <20081003074351.GB5235@ff.dom.local> <1223145027.23358.20.camel@f6bvp-5> <20081004191114.GA15152@ami.dom.local> <20081004200939.GB15152@ami.dom.local> <1223221212.18094.4.camel@f6bvp-5>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	David Miller <davem@davemloft.net>
To: "Bernard, f6bvp" <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:20301 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754104AbYJEUdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 16:33:39 -0400
Received: by ey-out-2122.google.com with SMTP id 6so752789eyi.37
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2008 13:33:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1223221212.18094.4.camel@f6bvp-5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 05, 2008 at 05:40:12PM +0200, Bernard, f6bvp wrote:
> With kernel-2.6.27-rc7 and ypur patches including netrom one I observ=
ed
> three events via netconsole.
> I think that they were triggered by NetRom activity I exercized on
> purpose.
> See attached documents.

Bernard, do you mean exactly "With kernel-2.6.27-rc7 and ypur patches
including netrom" or this all and David's patch reverted?

Jarek P.

>=20
> Le samedi 04 octobre 2008 ?? 22:09 +0200, Jarek Poplawski a =E9crit :
> > On Sat, Oct 04, 2008 at 09:11:14PM +0200, Jarek Poplawski wrote:
> > ...
> > > BTW, I think there is an additional, not serious problem with fre=
eing
> > > unorphaned sockets by netrom (as seen in your debugging logs with=
 non
> > > zero in the 2-nd, and 6 in the 3-rd column). So, it would be nice=
 to
> > > check if my #4 patch could help for this. (You need then 2.6.27-r=
c
> > > with patches #1(debugging), #3, #4 as signed in my previous messa=
ge,
> > > and of course above mentioned one reverted).
> >=20
> > BTW, could you please test it with and without the #4 (af_netrom) p=
atch?
> >=20
> > Jarek P.
> >=20
