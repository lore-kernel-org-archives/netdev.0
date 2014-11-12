From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ptp: fix time stamp matching logic for VLAN
 packets.
Date: Wed, 12 Nov 2014 15:06:41 -0500 (EST)
Message-ID: <20141112.150641.2230107300980046135.davem@davemloft.net>
References: <1415788432-21617-1-git-send-email-richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stefan.sorensen@spectralink.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46095 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190AbaKLUGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 15:06:42 -0500
In-Reply-To: <1415788432-21617-1-git-send-email-richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Wed, 12 Nov 2014 11:33:52 +0100

> Commit ae5c6c6d "ptp: Classify ptp over ip over vlan packets" changed the
> code in two drivers that matches time stamps with PTP frames, with the goal
> of allowing VLAN tagged PTP packets to receive hardware time stamps.
> 
> However, that commit failed to account for the VLAN header when parsing
> IPv4 packets. This patch fixes those two drivers to correctly match VLAN
> tagged IPv4/UDP PTP messages with their time stamps.
> 
> This patch should also be applied to v3.17.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Applied and queued up for -stable, thanks Richard.
