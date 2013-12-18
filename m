From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 6/8] net_sched: convert tcf_hashinfo to hlist
 and use spinlock
Date: Wed, 18 Dec 2013 09:38:43 -0500
Message-ID: <52B1B373.7020901@mojatatu.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com> <1387167311-14763-7-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:63718 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754310Ab3LROip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 09:38:45 -0500
Received: by mail-ig0-f169.google.com with SMTP id hk11so9184819igb.0
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 06:38:45 -0800 (PST)
In-Reply-To: <1387167311-14763-7-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/13 23:15, Cong Wang wrote:
> So that we don't need to play with singly linked list,
> and since the code is not on hot path, we can use spinlock
> instead of rwlock.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

nice.

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
