From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Support matching on
 SCTP ports
Date: Thu, 03 Nov 2016 16:26:52 -0400 (EDT)
Message-ID: <20161103.162652.718504734925720383.davem@davemloft.net>
References: <1478175862-28642-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42796 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756947AbcKCU0x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 16:26:53 -0400
In-Reply-To: <1478175862-28642-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Thu,  3 Nov 2016 13:24:21 +0100

> Support matching on SCTP ports in the same way that matching
> on TCP and UDP ports is already supported.
> 
> Example usage:
> 
> tc qdisc add dev eth0 ingress
> 
> tc filter add dev eth0 protocol ip parent ffff: \
>         flower indev eth0 ip_proto sctp dst_port 80 \
>         action drop
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Applied, thanks Simon.
