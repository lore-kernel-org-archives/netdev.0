From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: [PATCH] [TPROXY] implemented IP_RECVORIGDSTADDR socket option
Date: Thu, 13 Nov 2008 12:37:46 +0100
Message-ID: <1226576266.7446.13.camel@bzorp.balabit>
References: <1226572624.7164.11.camel@bzorp.balabit>
	 <200811131309.10693.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:32817 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751869AbYKMLhu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2008 06:37:50 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id ED97339D64A
	for <netdev@vger.kernel.org>; Thu, 13 Nov 2008 12:37:46 +0100 (CET)
In-Reply-To: <200811131309.10693.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-11-13 at 13:09 +0200, R=C3=A9mi Denis-Courmont wrote:
> On Thursday 13 November 2008 12:37:04 ext Balazs Scheidler, you wrote=
:
> > In case UDP traffic is redirected to a local UDP socket,
> > the originally addressed destination address/port
> > cannot be recovered with the in-kernel tproxy.
> >
> > This patch adds an IP_RECVORIGDSTADDR sockopt that enables
> > a IP_ORIGDSTADDR ancillary message in recvmsg(). This
> > ancillary message contains the original destination address/port
> > of the packet being received.
>=20
> Does this not duplicate the IP_PKTINFO functionality?
>=20

IP_PKTINFO does not have a port number field which may be changed with
tproxy redirections.

--=20
Bazsi


