From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2, 1/1] tcp: accommodate sequence number to a peer's
 shrunk receive window caused by precision loss in window scaling
Date: Fri, 17 Feb 2017 15:30:48 -0500 (EST)
Message-ID: <20170217.153048.1532740505360956399.davem@davemloft.net>
References: <BA334603-D37E-4C94-BB8B-19A830E0355C@netapp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net
To: Cheng.Cui@netapp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48660 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934090AbdBQUm0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 15:42:26 -0500
In-Reply-To: <BA334603-D37E-4C94-BB8B-19A830E0355C@netapp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Cui, Cheng" <Cheng.Cui@netapp.com>
Date: Fri, 17 Feb 2017 17:04:55 +0000

> Prevent sending out a left-shifted sequence number from a Linux sender in 
> response to a peer's shrunk receive-window caused by losing least significant
> bits in window-scaling.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Cheng Cui <Cheng.Cui@netapp.com>

Applied to net-next.
