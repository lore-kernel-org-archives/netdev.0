From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next RFC] net: Generic XDP
Date: Tue, 18 Apr 2017 15:07:08 -0400 (EDT)
Message-ID: <20170418.150708.1605529107204449972.davem@davemloft.net>
References: <20170413.162315.1889531431093534154.davem@davemloft.net>
        <20170415005949.GB73685@ast-mbp.thefacebook.com>
        <20170418190535.GG4730@C02RW35GFVH8.dhcp.broadcom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, michael.chan@broadcom.com,
        netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43476 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751363AbdDRTHK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 15:07:10 -0400
In-Reply-To: <20170418190535.GG4730@C02RW35GFVH8.dhcp.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Tue, 18 Apr 2017 15:05:35 -0400

> On Fri, Apr 14, 2017 at 05:59:51PM -0700, Alexei Starovoitov wrote:
>> On Thu, Apr 13, 2017 at 04:23:15PM -0400, David Miller wrote:
>> > +
>> > +	switch (act) {
>> > +	case XDP_TX:
>> > +		__skb_push(skb, skb->mac_len);
>> 
>> s/skb->mac_len/mac_len/
>> 
> 
> I was away from my keyboard for a few days, but was able to get some
> time to test this today.
> 
> When using this change above suggested by Alexei, XDP_DROP and XDP_TX
> actions appear to work well with xdp1 and xdp2.
> 
> I'm seeing some rather odd behavior with xdp_tx_tunnel so it might be
> good to hold off on committing this just yet.
> 
> At first glance, it looks like there is enough headroom for the new
> frame, but the resulting packet data do not look right and I'm actually
> seeing some data that may be left on the stack from a previous caller.

Thanks for testing Andy, I'll take a look and see if I can figure it out.
