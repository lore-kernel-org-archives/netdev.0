From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: igmp: Use ingress interface rather than vrf device
Date: Wed, 16 Aug 2017 11:10:28 -0700 (PDT)
Message-ID: <20170816.111028.670221926288940207.davem@davemloft.net>
References: <1502847522-13020-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34650 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751847AbdHPSK3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 14:10:29 -0400
In-Reply-To: <1502847522-13020-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Tue, 15 Aug 2017 18:38:42 -0700

> Anuradha reported that statically added groups for interfaces enslaved
> to a VRF device were not persisting. The problem is that igmp queries
> and reports need to use the data in the in_dev for the real ingress
> device rather than the VRF device. Update igmp_rcv accordingly.
> 
> Fixes: e58e41596811 ("net: Enable support for VRF with ipv4 multicast")
> Reported-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied and queued up for -stable, thanks.
