From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] ptp: feature enhancements
Date: Mon, 26 Sep 2011 16:04:43 -0400 (EDT)
Message-ID: <20110926.160443.1205173553442138535.davem@davemloft.net>
References: <cover.1316518332.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55671 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752517Ab1IZUEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 16:04:47 -0400
In-Reply-To: <cover.1316518332.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Tue, 20 Sep 2011 13:43:13 +0200

> This series adds one driver specific enhancement and one new feature
> to the PTP Hardware Clock subsystem. The first patch enables more of
> the phyter's IO capabilities. The second patch introduces PTP one-step
> support for Sync messages at the driver level. The third patch
> implements the one-step flag in the phyter.
> 
> Richard Cochran (3):
>   dp83640: enable six external events and one periodic output
>   net: introduce ptp one step time stamp mode for sync packets
>   dp83640: add time stamp insertion for sync messages

All applied to net-next, thanks.

Could you please add a test at the point where we pull in the
->tx_type value from the user, to make sure it is one of the
validly defined HWTSTAMP_TX_FOO values?

Thanks.
