From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] ip_tunnel: Ops registration for secondary encap (fou, gue)
Date: Wed, 12 Nov 2014 12:07:19 -0800
Message-ID: <CA+mtBx9aXUxZZodQi=QcDx22EzeX+Ch2p1qnpT2w6F2jmou3GA@mail.gmail.com>
References: <1415822049-24978-1-git-send-email-therbert@google.com>
	<20141112.150349.1546991259336520485.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>, rdunlap@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:55480 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190AbaKLUHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 15:07:20 -0500
Received: by mail-ie0-f174.google.com with SMTP id x19so13928514ier.5
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 12:07:19 -0800 (PST)
In-Reply-To: <20141112.150349.1546991259336520485.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 12, 2014 at 12:03 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Wed, 12 Nov 2014 11:54:09 -0800
>
>> Instead of calling fou and gue functions directly from ip_tunnel
>> use ops for these that were previously registered. This patch adds the
>> logic to add and remove encapsulation operations for ip_tunnel,
>> and modified fou (and gue) to register with ip_tunnels.
>>
>> This patch also addresses a circular dependency between ip_tunnel
>> and fou that was causing link errors when CONFIG_NET_IP_TUNNEL=y
>> and CONFIG_NET_FOU=m. References to fou an gue have been removed from
>> ip_tunnel.c
>>
>> Reported-by: Randy Dunlap <rdunlap@infradead.org>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>
> Applied, please in the future be explicit about the target tree by
> saying "[PATCH net-next]" or similar in your Subj.
>
> I'm pretty sure this isn't the first time I've had to ask this of
> you. :-/
>
I was unsure which branch to target since the bug was reported in
linux-next. Is next-next appropriate in this case?

Thanks,
Tom

> Thanks Tom.
