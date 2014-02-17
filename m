From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: fe80::/64 route missing on GRE tunnels
Date: Mon, 17 Feb 2014 14:04:54 +0100
Message-ID: <20140217130454.GB22833@order.stressinduktion.org>
References: <20140211215510.GA6994@sesse.net> <20140211215928.GA7862@sesse.net> <20140215074559.GA8634@order.stressinduktion.org> <20140215121027.GC8634@order.stressinduktion.org> <5301D843.4020802@6wind.com> <20140217094557.GB32630@sesse.net> <5301DD8A.10808@6wind.com> <20140217101730.GC32630@sesse.net> <5301E59F.5090506@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, itk-intern@samfundet.no, sesse@samfundet.no
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60640 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752321AbaBQNEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 08:04:55 -0500
Content-Disposition: inline
In-Reply-To: <5301E59F.5090506@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 17, 2014 at 11:34:07AM +0100, Nicolas Dichtel wrote:
> Le 17/02/2014 11:17, Steinar H. Gunderson a =C3=A9crit :
> >On Mon, Feb 17, 2014 at 10:59:38AM +0100, Nicolas Dichtel wrote:
> >>>It is added (ip -6 addr add fe80::1 dev foo), but it doesn't help=20
> >>>without the
> >>>/64 being present.
> >>With 'ip -6 addr add fe80::1/64 dev foo', the link local route will=
 be=20
> >>added.
> >
> >Possible, but you're still breaking userspace. You could argue the t=
unnel
> >setup system in question should have added a /64 in the first place,=
 but it
> >is deployed at a number of locations and changing all of them is not=
=20
> >trivial.
> I will propose a patch (instead of reverting the original one).

Thanks for looking into this, Nicolas. I agree it is not a very nice
situation.
