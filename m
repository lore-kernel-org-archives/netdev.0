From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/3] tcp: SACK RTTM changes for congestion
 control
Date: Sun, 03 May 2015 23:18:30 -0400 (EDT)
Message-ID: <20150503.231830.1607485359485463917.davem@davemloft.net>
References: <1430435459-12805-1-git-send-email-kennetkl@ifi.uio.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com
To: kennetkl@ifi.uio.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59264 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987AbbEDDSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 23:18:33 -0400
In-Reply-To: <1430435459-12805-1-git-send-email-kennetkl@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Date: Fri,  1 May 2015 01:10:56 +0200

> This patch series improves SACK RTT measurements for congestion control:
>   o Picks the latest sequence SACKed for RTT, i.e. most accurate delay
>     signal.
>   o Calls the congestion control's pkts_acked hook with SACK RTTMs
>     even when not sequentially ACKing new data.
> 
> V2: amend misleading comment

Series applied to net-next, thanks.
