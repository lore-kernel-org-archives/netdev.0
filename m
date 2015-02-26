From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] rhashtable: use cond_resched()
Date: Thu, 26 Feb 2015 16:50:15 +0100
Message-ID: <54EF40B7.8060903@iogearbox.net>
References: <CAADnVQKV8JSqhTPYBGDJt4KqTesEvtCMnhupiPyZJjvk=tmOwg@mail.gmail.com>	 <20150226075354.GA30061@acer.localdomain>	 <1424962236.5565.156.camel@edumazet-glaptop2.roam.corp.google.com> <1424964034.5565.162.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	David Laight <David.Laight@aculab.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58451 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748AbbBZPu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 10:50:29 -0500
In-Reply-To: <1424964034.5565.162.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/2015 04:20 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> If a hash table has 128 slots and 16384 elems, expand to 256 slots
> takes more than one second. For larger sets, a soft lockup is detected.
>
> Holding cpu for that long, even in a work queue is a show stopper
> for non preemptable kernels.
>
> cond_resched() at strategic points to allow process scheduler
> to reschedule us.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
