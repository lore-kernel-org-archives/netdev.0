From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] vxlan: Bypass encapsulation if the
 destination is local
Date: Sun, 07 Apr 2013 17:00:08 -0400 (EDT)
Message-ID: <20130407.170008.663673479376728205.davem@davemloft.net>
References: <1364941912.29336.36.camel@oc1677441337.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, dlstevens@us.ibm.com, netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58346 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934310Ab3DGVAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 17:00:10 -0400
In-Reply-To: <1364941912.29336.36.camel@oc1677441337.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Tue, 02 Apr 2013 15:31:52 -0700

> This patch bypasses vxlan encapsulation if the destination vxlan
> endpoint is a local device.
> 
> Changes since v1: added missing check for vxlan_find_vni() failure
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied, but...

> +		if (!dst_vxlan)
> +			goto tx_error;	
                                      ^^


Trailing whitespace.  We have many tools which will warn you about
things like this.

Thanks.
