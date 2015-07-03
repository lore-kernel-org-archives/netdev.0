From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 3/6] net_sched: act: make tcfg_pval non zero
Date: Fri, 03 Jul 2015 06:49:08 -0400
Message-ID: <559668A4.5040604@mojatatu.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com> <1435842455-30501-4-git-send-email-edumazet@google.com>
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
Received: from mail-ig0-f182.google.com ([209.85.213.182]:38500 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932093AbbGCKtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 06:49:10 -0400
Received: by igrv9 with SMTP id v9so75063317igr.1
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2015 03:49:10 -0700 (PDT)
In-Reply-To: <1435842455-30501-4-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/15 09:07, Eric Dumazet wrote:
> First step for gact RCU operation :
>
> Instead of testing if tcfg_pval is zero or not, just make it 1.
>
> No change in behavior, but slightly faster code.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
