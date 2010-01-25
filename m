From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6] net: use helpers to access uc list
Date: Mon, 25 Jan 2010 13:14:29 +0100
Message-ID: <20100125121427.GB2902@psychotron.redhat.com>
References: <20100124104239.GA21371@psychotron.redhat.com>
 <20100124.230251.177086043.davem@davemloft.net>
 <20100125083450.GA2902@psychotron.redhat.com>
 <20100125.020628.124583614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26628 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752092Ab0AYMOe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 07:14:34 -0500
Content-Disposition: inline
In-Reply-To: <20100125.020628.124583614.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jan 25, 2010 at 11:06:28AM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Mon, 25 Jan 2010 09:34:52 +0100
>
>> Well I use "unsigned char *" as iterator because it would allow
>> smooth thansition to list_head in case of mc_list. Currently "struct
>> dev_addr_list" is used to store address in the list but in the end
>> "struct netdev_hw_addr *" will be used.  To use "struct list_head *"
>> or "struct netdev_hw_addr *" as an iterator it would be needed to
>> convert all drivers at once and that's not doable. Therefore I see
>> "unsigned char *" cursor as the best option.
>
>But it's not what you want to use in the end, at all.
>
>If you're going to use a very ugly and opaque iterator type merely to
>ease transition, that's not a good reason.

I definitelly see your concerns. I'll think of a better way. Thanks for the
review!

Redards.

Jirka
