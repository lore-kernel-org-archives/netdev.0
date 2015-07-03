From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 5/6] net_sched: act: read tcfg_ptype once
Date: Fri, 03 Jul 2015 06:57:37 -0400
Message-ID: <55966AA1.1050309@mojatatu.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com> <1435842455-30501-6-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:33271 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754903AbbGCK5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 06:57:41 -0400
Received: by igcur8 with SMTP id ur8so141388324igc.0
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2015 03:57:40 -0700 (PDT)
In-Reply-To: <1435842455-30501-6-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/15 09:07, Eric Dumazet wrote:
> Third step for gact RCU operation :
>
> Following patch will get rid of spinlock protection,
> so we need to read tcfg_ptype once.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>


Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
