From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] geneve: use netlink_ext_ack for error
 reporting in rtnl operations
Date: Fri, 11 Aug 2017 13:45:14 -0700 (PDT)
Message-ID: <20170811.134514.1496944956776826656.davem@davemloft.net>
References: <1502266168-12107-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@ovn.org, netdev@vger.kernel.org
To: girish.moodalbail@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59312 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753357AbdHKUpS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 16:45:18 -0400
In-Reply-To: <1502266168-12107-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Girish Moodalbail <girish.moodalbail@oracle.com>
Date: Wed,  9 Aug 2017 01:09:28 -0700

> Add extack error messages for failure paths while creating/modifying
> geneve devices. Once extack support is added to iproute2, more
> meaningful and helpful error messages will be displayed making it easy
> for users to discern what went wrong.
> 
> Before:
> =======
> $ ip link add gen1 address 0:1:2:3:4:5:6 type geneve id 200 \
>   remote 192.168.13.2
> RTNETLINK answers: Invalid argument
> 
> After:
> ======
> $ ip link add gen1 address 0:1:2:3:4:5:6 type geneve id 200 \
>   remote 192.168.13.2
> Error: Provided link layer address is not Ethernet
> 
> Also, netdev_dbg() calls used to log errors associated with Netlink
> request have been removed.
> 
> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>

Applied, thanks.
