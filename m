From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] pkt_sched: add cond_resched() to class and
 qdisc dump
Date: Mon, 10 Mar 2014 17:30:40 -0700
Message-ID: <1394497840.21721.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1394496703-9278-1-git-send-email-edumazet@google.com>
	 <1394496703-9278-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:42201 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602AbaCKAam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 20:30:42 -0400
Received: by mail-pa0-f46.google.com with SMTP id kp14so8058752pab.33
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 17:30:42 -0700 (PDT)
In-Reply-To: <1394496703-9278-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 17:11 -0700, Eric Dumazet wrote:
> We have seen delays of more than 50ms in class or qdisc dumps, in case
> device is under high TX stress, even with the prior 4KB per skb limit.
> 
> Add cond_resched() to give a chance to higher prio tasks to get cpu.
> 
> Signed-off-by; Eric Dumazet <edumazet@google.com>

Gosh I managed to mess this SOB :(

Signed-off-by: Eric Dumazet <edumazet@google.com>
