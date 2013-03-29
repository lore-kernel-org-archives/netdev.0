From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fix disabling of arp_interval and miimon
Date: Fri, 29 Mar 2013 15:03:28 -0400 (EDT)
Message-ID: <20130329.150328.1429949615777944148.davem@davemloft.net>
References: <1364391161-26605-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56050 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754502Ab3C2TDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 15:03:35 -0400
In-Reply-To: <1364391161-26605-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Wed, 27 Mar 2013 14:32:41 +0100

> Currently if either arp_interval or miimon is disabled, they both get
> disabled, and upon disabling they get executed once more which is not
> the proper behaviour. Also when doing a no-op and disabling an already
> disabled one, the other again gets disabled.
> Also fix the error messages with the proper valid ranges, and a small
> typo fix in the up delay error message (outputting "down delay", instead
> of "up delay").
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Indeed the existing code looks completely wrong.

Applied and queued up for -stable, thanks.
