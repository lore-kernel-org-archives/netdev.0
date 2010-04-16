From: Tom Herbert <therbert@google.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Thu, 15 Apr 2010 23:28:42 -0700
Message-ID: <z2g65634d661004152328hc72de2adgbeb20ec94af19b0@mail.gmail.com>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi> <4BC741AE.3000108@hp.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <o2v412e6f7f1004152302j1aca5edam9d53d01781ddbe9d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, hadi@cyberus.ca,
	Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	robert@herjulf.net, andi@firstfloor.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:19829 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754020Ab0DPG2r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 02:28:47 -0400
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o3G6Si1M006595
	for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 08:28:45 +0200
Received: from pvg4 (pvg4.prod.google.com [10.241.210.132])
	by kpbe17.cbf.corp.google.com with ESMTP id o3G6ShED009830
	for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 23:28:43 -0700
Received: by pvg4 with SMTP id 4so1624448pvg.37
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 23:28:43 -0700 (PDT)
In-Reply-To: <o2v412e6f7f1004152302j1aca5edam9d53d01781ddbe9d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> How do you wake up a thread on a remote cpu ?
>>
>
> resched IPI, apparently. But it is async absolutely. and its IRQ
> handler is lighter.
>
The IPI used in RPS is done asynchronously.

> --
> Regards=EF=BC=8C
> Changli Gao(xiaosuo@gmail.com)
>
