From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 23/26] RDS: Add AF and PF #defines for RDS sockets
Date: Wed, 25 Feb 2009 03:58:43 -0800 (PST)
Message-ID: <20090225.035843.143817933.davem@davemloft.net>
References: <1235525443-9007-24-git-send-email-andy.grover@oracle.com>
	<20090224.232648.84203571.davem@davemloft.net>
	<200902251336.36461.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andy.grover@oracle.com, netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54820
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752868AbZBYL7C convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 06:59:02 -0500
In-Reply-To: <200902251336.36461.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
Date: Wed, 25 Feb 2009 13:36:36 +0200

> On Wednesday 25 February 2009 09:26:48 ext David Miller, you wrote:
> > From: Andy Grover <andy.grover@oracle.com>
> > Date: Tue, 24 Feb 2009 17:30:40 -0800
> >
> > > @@ -191,7 +191,8 @@ struct ucred {
> > >  #define AF_RXRPC     33      /* RxRPC sockets                */
> > >  #define AF_ISDN              34      /* mISDN sockets           =
     */
> > >  #define AF_PHONET    35      /* Phonet sockets               */
> > > -#define AF_MAX               36      /* For now.. */
> > > +#define AF_RDS               36      /* RDS sockets             =
     */
> > > +#define AF_MAX               37      /* For now.. */
> > >
> > >  /* Protocol families, same as address families. */
> > >  #define PF_UNSPEC    AF_UNSPEC
> >
> > Pick an unused number, you don't have to increment AF_MAX
> > to allocate a value.
>=20
> But that patch is also allocating a PF value and net/socket.c has:

I'm saying to use a lower number, like 21, 27, 28, etc.

