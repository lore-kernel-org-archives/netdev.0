From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH net-next] ipv6: trival improvements
Date: Fri, 20 Dec 2013 09:01:22 +0800
Message-ID: <CAJFZqHz_tvawRCuCqPLRDrEPz-Q-AH-gnOcSUX_tfgU=gHuD=Q@mail.gmail.com>
References: <1387433932-2745-1-git-send-email-roy.qing.li@gmail.com>
	<20131219.144550.1168547541317435358.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f49.google.com ([209.85.212.49]:48823 "EHLO
	mail-vb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756831Ab3LTBBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 20:01:23 -0500
Received: by mail-vb0-f49.google.com with SMTP id x11so1065988vbb.36
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 17:01:22 -0800 (PST)
In-Reply-To: <20131219.144550.1168547541317435358.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 3:45 AM, David Miller <davem@davemloft.net> wrote:
> From: roy.qing.li@gmail.com
> Date: Thu, 19 Dec 2013 14:18:52 +0800
>
>> From: Li RongQing <roy.qing.li@gmail.com>
>>
>> 1. remove the unnecessary setting rt.rt6i_metric to 0 since memset() has clear
>> them.
>> 2. call ip6_rt_put to release rt only when rt is not null in addrconf_prefix_rcv.
>>
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>
> ip6_rt_put() transparently handles NULL just fine, don't special
> case it like this.

Yes, ip6_rt_put() can handles NULL, but this change can free cpu to do judgement
one time if rt is NULL.

Thanks

-Roy
