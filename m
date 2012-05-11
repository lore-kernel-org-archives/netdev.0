From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sch_htb: report backlog information in htb
 classes
Date: Sat, 12 May 2012 00:41:12 +0200
Message-ID: <1336776072.31653.298.camel@edumazet-glaptop>
References: <1336775494.31653.297.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:56493 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912Ab2EKWlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 18:41:18 -0400
Received: by wibhr2 with SMTP id hr2so2109346wib.1
        for <netdev@vger.kernel.org>; Fri, 11 May 2012 15:41:17 -0700 (PDT)
In-Reply-To: <1336775494.31653.297.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-05-12 at 00:31 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> htb classes at level 0 can copy their qdisc child backlog to provide to
> "tc -s class" users more relevant information. (packet counter is
> correct but byte counter (backlog) is 0)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/sched/sch_htb.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)

Please disregard this patch, more work is needed.

Thanks
