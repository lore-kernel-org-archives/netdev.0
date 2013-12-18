From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 8/8] net_sched: convert tcf_proto_ops to use
 struct list_head
Date: Wed, 18 Dec 2013 09:41:51 -0500
Message-ID: <52B1B42F.8080003@mojatatu.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com> <1387167311-14763-9-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:58280 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754301Ab3LROlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 09:41:52 -0500
Received: by mail-ig0-f175.google.com with SMTP id j1so9243491iga.2
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 06:41:52 -0800 (PST)
In-Reply-To: <1387167311-14763-9-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/13 23:15, Cong Wang wrote:
> We don't need to maintain our own singly linked list code.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>   include/net/sch_generic.h |  2 +-
>   net/sched/cls_api.c       | 18 ++++++++----------
>   2 files changed, 9 insertions(+), 11 deletions(-)
>

And another nice improvement. Thanks Cong

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
