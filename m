From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2 2/2] net/sched: fq_codel: Avoid
 set-but-unused variable
Date: Thu, 16 Mar 2017 05:28:09 -0700
Message-ID: <1489667289.28631.219.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1489661622-14498-1-git-send-email-ogerlitz@mellanox.com>
         <1489661622-14498-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33552 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752353AbdCPM2W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 08:28:22 -0400
Received: by mail-pg0-f67.google.com with SMTP id y17so5958118pgh.0
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 05:28:21 -0700 (PDT)
In-Reply-To: <1489661622-14498-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-16 at 12:53 +0200, Or Gerlitz wrote:
> The code introduced by commit 2ccccf5fb43f ("net_sched: update
> hierarchical backlog too") only sets prev_backlog in fq_codel_dequeue()
> but not using that anywhere, remove that setting.
> 
> Cc: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  net/sched/sch_fq_codel.c | 2 --
>  1 file changed, 2 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
