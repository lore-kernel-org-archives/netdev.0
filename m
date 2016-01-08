From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next v2] net, sched: add clsact qdisc
Date: Thu, 07 Jan 2016 17:03:36 -0800
Message-ID: <568F0AE8.9060408@gmail.com>
References: <61198814638d88ce3555dbecf8ef875523b95743.1452197856.git.daniel@iogearbox.net>	 <568EF308.1060505@gmail.com> <1452211279.8255.221.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	alexei.starovoitov@gmail.com, jhs@mojatatu.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36587 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbcAHBDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 20:03:50 -0500
Received: by mail-pa0-f47.google.com with SMTP id yy13so179767953pab.3
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 17:03:50 -0800 (PST)
In-Reply-To: <1452211279.8255.221.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-01-07 04:01 PM, Eric Dumazet wrote:
> On Thu, 2016-01-07 at 15:21 -0800, John Fastabend wrote:
>>  Further we can build interesting queue
>> select logic now and maybe remove select_queue() from the ndo ops
>> eventually? With this and xps there really is no reason to have drivers
>> implementing some under-the-covers logic anymore.
> 
> I guess you missed the "hv_netvsc: don't make assumptions on struct
> flow_keys layout" thread today ;)
> 
> 
> 

Ah thanks for the pointer. That seems a bit odd to me at least I can't
parse out what that table is useful for.

.John
