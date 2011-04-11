From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] vxge: always enable hardware time stamp
Date: Sun, 10 Apr 2011 18:58:45 -0700 (PDT)
Message-ID: <20110410.185845.70188298.davem@davemloft.net>
References: <1302297083-22665-1-git-send-email-jdmason@kudzu.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jdmason@kudzu.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46507
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753802Ab1DKB7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2011 21:59:22 -0400
In-Reply-To: <1302297083-22665-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jdmason@kudzu.us>
Date: Fri,  8 Apr 2011 16:11:21 -0500

> Hardware time stamp calculation can only be enabled by the privileged
> function. Enable it always by default and simply use the ethtool
> interface to set a flag to indicate whether or not the respective
> function driver should indicate the timestamp along with the received
> packet.
> 
> Also, make certain fields in vxge_hw_device_config bit-fields to reduce
> the size of the struct.
> 
> Signed-off-by: Jon Mason <jdmason@kudzu.us>

Doesn't this have some performance or latency impact?

I think it should be stay off by default, people who want this know
they want it and can turn it on if they want to.
