From: Jamal Hadi Salim <hadi@mojatatu.com>
Subject: Re: [PATCH v3] sch_htb: let skb->priority refer to non-leaf class
Date: Wed, 22 Jan 2014 07:41:45 -0500
Message-ID: <CAAFAkD-kAVH=oObrD+d_Uw9otV9YPcvVo94+1UM_CBo3J1qSyA@mail.gmail.com>
References: <1389953999.4698.18.camel@azathoth.dev.smoothwall.net>
 <52D927CD.4080403@cogentembedded.com> <1389964952.4698.20.camel@azathoth.dev.smoothwall.net>
 <20140121.143641.295542315649549669.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: harry.mason@smoothwall.net, sergei.shtylyov@cogentembedded.com,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f177.google.com ([209.85.220.177]:57616 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755154AbaAVMmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 07:42:06 -0500
Received: by mail-vc0-f177.google.com with SMTP id if11so177015vcb.8
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 04:42:05 -0800 (PST)
In-Reply-To: <20140121.143641.295542315649549669.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks reasonable from my view.

cheers,
jamal

On Tue, Jan 21, 2014 at 5:36 PM, David Miller <davem@davemloft.net> wrote:
> From: Harry Mason <harry.mason@smoothwall.net>
> Date: Fri, 17 Jan 2014 13:22:32 +0000
>
>> If the class in skb->priority is not a leaf, apply filters from the
>> selected class, not the qdisc. This lets netfilter or user space
>> partially classify the packet.
>>
>> Signed-off-by: Harry Mason <harry.mason@smoothwall.net>
>
> Can I please get some reviews of this patch?
>
> Thanks.
