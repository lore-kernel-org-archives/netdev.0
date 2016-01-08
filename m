From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] net, sched: add clsact qdisc
Date: Thu, 07 Jan 2016 16:01:19 -0800
Message-ID: <1452211279.8255.221.camel@edumazet-glaptop2.roam.corp.google.com>
References: <61198814638d88ce3555dbecf8ef875523b95743.1452197856.git.daniel@iogearbox.net>
	 <568EF308.1060505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	alexei.starovoitov@gmail.com, jhs@mojatatu.com,
	netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34221 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061AbcAHABV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 19:01:21 -0500
Received: by mail-pf0-f170.google.com with SMTP id q63so827237pfb.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 16:01:21 -0800 (PST)
In-Reply-To: <568EF308.1060505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-01-07 at 15:21 -0800, John Fastabend wrote:
>  Further we can build interesting queue
> select logic now and maybe remove select_queue() from the ndo ops
> eventually? With this and xps there really is no reason to have drivers
> implementing some under-the-covers logic anymore.

I guess you missed the "hv_netvsc: don't make assumptions on struct
flow_keys layout" thread today ;)
