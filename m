From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Add SRIOV configuration via sysfs and few
 fixes
Date: Wed, 15 Jun 2016 14:46:31 -0700 (PDT)
Message-ID: <20160615.144631.1655781774102529663.davem@davemloft.net>
References: <1465895372-21101-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34402 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161092AbcFOVqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 17:46:33 -0400
In-Reply-To: <1465895372-21101-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue, 14 Jun 2016 14:39:29 +0530

> This series adds support to configure SR-IOV via PCI sysfs interface,
> reduces resource allocation in kdump kernel by disabling offload. Also
> synchronize unicast and multicast mac address, even in the interface is in
> Promiscuous mode.
> 
> This patch series has been created against net-next tree and includes
> patches on cxgb4 and cxgb4vf driver.
> 
> We have included all the maintainers of respective drivers. Kindly review
> the change and let us know in case of any review comments.

A great example of why not to add module parameters to drivers.

Series applied, thanks.
