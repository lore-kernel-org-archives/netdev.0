From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] sit: allow to use rtnl ops on fb tunnel
Date: Wed, 02 Oct 2013 17:08:22 -0400 (EDT)
Message-ID: <20131002.170822.1627691739724018976.davem@davemloft.net>
References: <20131001.125923.700243113980583930.davem@davemloft.net>
	<524BC816.1000702@6wind.com>
	<524BCCE2.8000700@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	pshelar@nicira.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754328Ab3JBVIY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 17:08:24 -0400
In-Reply-To: <524BCCE2.8000700@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 02 Oct 2013 09:36:02 +0200

> Le 02/10/2013 09:15, Nicolas Dichtel a =E9crit :
>> Le 01/10/2013 18:59, David Miller a =E9crit :
>>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>> Date: Tue,  1 Oct 2013 18:04:59 +0200
>>>
>>>> rtnl ops where introduced by ba3e3f50a0e5 ("sit: advertise tunnel
>>>> param via
>>>> rtnl"), but I forget to assign rtnl ops to fb tunnels.
>>>>
>>>> Now that it is done, we must remove the explicit call to
>>>> unregister_netdevice_queue(), because the fallback tunnel is added=
 to
>>>> the queue
>>>> in sit_destroy_tunnels() when checking rtnl_link_ops of all netdev=
ices
>>>> (this
>>>> is valid since commit 5e6700b3bf98 ("sit: add support of x-netns")=
).
>>>>
>>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>>
>>> Applied and queued up for -stable.
> Another things about ipip: between 0974658da47c ("ipip: advertise
> tunnel param
> via rtnl", v3.8) and fd58156e456d ("IPIP: Use ip-tunneling code.",
> v3.10) the
> fb device of ipip module has the same problem.
> Should I send a patch?

Yes please do, thanks for noticing this.
