From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibmvnic: Remove netdev notify for failover
 resets
Date: Tue, 13 Jun 2017 13:00:52 -0400 (EDT)
Message-ID: <20170613.130052.1149087382396212587.davem@davemloft.net>
References: <20170613004745.52815.48392.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nfont@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44618 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753595AbdFMRAy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 13:00:54 -0400
In-Reply-To: <20170613004745.52815.48392.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Mon, 12 Jun 2017 20:47:45 -0400

> When handling a driver reset due to a failover of the backing
> server on the vios, doing the netdev_notify_peers() can cause
> network traffic to stall or halt. Remove the netdev notify call
> for failover resets.
> 
> Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>

Applied.
