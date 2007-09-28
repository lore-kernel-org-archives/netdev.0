From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPoIB: Convert to netdevice internal stats
Date: Fri, 28 Sep 2007 15:34:25 -0700 (PDT)
Message-ID: <20070928.153425.43869012.davem@davemloft.net>
References: <ada641umo2u.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.org, jeff@garzik.org,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54359
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753478AbXI1We0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 18:34:26 -0400
In-Reply-To: <ada641umo2u.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Fri, 28 Sep 2007 15:18:01 -0700

> Use the stats member of struct netdevice in IPoIB, so we can save
> memory by deleting the stats member of struct ipoib_dev_priv, and save
> code by deleting ipoib_get_stats().
> 
> Signed-off-by: Roland Dreier <rolandd@cisco.com>

Applied to net-2.6.24, thanks.

How is that ibm_emac NAPI conversion coming along? :-)
