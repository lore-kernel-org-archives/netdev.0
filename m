From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/3] net: Allow non-fatal messages to be
 passed in extack
Date: Wed, 01 Nov 2017 11:51:41 +0900 (KST)
Message-ID: <20171101.115141.825853765204769299.davem@davemloft.net>
References: <1509151034-28278-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com,
        johannes.berg@intel.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44306 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932210AbdKACvp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 22:51:45 -0400
In-Reply-To: <1509151034-28278-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Fri, 27 Oct 2017 17:37:11 -0700

> There are many cases where networking subsystems throw non-fatal warning
> messages that end up in dmesg / kernel log to which a user making the
> change is completely oblivious. This set makes the extack facility
> usable for returning such messages.
> 
> The case in point here is spectrum and adding FIB rules which causes an
> offload abort. Make the use case more user friendly by letting the user
> know that offload is no longer happening because of the rule change.
> 
> v2
> - kept the offload abort in a work queue entry per Ido's comment

Series applied, thanks David.
