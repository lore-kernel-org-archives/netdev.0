From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 path MTU discovery broken
Date: Sun, 6 Oct 2013 14:44:03 +0200
Message-ID: <20131006124403.GA9295@order.stressinduktion.org>
References: <20130927201420.GB12043@sesse.net> <20130928203318.GC23654@order.stressinduktion.org> <20131006120612.GA27852@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, edumazet@google.com
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43699 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046Ab3JFMoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Oct 2013 08:44:05 -0400
Content-Disposition: inline
In-Reply-To: <20131006120612.GA27852@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 06, 2013 at 02:06:12PM +0200, Steinar H. Gunderson wrote:
> On Sat, Sep 28, 2013 at 10:33:18PM +0200, Hannes Frederic Sowa wrote:
> >> So the =E2=80=9Cpacket too big=E2=80=9D packets really look like t=
hey're being ignored.
> >> However, they _do_ reach the kernel somehow, since Icmp6InPktTooBi=
gs
> >> seems to increase.
> >>=20
> >> Could this be related somehow to the packets coming from 2001:67c:=
29f4::31,
> >> while the default route is to a link-local address? (An RPF issue?=
) This used
> >> to work (although it was often flaky for me) in 3.10 and before. I=
 can't
> >> easily bisect, though, as I don't boot this machine too often.
> > This looks like a bug and should definitely get fixed. There should=
 be
> > no RPF issue. May I have a look at your /proc/net/ipv6_route?
>=20
> It started again, so now I could capture what you asked for:

Thanks!

Do you know which remote IP address is part in the failing communicatio=
n? Same
as above?

Greetings,

  Hannes
