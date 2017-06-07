From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] vxlan: use a more suitable function when assigning
 NULL
Date: Wed, 07 Jun 2017 15:26:32 -0400 (EDT)
Message-ID: <20170607.152632.1622878385522436454.davem@davemloft.net>
References: <1496835418-22723-1-git-send-email-markb@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, stephen@networkplumber.org,
        netdev@vger.kernel.org
To: markb@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34564 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752216AbdFGT0e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 15:26:34 -0400
In-Reply-To: <1496835418-22723-1-git-send-email-markb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Bloch <markb@mellanox.com>
Date: Wed,  7 Jun 2017 14:36:58 +0300

> When stopping the vxlan interface we detach it from the socket.
> Use RCU_INIT_POINTER() and not rcu_assign_pointer() to do so.
> 
> Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Mark Bloch <markb@mellanox.com>

Applied, thanks Mark.
