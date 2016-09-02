From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] switchdev: Fix return value of
 switchdev_port_fdb_dump().
Date: Fri, 02 Sep 2016 11:00:41 -0700 (PDT)
Message-ID: <20160902.110041.2180958025092176907.davem@davemloft.net>
References: <1472814717-11339-1-git-send-email-rami.rosen@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        eric.dumazet@gmail.com, wkok@cumulusnetworks.com
To: rami.rosen@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54700 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750989AbcIBSAn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 14:00:43 -0400
In-Reply-To: <1472814717-11339-1-git-send-email-rami.rosen@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <rami.rosen@intel.com>
Date: Fri,  2 Sep 2016 14:11:57 +0300

> This patch fixes the retun value of switchdev_port_fdb_dump() when
> CONFIG_NET_SWITCHDEV is not set. This avoids getting "warning: return makes
> integer from pointer without a cast [-Wint-conversion]" when building
> when CONFIG_NET_SWITCHDEV is not set under several compiler versions.
> This warning is due to commit d297653dd6f07afbe7e6c702a4bcd7615680002e
> ("rtnetlink: fdb dump: optimize by saving last interface markers").
> 
> Signed-off-by: Rami Rosen <rami.rosen@intel.com>

Applied, thanks.
