From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/6]: powerpc/cell spidernet ethernet patches
Date: Mon, 2 Oct 2006 18:50:39 +0200
Message-ID: <200610021850.41062.arnd@arndb.de>
References: <20060929230552.GG6433@austin.ibm.com> <200609301240.03464.arnd@arndb.de> <20061002162749.GB4546@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org, jeff@garzik.org, akpm@osdl.org,
	netdev@vger.kernel.org, James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:40128 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S932282AbWJBQu6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 12:50:58 -0400
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20061002162749.GB4546@austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 02 October 2006 18:27, Linas Vepstas wrote:
> >=20
> > I'm not sure if I have missed a patch in here, but I
> > don't see anything reintroducing the 'netif_stop_queue'
> > that is missing from the transmit path.
> >=20
> > Do you have a extra patch for that?
>=20
> Unfinished. =A0There are several ways in which the current=20
> spider-net driver doesn't do things the way Greg KH's, etal=20
> book on device drivers recommends. I was planning on combing=20
> through these this week.

Ok, that's good. However, removing the netif_stop_queue
was an obvious oversight that happened during the cleanup
last year.

Putting that one line back in should be a really safe fix for
the problem of overly high system load we sometimes see.

	Arnd <><
