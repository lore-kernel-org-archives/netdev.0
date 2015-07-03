From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 4/6] net_sched: act: use a separate packet counters
 for gact_determ()
Date: Fri, 03 Jul 2015 06:50:05 -0400
Message-ID: <559668DD.7060209@mojatatu.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com> <1435842455-30501-5-git-send-email-edumazet@google.com>
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
Received: from mail-ie0-f169.google.com ([209.85.223.169]:36139 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754800AbbGCKuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 06:50:08 -0400
Received: by iecvh10 with SMTP id vh10so74645541iec.3
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2015 03:50:07 -0700 (PDT)
In-Reply-To: <1435842455-30501-5-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/15 09:07, Eric Dumazet wrote:
> Second step for gact RCU operation :
>
> We want to get rid of the spinlock protecting gact operations.
> Stats (packets/bytes) will soon be per cpu.
>
> gact_determ() would not work without a central packet counter,
> so lets add it for this mode.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>


Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
