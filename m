From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tg3: update rx_jumbo_pending ring param only when
 jumbo frames are enabled
Date: Fri, 18 Apr 2014 18:01:51 -0400 (EDT)
Message-ID: <20140418.180151.634079582942024473.davem@davemloft.net>
References: <1397739068-14240-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37929 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068AbaDRV7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2014 17:59:42 -0400
In-Reply-To: <1397739068-14240-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Thu, 17 Apr 2014 14:51:08 +0200

> The patch fixes a problem with dropped jumbo frames after usage of
> 'ethtool -G ... rx'.
> 
> Scenario:
> 1. ip link set eth0 up
> 2. ethtool -G eth0 rx N # <- This zeroes rx-jumbo
> 3. ip link set mtu 9000 dev eth0
> 
> The ethtool command set rx_jumbo_pending to zero so any received jumbo
> packets are dropped and you need to use 'ethtool -G eth0 rx-jumbo N'
> to workaround the issue.
> The patch changes the logic so rx_jumbo_pending value is changed only if
> jumbo frames are enabled (MTU > 1500).
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied and queued up for -stable.
