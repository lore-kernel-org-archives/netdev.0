From: Aaron Conole <aconole@redhat.com>
Subject: Re: pull-request: wireless-drivers-next 2016-09-29
Date: Fri, 30 Sep 2016 09:30:40 -0400
Message-ID: <f7t4m4xtszj.fsf@redhat.com>
References: <87ponmve2v.fsf@kamboji.qca.qualcomm.com>
        <20160930.013245.1474369794552343595.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36748 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932694AbcI3Nao (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Sep 2016 09:30:44 -0400
In-Reply-To: <20160930.013245.1474369794552343595.davem@davemloft.net> (David
        Miller's message of "Fri, 30 Sep 2016 01:32:45 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Kalle Valo <kvalo@codeaurora.org>
> Date: Thu, 29 Sep 2016 19:57:28 +0300
>
...
>> Or actually I had one problem. While doing a test merge I noticed that
>> net-next fails to compile for me, but I don't think this is anything
>> wireless related:
>> 
>>   CC      net/netfilter/core.o
>> net/netfilter/core.c: In function 'nf_set_hooks_head':
>> net/netfilter/core.c:96:149: error: 'struct net_device' has no
>> member named 'nf_hooks_ingress'
>
> Yes, I am aware of this build issue and will tackle it myself if someone
> doesn't beat me to it.

Sorry, I introduced this.  I posted a series targetted at nf-next to
solve this, but it could be merged to net-next instead, if that makes
sense.

The patches are here:

https://patchwork.ozlabs.org/patch/676287/
https://patchwork.ozlabs.org/patch/676288/


Again, sorry for this.
