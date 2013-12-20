From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: fix a regression in tc actions
Date: Fri, 20 Dec 2013 07:15:54 -0500
Message-ID: <52B434FA.8080309@mojatatu.com>
References: <1387526931-21814-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:39456 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932130Ab3LTMP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 07:15:57 -0500
Received: by mail-ie0-f174.google.com with SMTP id at1so2941135iec.33
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 04:15:56 -0800 (PST)
In-Reply-To: <1387526931-21814-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/13 03:08, Cong Wang wrote:
> This patch fixes:
> 1) pass mask rather than size to tcf_hashinfo_init()
> 2) the cleanup should be in reversed order in mirred_cleanup_module()
>
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Fixes: 369ba56787d7469c0afd ("net_sched: init struct tcf_hashinfo at register time")
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>

Please Cc me - my filters will catch it faster.

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
