From: David Miller <davem@davemloft.net>
Subject: Re: [uclinux-dist-devel] [PATCH net-next-2.6] netdev: bfin_mac:
 Use is_multicast_ether_addr helper
Date: Wed, 12 Jan 2011 19:01:43 -0800 (PST)
Message-ID: <20110112.190143.184432859.davem@davemloft.net>
References: <1294824611-10483-1-git-send-email-tklauser@distanz.ch>
	<AANLkTimztPZB3N+ZYNsDM9L3ZEM+x__bBc-JCRgO8iDC@mail.gmail.com>
	<1294852681.4114.6.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vapier.adi@gmail.com, tklauser@distanz.ch,
	michael.hennerich@analog.com,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56948
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932780Ab1AMDBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 22:01:10 -0500
In-Reply-To: <1294852681.4114.6.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 12 Jan 2011 09:18:01 -0800

> On Wed, 2011-01-12 at 11:38 -0500, Mike Frysinger wrote:
>> On Wed, Jan 12, 2011 at 04:30, Tobias Klauser wrote:
>> > --- a/drivers/net/bfin_mac.c
>> > +++ b/drivers/net/bfin_mac.c
>> > @@ -1293,7 +1293,7 @@ static void bfin_mac_multicast_hash(struct net_device *dev)
>> >                addrs = ha->addr;
>> >
>> >                /* skip non-multicast addresses */
>> > -               if (!(*addrs & 1))
>> > +               if (!is_multicast_ether_addr(addrs))
>> >                        continue;
>> 
>> looks good to me ...
>> Acked-by: Mike Frysinger <vapier@gentoo.org>
> 
> Does a netdev_for_each_mc_addr loop entry really
> need to verify that the address is multicast?
> 
> Couldn't this just be:

It could, and I'd be happy to apply a follow-on patch that does
this.
