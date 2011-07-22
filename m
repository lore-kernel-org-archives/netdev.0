From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vmxnet3: set netdev parant device before
 calling netdev_info
Date: Thu, 21 Jul 2011 21:34:31 -0700 (PDT)
Message-ID: <20110721.213431.1027869707534665048.davem@davemloft.net>
References: <alpine.LRH.2.00.1107201834220.19334@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pv-drivers@vmware.com
To: sbhatewara@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48115 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943Ab1GVEec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 00:34:32 -0400
In-Reply-To: <alpine.LRH.2.00.1107201834220.19334@sbhatewara-dev1.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Wed, 20 Jul 2011 19:01:11 -0700 (PDT)

> 
> Parent device for netdev should be set before netdev_info() can be called
> otherwise there is a NULL pointer dereference and probe() fails.
> 
> Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>

Applied.
