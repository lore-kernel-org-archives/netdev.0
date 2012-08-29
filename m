From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next V3 0/2] Add rtnl_link_ops support to IPoIB
Date: Wed, 29 Aug 2012 14:45:16 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208291443540.1098@stinky-local.trash.net>
References: <1345724119-32110-1-git-send-email-ogerlitz@mellanox.com>
 <503DE3AC.30701@mellanox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: davem@davemloft.net, roland@kernel.org, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38397 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235Ab2H2MpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 08:45:19 -0400
In-Reply-To: <503DE3AC.30701@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Aug 2012, Or Gerlitz wrote:

> On 23/08/2012 15:15, Or Gerlitz wrote:
>> This is about adding rtnl_link_ops to IPoIB, primarly addressing feedback 
>> from Dave on a similar patch that was part of the eIPoIB submission.
>
> Dave, Roland
>
> Any comment on this? The patch was originally submitted through netdev so I 
> kept the fixed version to go through that path as well. If this makes things 
> easier, we can merge that through net-next.
>
> IPoIB has more proprietary sysfs entries, such as for setting the mode 
> (datagram or connected) -- in 2nd thought, non legacy ipoib child interfaces 
> created through rtnl shouldn't preserve these prop. mechanisms and use rtnl 
> for all sorts of configs, as done for macvlan/8021q etc devices, correct? if 
> this is indeed the case, I will fix that and submit V3.

This is how rtnl_link was intended to be used, so you can set and query
all attributes in an atomic fashion and get notifications on changes.
