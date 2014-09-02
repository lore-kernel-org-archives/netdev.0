From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qeth: don't query for info if hardware not ready.
Date: Tue, 02 Sep 2014 13:54:53 -0700 (PDT)
Message-ID: <20140902.135453.1641959942842500454.davem@davemloft.net>
References: <20140902062017.GA23360@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: blaschka@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58528 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754615AbaIBUyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 16:54:54 -0400
In-Reply-To: <20140902062017.GA23360@tuxmaker.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Date: Tue, 2 Sep 2014 08:20:17 +0200

> From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
> 
> When qeth device is queried for ethtool data, hardware operation
> is performed to extract the necessary information from the card.
> If the card is not online at the moment (e.g. it is undergoing
> recovery), this operation produces undesired effects like
> temporarily freezing the system. This patch prevents execution
> of the hardware query operation when the card is not online.
> In such case, ioctl() operation returns error with errno ENODEV.
> 
> Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
> Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
> Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>

Applied.
