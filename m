From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [RFC] [PATCH 6/7] pcmcia: use pcmcia_loop_config in net pcmcia
 drivers
Date: Tue, 29 Jul 2008 15:21:16 -0500
Message-ID: <488F7BBC.1000300@lwfinger.net>
References: <20080729071539.GB27385@comet.dominikbrodowski.net> <20080729072111.GI27385@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-pcmcia@lists.infradead.org, Jeff Garzik <jgarzik@pobox.com>,
	netdev@vger.kernel.org
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:50350 "EHLO
	mtiwmhc11.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752136AbYG2UV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 16:21:26 -0400
In-Reply-To: <20080729072111.GI27385@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dominik Brodowski wrote:
> Use the config loop helper in (some) net pcmcia drivers.
> 
> CC: Jeff Garzik <jgarzik@pobox.com>
> CC: <netdev@vger.kernel.org>
> Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
> ---
>  drivers/net/pcmcia/axnet_cs.c    |   71 ++++++++++++++-------------------
>  drivers/net/pcmcia/pcnet_cs.c    |   79 ++++++++++++++++++--------------------
>  drivers/net/pcmcia/smc91c92_cs.c |   46 ++++++----------------
>  3 files changed, 80 insertions(+), 116 deletions(-)

ACK for pcnet_cs.c by Larry Finger <Larry.Finger@lwfinger.net>.

Tested with 2.6.27-rc1.

Larry
