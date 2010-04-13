From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 2/2] gianfar: Add hardware TX timestamping
 support
Date: Tue, 13 Apr 2010 01:52:48 -0700 (PDT)
Message-ID: <20100413.015248.139841458.davem@davemloft.net>
References: <95DC1AA8EC908B48939B72CF375AA5E311B26A78@alice.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	sandeep.kumar@freescale.com, scottwood@freescale.com
To: Manfred.Rudigier@omicron.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42531
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752567Ab0DMIwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 04:52:44 -0400
In-Reply-To: <95DC1AA8EC908B48939B72CF375AA5E311B26A78@alice.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manfred Rudigier <Manfred.Rudigier@omicron.at>
Date: Fri, 9 Apr 2010 11:10:35 +0200

> If a packet has the skb_shared_tx->hardware flag set the device is
> instructed to generate a TX timestamp and write it back to memory after
> the frame is transmitted. During the clean_tx_ring operation the
> timestamp will be extracted and copied into the skb_shared_hwtstamps
> struct of the skb.
> 
> TX timestamping is enabled by setting the tx_type to something else
> than HWTSTAMP_TX_OFF with the SIOCSHWTSTAMP ioctl command. It is only
> supported by eTSEC devices.
> 
> Signed-off-by: Manfred Rudigier <manfred.rudigier@omicron.at>

Applied to net-next-2.6
