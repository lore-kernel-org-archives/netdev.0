From: Salam Noureddine <noureddine@aristanetworks.com>
Subject: Re: [PATCH 1/1] ipv4: arp: update neighbour address when a gratuitous
 arp is received and arp_accept is set
Date: Wed, 1 Jan 2014 21:06:10 -0800
Message-ID: <CAO7SqHAKtoTr2VeE48dncfSB50cB9LEzp65abjeJuCSe0s6KLg@mail.gmail.com>
References: <1387923422-4247-1-git-send-email-noureddine@aristanetworks.com>
	<20140101.233834.1721631702711130638.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f172.google.com ([209.85.128.172]:46397 "EHLO
	mail-ve0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728AbaABFGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 00:06:11 -0500
Received: by mail-ve0-f172.google.com with SMTP id jw12so7241039veb.3
        for <netdev@vger.kernel.org>; Wed, 01 Jan 2014 21:06:10 -0800 (PST)
In-Reply-To: <20140101.233834.1721631702711130638.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch is against net-next, sorry forgot to mention it in the
subject. Hannes pointed changes made to arp.c in net-next so I
generated this patch accordingly.

Thanks,

Salam

On Wed, Jan 1, 2014 at 8:38 PM, David Miller <davem@davemloft.net> wrote:
> From: Salam Noureddine <noureddine@aristanetworks.com>
> Date: Tue, 24 Dec 2013 14:17:02 -0800
>
>> Gratuitous arp packets are useful in switchover scenarios to update
>> client arp tables as quickly as possible. Currently, the mac address
>> of a neighbour is only updated after a locktime period has elapsed
>> since the last update. In most use cases such delays are unacceptable
>> for network admins. Moreover, the "updated" field of the neighbour
>> stucture doesn't record the last time the address of a neighbour
>> changed but records any change that happens to the neighbour. This is
>> clearly a bug since locktime uses that field as meaning "addr_updated".
>> With this observation, I was able to perpetuate a stale address by
>> sending a stream of gratuitous arp packets spaced less than locktime
>> apart. With this change the address is updated when a gratuitous arp
>> is received and the arp_accept sysctl is set.
>>
>> Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>
>
> This patch doesn't apply, please regenerate this patch against current
> sources.
