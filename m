From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net 0/4] macvlan: Fix some issues with changing mac
 addresses
Date: Thu, 22 Jun 2017 11:17:58 -0400 (EDT)
Message-ID: <20170622.111758.886152844955675351.davem@davemloft.net>
References: <20170621115919.28165-1-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, girish.moodalbail@oracle.com,
        vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35990 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751434AbdFVPSA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 11:18:00 -0400
In-Reply-To: <20170621115919.28165-1-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Wed, 21 Jun 2017 07:59:15 -0400

> There are some issues in macvlan wrt to changing it's mac address.
> * An error is returned in the specified address is the same as an already
>   assigned address.
> * In passthru mode, the mac address of the macvlan device doesn't change.
> * After changing the mac address of a passthru macvlan and then removing it,
>   the mac address of the physical device remains changed.
> 
> This patch series attempts to resolve these issues.
> 
> V2: Address a small issue in p4 where we save the address from the lowerdev
>     (from girish.moodalbail@oracle.com)

Series applied, thanks.
