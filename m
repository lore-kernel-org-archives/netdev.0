From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 6/6] net_sched: act: remove spinlock in fast
 path
Date: Thu, 02 Jul 2015 10:13:22 -0700
Message-ID: <55957132.1020201@plumgrid.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com> <1435842455-30501-7-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34827 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753616AbbGBRNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 13:13:23 -0400
Received: by pactm7 with SMTP id tm7so43355541pac.2
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 10:13:23 -0700 (PDT)
In-Reply-To: <1435842455-30501-7-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/2/15 6:07 AM, Eric Dumazet wrote:
> Final step for gact RCU operation :
>
> 1) Use percpu stats
> 2) update lastuse only every clock tick
> 3) Remove spinlock acquisition, as it is no longer needed.
>
> Since this is the last contended lock in packet RX when tc gact is used,
> this gives impressive gain.
>
> My host with 8 RX queues was handling 5 Mpps before the patch,
> and more than 10 Mpps after patch.
>
> Signed-off-by: Eric Dumazet<edumazet@google.com>

Great stuff. Thank you for fixing it!

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
