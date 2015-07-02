From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 3/6] net_sched: act: make tcfg_pval non zero
Date: Thu, 02 Jul 2015 09:58:33 -0700
Message-ID: <55956DB9.60101@plumgrid.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com> <1435842455-30501-4-git-send-email-edumazet@google.com>
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
Received: from mail-pd0-f171.google.com ([209.85.192.171]:35198 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753834AbbGBQ6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 12:58:34 -0400
Received: by pdbci14 with SMTP id ci14so48023340pdb.2
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 09:58:34 -0700 (PDT)
In-Reply-To: <1435842455-30501-4-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/2/15 6:07 AM, Eric Dumazet wrote:
> First step for gact RCU operation :
>
> Instead of testing if tcfg_pval is zero or not, just make it 1.
>
> No change in behavior, but slightly faster code.
>
> Signed-off-by: Eric Dumazet<edumazet@google.com>

Nice trick!
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
