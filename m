From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] gianfar: Add backwards compatible Single
 Queue mode polling
Date: Wed, 12 Jun 2013 03:16:39 -0700 (PDT)
Message-ID: <20130612.031639.1111694751709981287.davem@davemloft.net>
References: <CALG0vJtYfhJOMMU1rgDV8TYgkm3MJh2iibqmAJsj3nxbegBWEQ@mail.gmail.com>
	<1370884788-4862-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.guntsche@it-loops.com
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52532 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588Ab3FLKQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 06:16:40 -0400
In-Reply-To: <1370884788-4862-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Mon, 10 Jun 2013 20:19:48 +0300

> Older Single Queue (SQ_SG_MODE) devices like TSEC (i.e. mpc83xx)
> don't feature the frame receive indication bits (RXF) in RSTAT.
> For these and for the rest of the SQ_SG_MODE devices, provide the
> appropiate polling routine that handles a single pair of Rx/Tx
> BD rings, removing the overhead incurred by the multiple queues/
> multiple interrupt group devices (veTSEC/ eTSEC2.0 devices).
> So this is primarily a fix for the TSEC devices.
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied, thanks.
