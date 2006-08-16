From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 1/2]: powerpc/cell spidernet bottom half
Date: Wed, 16 Aug 2006 18:30:28 -0500
Message-ID: <20060816233028.GO20551@austin.ibm.com>
References: <44E38157.4070805@garzik.org> <200608162324.47235.arnd@arndb.de> <20060816.143203.11626235.davem@davemloft.net> <200608170016.47072.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org, akpm@osdl.org, jeff@garzik.org,
	netdev@vger.kernel.org, jklewis@us.ibm.com,
	linux-kernel@vger.kernel.org, Jens.Osterkamp@de.ibm.com,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:20929 "EHLO
	e36.co.us.ibm.com") by vger.kernel.org with ESMTP id S1750959AbWHPXaw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 19:30:52 -0400
To: Arnd Bergmann <arnd@arndb.de>
Content-Disposition: inline
In-Reply-To: <200608170016.47072.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 17, 2006 at 12:16:46AM +0200, Arnd Bergmann wrote:
> Am Wednesday 16 August 2006 23:32 schrieb David Miller:
> > Can spidernet be told these kinds of parameters? =A0"N packets or
> > X usecs"?
>=20
> It can not do exactly this but probably we can get close to it by

Why would you want o do this? It seems like a cruddier strategy=20
than what we can already do  (which is to never get an transmit
interrupt, as long as the kernel can shove data into the device fast
enough to keep the queue from going empty.)  The whole *point* of a=20
low-watermark interrupt is to never have to actually get the interrupt,=
=20
if the rest of the system is on its toes and is supplying data fast
enough.

--linas

