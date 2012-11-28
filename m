From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH net-next] gro: Handle inline VLAN tags
Date: Wed, 28 Nov 2012 12:30:12 -0500
Message-ID: <50B64A24.60200@myri.com>
References: <1353114559.10798.66.camel@edumazet-glaptop> <20121119.191002.1995098917961576324.davem@davemloft.net> <50B3850C.4070902@myri.com> <20121128.114602.1208211617672057364.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	herbert@gondor.hengli.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:43944 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752975Ab2K1RaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 12:30:17 -0500
Received: by mail-yh0-f46.google.com with SMTP id m54so1567346yhm.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 09:30:15 -0800 (PST)
In-Reply-To: <20121128.114602.1208211617672057364.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/12 11:46, David Miller wrote:
> From: Andrew Gallatin <gallatin@myri.com>
> Date: Mon, 26 Nov 2012 10:04:44 -0500
>
>> How do you feel about the patchset I posted on 11/14/2012
>> ([PATCH net-next 0/3] myri10ge: LRO to GRO conversion,
>> http://marc.info/?l=linux-netdev&m=135289838223920&w=2)
>> which moves myri10ge from LRO to GRO?
>>
>> Specifically, if doing vlan decap in GRO is not OK, then how
>> about doing it in the driver?
>
> I'm going to trust Eric's judgment on this one, as he has been
> thinking more about the long term GRO issues than I have.
>
> Thanks.
>

Perfect, thanks.  Eric seemed OK with doing the vlan decap
in the driver.  But.. I didn't get an "nack" or an "applied" from
you in response to that myri10ge patchset.  Do I need to re-submit it?

Sorry, I'm not terribly familiar with the etiquette for this sort
of thing.

Thanks,

Drew
