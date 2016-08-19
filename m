From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: bridge: export vlan stats per-port
 with flags
Date: Thu, 18 Aug 2016 23:19:00 -0700 (PDT)
Message-ID: <20160818.231900.1546468845417451233.davem@davemloft.net>
References: <1471431190-27442-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, bridge@lists.linux-foundation.org
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42353 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750806AbcHSGTB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 02:19:01 -0400
In-Reply-To: <1471431190-27442-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Wed, 17 Aug 2016 12:53:08 +0200

> This set adds the ability to export vlan stats per-port. Patch 01 makes
> that possible by consolidating the bridge and port linkxstats calls. Then
> patch 02 allows to dump the vlan entry flags in order to be able to
> distinguish between bridge and port vlan entries when dumping the master
> device vlan stats. That is needed because that call was implemented when
> the stats API didn't have slave dumping capabilities and it dumps all vlan
> stats (for both bridge and port entries). We also need it in order to print
> the vlan flags when dumping the stats.

Series applied.
