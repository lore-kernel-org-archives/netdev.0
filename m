From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 1/2] net: pktgen: support injecting packets for
 qdisc testing
Date: Fri, 1 Jul 2016 08:56:11 -0400
Message-ID: <5776686B.5090204@mojatatu.com>
References: <20160629194731.14745.20562.stgit@john-Precision-Tower-5810>
 <5774F2A6.3020308@mojatatu.com> <57754E6E.8010602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36425 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbcGANLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 09:11:16 -0400
Received: by mail-it0-f66.google.com with SMTP id h190so2169218ith.3
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 06:11:16 -0700 (PDT)
In-Reply-To: <57754E6E.8010602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-30 12:53 PM, John Fastabend wrote:
> On 16-06-30 03:21 AM, Jamal Hadi Salim wrote:
>> On 16-06-29 03:47 PM, John Fastabend wrote:

>
> Taking a look at the link couple differences exist. First the patch
> linked does a 'netif_xmit_frozen_or_drv_stopped(txq)' check but this
> really shouldn't be needed it is handled by the sch_direct_xmit()
> logic in ./net/sched
>
> Also in this patch I made it way more conservative on when to back
> off then my original patch and now its closer to the one linked except
> I also back off with return code NET_XMIT_CN.
>
> As for clones what is the concern exactly? We allow them through the
> ingress pktgen mode that can hit classifiers and I don't see any issues
> testing with them.
>

I sent you that because we discussed back then and you thought
there was something different and useful.
I dont remember why it was important to avoid clones - maybe i had a
bug. I thought we discussed it (I will try to dig into the machine
used for testing).
Anyways, doesnt matter if you tested and it works fine.

cheers,
jamal
