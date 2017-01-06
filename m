From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH next] ipv6: do not send RTM_DELADDR for tentative
 addresses
Date: Fri, 06 Jan 2017 15:39:50 -0500 (EST)
Message-ID: <20170106.153950.509531386949440475.davem@davemloft.net>
References: <20170104230101.17470-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        hannes@stressinduktion.org
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40516 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031517AbdAFUjw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 15:39:52 -0500
In-Reply-To: <20170104230101.17470-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Wed,  4 Jan 2017 15:01:01 -0800

> From: Mahesh Bandewar <maheshb@google.com>
> 
> RTM_NEWADDR notification is sent when IFA_F_TENTATIVE is cleared from
> the address. So if the address is added and deleted before DAD probes
> completes, the RTM_DELADDR will be sent for which there was no
> RTM_NEWADDR causing asymmetry in notification. However if the same
> logic is used while sending RTM_DELADDR notification, this asymmetry
> can be avoided.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

This makes a lot of sense, applied, thanks!
