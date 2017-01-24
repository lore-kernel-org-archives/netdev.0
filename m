From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/18] netvsc driver enhancements for net-next
Date: Tue, 24 Jan 2017 16:30:05 -0500 (EST)
Message-ID: <20170124.163005.1454633748162819090.davem@davemloft.net>
References: <20170124210615.18628-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34190 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751063AbdAXVaH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:30:07 -0500
In-Reply-To: <20170124210615.18628-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 24 Jan 2017 13:05:57 -0800

> Lots of little things in here. Support for minor more ethtool control,
> negotiation of offload parameters with host (based on FreeBSD) and
> several cleanups.

Series applied, but two comments for potential follow-on changes:

>   netvsc: enhance transmit select_queue

Wouldn't it be better to check for the channel table NULL pointer
before assigning the queue index to the socket?

>   netvsc: call netif_receive_skb

Hmmm, potential stack depth issues?
