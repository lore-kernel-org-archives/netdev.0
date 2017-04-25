From: David Miller <davem@davemloft.net>
Subject: Re: Blogpost evaluation this [PATCH v4 net-next RFC] net: Generic
 XDP
Date: Tue, 25 Apr 2017 13:31:03 -0400 (EDT)
Message-ID: <20170425.133103.1549209166033304482.davem@davemloft.net>
References: <20170424162405.1183f2e7@redhat.com>
        <20170424.182643.485613135674690555.davem@davemloft.net>
        <20170425172549.GQ4730@C02RW35GFVH8.dhcp.broadcom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, xdp-newbies@vger.kernel.org,
        netdev@vger.kernel.org
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42720 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754281AbdDYRbF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:31:05 -0400
In-Reply-To: <20170425172549.GQ4730@C02RW35GFVH8.dhcp.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Tue, 25 Apr 2017 13:25:49 -0400

> On Mon, Apr 24, 2017 at 06:26:43PM -0400, David Miller wrote:
>> Andy, how goes it? :)
> 
> Sorry for the delayed response.  I was AFK yesterday, but based on
> testing from Friday and what I wrapped up today all looks good to me.
> 
> On my system (i7-6700 CPU @ 3.40GHz) the reported and actual TX
> throughput for xdp_tx_iptunnel is 4.6Mpps for the optimized XDP.
> 
> For generic XDP the reported throughput of xdp_tx_iptunnel is 4.6Mpps
> but only ~880kpps actually on the wire.  It seems to me that can be
> fixed with a follow-up for offending drivers or the stack if deemed that
> there is a real error there.

Ok, I'll commit the latest version with tested-by tags for you, Jesper,
and David Ahern added.

Thanks everyone.
