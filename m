From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/2] gianfar: Add hardware RX timestamping
 support
Date: Tue, 13 Apr 2010 01:52:42 -0700 (PDT)
Message-ID: <20100413.015242.155130766.davem@davemloft.net>
References: <95DC1AA8EC908B48939B72CF375AA5E311B26A77@alice.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	sandeep.kumar@freescale.com, scottwood@freescale.com
To: Manfred.Rudigier@omicron.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42523
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752580Ab0DMIwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 04:52:38 -0400
In-Reply-To: <95DC1AA8EC908B48939B72CF375AA5E311B26A77@alice.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manfred Rudigier <Manfred.Rudigier@omicron.at>
Date: Fri, 9 Apr 2010 11:10:03 +0200

> The device is configured to insert hardware timestamps into all
> received packets. The RX timestamps are extracted from the padding
> alingment bytes during the clean_rx_ring operation and copied into the
> skb_shared_hwtstamps struct of the skb. This extraction only happens if
> the rx_filter was set to something else than HWTSTAMP_FILTER_NONE with
> the SIOCSHWTSTAMP ioctl command.
> 
> Hardware timestamping is only supported for eTSEC devices. To indicate
> device support the new FSL_GIANFAR_DEV_HAS_TIMER flag was introduced.
> 
> Signed-off-by: Manfred Rudigier <manfred.rudigier@omicron.at>

Applied to net-next-2.6
