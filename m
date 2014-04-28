From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ptp: validate the requested frequency
 adjustment.
Date: Mon, 28 Apr 2014 13:29:17 -0400 (EDT)
Message-ID: <20140428.132917.2207057296687531685.davem@davemloft.net>
References: <ab098280c43e23292c28cabaa4cda13d8f21ca29.1398603530.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44902 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755676AbaD1TSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 15:18:13 -0400
In-Reply-To: <ab098280c43e23292c28cabaa4cda13d8f21ca29.1398603530.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Sun, 27 Apr 2014 15:01:27 +0200

> PTP Hardware Clock drivers specify a maximum frequency adjustment that
> their clocks can accommodate. Normally, user space programs will want to
> respect the advertised limits. However, no kernel or driver code checks
> that the dialed frequency offset is within the bounds, and out of range
> values can lead to surprising results.
> 
> This patch fixes the issue by rejecting bad values.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Applied.
