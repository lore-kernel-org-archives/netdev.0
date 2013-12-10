From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] neigh: use neigh_parms_net() to get struct
 neigh_parms->net pointer
Date: Wed, 11 Dec 2013 00:11:13 +0100
Message-ID: <20131210231113.GF2469@minipsycho.orion>
References: <1386716107-18843-1-git-send-email-jiri@resnulli.us>
 <20131210.175929.828518960842627263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:36066 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab3LJXLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 18:11:16 -0500
Received: by mail-ee0-f54.google.com with SMTP id e51so2455566eek.13
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 15:11:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131210.175929.828518960842627263.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Dec 10, 2013 at 11:59:29PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Tue, 10 Dec 2013 23:55:07 +0100
>
>> This fixes compile error when CONFIG_NET_NS is not set.
>> 
>> Introduced by:
>> commit 1d4c8c29841b9991cdf3c7cc4ba7f96a94f104ca
>>     "neigh: restore old behaviour of default parms values"
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ...
>> -	struct net *net = p->net;
>> +	struct net *net = neigh_parms_net(p);
>
>Hey look at that, the interface already existed :-)

Yep. It was just my dumb head that missed that :)

>
>Applied, thanks Jiri.
