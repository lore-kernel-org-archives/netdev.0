From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v3 net-next 7/7] net_sched: act_mirred: remove spinlock
 in fast path
Date: Mon, 06 Jul 2015 08:53:43 -0400
Message-ID: <559A7A57.2000803@mojatatu.com>
References: <1436185089-18268-1-git-send-email-edumazet@google.com> <1436185089-18268-8-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:35705 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725AbbGFMxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 08:53:50 -0400
Received: by igcqs7 with SMTP id qs7so9106982igc.0
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 05:53:50 -0700 (PDT)
In-Reply-To: <1436185089-18268-8-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/06/15 08:18, Eric Dumazet wrote:
> Like act_gact, act_mirred can be lockless in packet processing
>
> 1) Use percpu stats
> 2) update lastuse only every clock tick to avoid false sharing
> 3) use rcu to protect tcfm_dev
> 4) Remove spinlock usage, as it is no longer needed.
>
> Next step : add multi queue capability to ifb device
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good to me ;->
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cant wait for the multi queue ifb.

cheers,
jamal
