From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] ipv4: allow local fragmentation in
 ip_finish_output_gso()
Date: Thu, 03 Nov 2016 16:12:44 -0400 (EDT)
Message-ID: <20161103.161244.1518109748163260273.davem@davemloft.net>
References: <1478118977-19608-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, jtluka@redhat.com,
        hannes@stressinduktion.org
To: lrichard@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42370 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755243AbcKCUMq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 16:12:46 -0400
In-Reply-To: <1478118977-19608-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lance Richardson <lrichard@redhat.com>
Date: Wed,  2 Nov 2016 16:36:17 -0400

> Some configurations (e.g. geneve interface with default
> MTU of 1500 over an ethernet interface with 1500 MTU) result
> in the transmission of packets that exceed the configured MTU.
> While this should be considered to be a "bad" configuration,
> it is still allowed and should not result in the sending
> of packets that exceed the configured MTU.
> 
> Fix by dropping the assumption in ip_finish_output_gso() that
> locally originated gso packets will never need fragmentation.
> Basic testing using iperf (observing CPU usage and bandwidth)
> have shown no measurable performance impact for traffic not
> requiring fragmentation.
> 
> Fixes: c7ba65d7b649 ("net: ip: push gso skb forwarding handling down the stack")
> Reported-by: Jan Tluka <jtluka@redhat.com>
> Signed-off-by: Lance Richardson <lrichard@redhat.com>

Applied and queued up for -stable.
