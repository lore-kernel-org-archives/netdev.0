From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/6] net: sched: extend percpu stats helpers
Date: Fri, 03 Jul 2015 06:44:34 -0400
Message-ID: <55966792.9020308@mojatatu.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com> <1435842455-30501-2-git-send-email-edumazet@google.com>
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
Received: from mail-ig0-f174.google.com ([209.85.213.174]:37778 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754673AbbGCKoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 06:44:37 -0400
Received: by igblr2 with SMTP id lr2so74855718igb.0
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2015 03:44:36 -0700 (PDT)
In-Reply-To: <1435842455-30501-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/15 09:07, Eric Dumazet wrote:
> qdisc_bstats_update_cpu() and other helpers were added to support
> percpu stats for qdisc.
>
> We want to add percpu stats for tc action, so this patch add common
> helpers.
>
> qdisc_bstats_update_cpu() is renamed to qdisc_bstats_cpu_update()
> qdisc_qstats_drop_cpu() is renamed to qdisc_qstats_cpu_drop()
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: John Fastabend <john.fastabend@gmail.com>


Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
