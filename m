From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH v2 46/46] net: mark drivers that drop packets from rx
 queue head under memory pressure
Date: Mon, 11 Jul 2011 08:24:48 -0700
Message-ID: <20110711082448.08607039@nehalam.ftrdhcpuser.net>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
	<c84a04a957128ae664f4a80da23fad4b9f71a85f.1310339689.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Hartley Sweeten <hsweeten@visionengravers.com>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Guo-Fu Tseng <cooldavid@cooldavid.org>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Jon Mason <jdmason@kudzu.us>
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:32857 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757943Ab1GKPZR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 11:25:17 -0400
In-Reply-To: <c84a04a957128ae664f4a80da23fad4b9f71a85f.1310339689.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Jul 2011 02:52:50 +0200 (CEST)
Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:

> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>  drivers/net/arm/ep93xx_eth.c    |    3 +++
>  drivers/net/bnx2.c              |    3 +++
>  drivers/net/bnx2x/bnx2x_cmn.c   |    3 +++
>  drivers/net/cassini.c           |    3 +++
>  drivers/net/jme.c               |    3 +++
>  drivers/net/mlx4/en_rx.c        |    6 ++++++
>  drivers/net/r8169.c             |    3 +++
>  drivers/net/skge.c              |    3 +++
>  drivers/net/sky2.c              |    2 ++
>  drivers/net/tg3.c               |    2 ++
>  drivers/net/tokenring/olympic.c |    2 ++
>  drivers/net/vxge/vxge-main.c    |    3 +++
>  12 files changed, 36 insertions(+), 0 deletions(-)
>=20

Nak. This is normal behavior and putting in a compile warning is just
useless extra noise.
