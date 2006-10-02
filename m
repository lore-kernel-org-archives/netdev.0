From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 0/6]: powerpc/cell spidernet ethernet patches
Date: Mon, 2 Oct 2006 12:23:00 -0500
Message-ID: <20061002172300.GD4546@austin.ibm.com>
References: <20060929230552.GG6433@austin.ibm.com> <200609301240.03464.arnd@arndb.de> <20061002162749.GB4546@austin.ibm.com> <200610021850.41062.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org, jeff@garzik.org, akpm@osdl.org,
	netdev@vger.kernel.org, James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:2234 "EHLO e33.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S965143AbWJBRXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 13:23:02 -0400
To: Arnd Bergmann <arnd@arndb.de>
Content-Disposition: inline
In-Reply-To: <200610021850.41062.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 02, 2006 at 06:50:39PM +0200, Arnd Bergmann wrote:
> On Monday 02 October 2006 18:27, Linas Vepstas wrote:
> > >=20
> > > I'm not sure if I have missed a patch in here, but I
> > > don't see anything reintroducing the 'netif_stop_queue'
> > > that is missing from the transmit path.
> > >=20
> > > Do you have a extra patch for that?
> >=20
> > Unfinished. =A0There are several ways in which the current=20
> > spider-net driver doesn't do things the way Greg KH's, etal=20
> > book on device drivers recommends. I was planning on combing=20
> > through these this week.
>=20
> Ok, that's good. However, removing the netif_stop_queue
> was an obvious oversight that happened during the cleanup
> last year.
>=20
> Putting that one line back in should be a really safe fix for
> the problem of overly high system load we sometimes see.

Hmm. I have a patch from 5 weeks ago that seems to insert a bunch=20
of these. I'm not sure why it hadn't been mailed before, I'll=20
test and post as soon as I can.

--linas
