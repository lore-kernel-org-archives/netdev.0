From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] rtnl: fix the loop index update error in
 rtnl_dump_ifinfo()
Date: Sat, 19 Nov 2016 22:15:05 -0500 (EST)
Message-ID: <20161119.221505.436326824041297337.davem@davemloft.net>
References: <1479569312-15224-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45936 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753050AbcKTDPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 22:15:07 -0500
In-Reply-To: <1479569312-15224-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Sat, 19 Nov 2016 23:28:32 +0800

> If the link is filtered out, loop index should also be updated. If not,
> loop index will not be correct.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied to 'net' and queued up for -stable.

Bug fixes should always be targetted at 'net' not 'net-next'.
