From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] gianfar: Fix invalid TX frames returned on
 error queue when time stamping
Date: Thu, 12 Jan 2012 15:26:19 -0800 (PST)
Message-ID: <20120112.152619.2007546642181896584.davem@davemloft.net>
References: <1326187612-27384-1-git-send-email-manfred.rudigier@omicron.at>
	<1326187612-27384-2-git-send-email-manfred.rudigier@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com,
	avorontsov@mvista.com, richardcochran@gmail.com,
	eric.dumazet@gmail.com
To: manfred.rudigier@omicron.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42159 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755278Ab2ALX0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 18:26:32 -0500
In-Reply-To: <1326187612-27384-2-git-send-email-manfred.rudigier@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manfred Rudigier <manfred.rudigier@omicron.at>
Date: Tue, 10 Jan 2012 10:26:51 +0100

> When TX time stamping for PTP messages is enabled on a socket, a time
> stamp is returned on the socket error queue to the user space application
> after the frame was transmitted. The transmitted frame is also returned on
> the error queue so that an application knows to which frame the time stamp
> belongs.
> 
> In the current implementation the TxFCB is immediately followed by the
> frame. Since the eTSEC inserts the TX time stamp 8 bytes after the TxFCB,
> parts of the frame have been overwritten and an invalid frame was returned
> on the socket error queue.
> 
> This patch fixes the described problem by adding additional 16 padding
> bytes between the TxFCB and the frame for all messages sent from a time
> stamping enabled socket (other sockets are not affected).
> 
> Signed-off-by: Manfred Rudigier <manfred.rudigier@omicron.at>

Applied.
