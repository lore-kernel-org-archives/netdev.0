From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next 7/7] net_sched: act_mirred: remove spinlock
 in fast path
Date: Mon, 06 Jul 2015 11:29:57 -0700
Message-ID: <559AC925.3020703@plumgrid.com>
References: <1436185089-18268-1-git-send-email-edumazet@google.com> <1436185089-18268-8-git-send-email-edumazet@google.com>
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
Received: from mail-pd0-f175.google.com ([209.85.192.175]:36108 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbbGFSaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 14:30:00 -0400
Received: by pddu5 with SMTP id u5so22757438pdd.3
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 11:30:00 -0700 (PDT)
In-Reply-To: <1436185089-18268-8-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/6/15 5:18 AM, Eric Dumazet wrote:
> Like act_gact, act_mirred can be lockless in packet processing
>
> 1) Use percpu stats
> 2) update lastuse only every clock tick to avoid false sharing
> 3) use rcu to protect tcfm_dev
> 4) Remove spinlock usage, as it is no longer needed.
>
> Next step : add multi queue capability to ifb device
>
> Signed-off-by: Eric Dumazet<edumazet@google.com>

Nice!
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
