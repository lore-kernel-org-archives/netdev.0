From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 0/8] sunvnet driver updates
Date: Tue, 14 Feb 2017 13:04:37 -0500 (EST)
Message-ID: <20170214.130437.1795348617839754542.davem@davemloft.net>
References: <1487012224-403399-1-git-send-email-shannon.nelson@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: shannon.nelson@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38764 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753190AbdBNSEj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 13:04:39 -0500
In-Reply-To: <1487012224-403399-1-git-send-email-shannon.nelson@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@oracle.com>
Date: Mon, 13 Feb 2017 10:56:56 -0800

> The sunvnet ldom virtual network driver was due for some updates and
> a bugfix or two.  These patches address a few items left over from
> last year's make-over.
> 
> v2:
>  - changed memory barrier fix to use smp_wmb
>  - put NETIF_F_SG back into the advertised ldmvsw hw_features
> 
> v3:
>  - the sunvnet_common module doesn't need module_init or _exit
> 
> v4:
>  - dropped the statistics patch
>  - fixed up "default" tag for SUNVNET_COMMON

Series applied, thanks.
