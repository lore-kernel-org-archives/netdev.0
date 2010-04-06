From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH 1/2] netdev: buffer infrastructure to log network
 driver's information
Date: Mon, 5 Apr 2010 20:10:34 -0400
Message-ID: <20100406001034.GA2156@localhost.localdomain>
References: <4BB98828.5030302@jp.fujitsu.com>
 <4BB988C9.9070709@jp.fujitsu.com>
 <1270456946.1971.27.camel@edumazet-laptop>
 <20100405.123155.263974951.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, sanagi.koki@jp.fujitsu.com,
	netdev@vger.kernel.org, izumi.taku@jp.fujitsu.com,
	kaneshige.kenji@jp.fujitsu.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57517 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755517Ab0DFAKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 20:10:47 -0400
Content-Disposition: inline
In-Reply-To: <20100405.123155.263974951.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 05, 2010 at 12:31:55PM -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 05 Apr 2010 10:42:26 +0200
>=20
> > Le lundi 05 avril 2010 =E0 15:52 +0900, Koki Sanagi a =E9crit :
> >> This patch implements buffer infrastructure under driver/net.
> >> This buffer records information from network driver.
> >>=20
> >> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> >> ---
> >>   drivers/net/Kconfig     |    8 +
> >>   drivers/net/Makefile    |    1 +
> >>   drivers/net/ndrvbuf.c   |  535 +++++++++++++++++++++++++++++++++=
++++++++++++++
> >>   include/linux/ndrvbuf.h |   57 +++++
> >>   4 files changed, 601 insertions(+), 0 deletions(-)
> >>=20
> >=20
> > Wow, 600 lines... thats what I call bloat...
>=20
> And we have all sorts of facilities for creating filesystem
> streams and ring buffers of debug information.
>=20
> You could even hook into 'perf' to log and process these
> events in probably like 12 lines of code.
>=20
I'm still having a hard time understanding why this approach is prefera=
ble to
the previous approach you took using tracepoints.  Granted you can't ge=
t driver
internal state as easily, but its generic and doesn't do...this.
Neil

