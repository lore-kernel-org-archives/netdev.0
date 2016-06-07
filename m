From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/3] be2net: patch set
Date: Tue, 07 Jun 2016 16:19:00 -0700 (PDT)
Message-ID: <20160607.161900.1488261086934233916.davem@davemloft.net>
References: <1465212130-510-1-git-send-email-sathya.perla@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbcFGXTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 19:19:02 -0400
In-Reply-To: <1465212130-510-1-git-send-email-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@broadcom.com>
Date: Mon,  6 Jun 2016 07:22:07 -0400

> Hi David, the following patch set contains three non-critical fixes that
> can go into the net-next tree.
> 
> Patch 1 fixes the logic for provisioning queue pairs on VFs to take into
> account the limit on number of TXQs too as in some profiles the number
> of TXQs is less than that of RXQs.
> 
> Patch 2 enables WoL support from shutdown on Skyhawk.
> 
> Patch 3 enhances the logic for provisioning queue pairs on VFs on
> SR-IOV over multi-partition configs. Each PF (partition) on a port has to
> compute the number of RSS tables it's VFs can use.

Series applied, thanks.
