From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 00/14] [RFC] Phonet protocol stack
Date: Wed, 17 Sep 2008 00:15:48 -0400
Message-ID: <1221624949.23335.11.camel@localhost.localdomain>
References: <200809161757.38571.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44949 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750807AbYIQEPS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Sep 2008 00:15:18 -0400
In-Reply-To: <200809161757.38571.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-09-16 at 17:57 +0300, R=C3=A9mi Denis-Courmont wrote:
> 	Hello,
>=20
> This patch series introduces support for PhoNet,
> the "Phone Network protocol". This protocol is the primary interface
> to Nokia cellular modem engines. We are integrating it to the Linux
> kernel in order to support HSPA cellular data connectivity on the
> Maemo Software platform.

Do you have any documentation or examples of how userspace uses this
interface?  I'm starting to see a proliferation of methods by which
userspace now has to talk to cellular modems and I'd like to keep a
handle on them, despite the fact that they all pretty much do the same
thing and thus you'd think they'd expose about the same interface...

Dan

> This patchset provides a simple datagram socket=20
> independent of the underlying hardware (network interface) through
> which the modem is attached. We are in the process of contributing
> a lower-layer driver through Linux OMAP.
>=20
> This series is based on net-next-2.6, plus the tiny MISDN lockdep fix
> I posted to netdev yesterday.
>=20
> Any comments welcome.
>=20
> --
>  Documentation/networking/phonet.txt |  111 ++++++++
>  include/linux/if_ether.h            |    1
>  include/linux/if_phonet.h           |   16 +
>  include/linux/phonet.h              |  136 ++++++++++
>  include/linux/rtnetlink.h           |    4
>  include/linux/socket.h              |    4
>  include/net/phonet/phonet.h         |  103 +++++++
>  include/net/phonet/pn_dev.h         |   63 ++++
>  net/Kconfig                         |    1
>  net/Makefile                        |    1
>  net/core/sock.c                     |    9
>  net/phonet/Kconfig                  |   11
>  net/phonet/Makefile                 |   11
>  net/phonet/af_phonet.c              |  485 +++++++++++++++++++++++++=
++++++++++-
>  net/phonet/datagram.c               |  197 ++++++++++++++
>  net/phonet/pn_dev.c                 |  232 +++++++++++++++++
>  net/phonet/pn_netlink.c             |  239 +++++++++++++++++
>  net/phonet/socket.c                 |  314 +++++++++++++++++++++++
>  net/phonet/sysctl.c                 |  111 ++++++++
>  19 files changed, 2036 insertions(+), 13 deletions(-)
>=20
> Regards,
>=20

