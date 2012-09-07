From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH 1/2] dst: take into account policy update on check()
Date: Fri, 07 Sep 2012 17:13:35 +0200
Message-ID: <504A0F1F.5060504@6wind.com>
References: <5049FAE3.2050403@6wind.com>  <1347033467-3757-1-git-send-email-nicolas.dichtel@6wind.com>  <1347033467-3757-2-git-send-email-nicolas.dichtel@6wind.com>  <1347028510.2484.736.camel@edumazet-glaptop>  <504A08EA.3080506@6wind.com> <1347030598.2484.777.camel@edumazet-glaptop>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vyasevich@gmail.com, davem@davemloft.net, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:45978 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754991Ab2IGPNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 11:13:40 -0400
Received: by eekc1 with SMTP id c1so1231339eek.19
        for <netdev@vger.kernel.org>; Fri, 07 Sep 2012 08:13:38 -0700 (PDT)
In-Reply-To: <1347030598.2484.777.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/09/2012 17:09, Eric Dumazet a =C3=A9crit :
> On Fri, 2012-09-07 at 16:47 +0200, Nicolas Dichtel wrote:
>> Le 07/09/2012 16:35, Eric Dumazet a =C3=A9crit :
>>>
>>> Hmm... cant we reuse rt_genid ?
>>>
>>> (When changing flow_cache_genid, change &net->ipv4.rt_genid)
>>
>> And so adding a new field in net->ipv6?
>
> or move net->ipv4.rt_genid to net->rt_genid
>
> Having separate field for IPv4/IPv6 is of little interest IMHO
>
Ok, I will wait feedback from other people and repost a patch after.
