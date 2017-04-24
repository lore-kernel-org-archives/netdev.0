From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] tipc: check return value of nlmsg_new
Date: Mon, 24 Apr 2017 15:51:45 -0400 (EDT)
Message-ID: <20170424.155145.1355712525746160380.davem@davemloft.net>
References: <1492931359-25004-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
        netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
        linux-kernel@vger.kernel.org
To: bianpan2016@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56836 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S975399AbdDXTvs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 15:51:48 -0400
In-Reply-To: <1492931359-25004-1-git-send-email-bianpan2016@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pan Bian <bianpan2016@163.com>
Date: Sun, 23 Apr 2017 15:09:19 +0800

> Function nlmsg_new() will return a NULL pointer if there is no enough
> memory, and its return value should be checked before it is used.
> However, in function tipc_nl_node_get_monitor(), the validation of the
> return value of function nlmsg_new() is missed. This patch fixes the
> bug.
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Applied.
