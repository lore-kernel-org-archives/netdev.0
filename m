From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 2/8] net_sched: act: use standard struct list_head
Date: Wed, 18 Dec 2013 09:22:40 -0500
Message-ID: <52B1AFB0.6060906@mojatatu.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com> <1387167311-14763-3-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:39381 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754861Ab3LROWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 09:22:42 -0500
Received: by mail-ig0-f169.google.com with SMTP id hk11so9149833igb.0
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 06:22:42 -0800 (PST)
In-Reply-To: <1387167311-14763-3-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/13 23:15, Cong Wang wrote:
> Currently actions are chained by a singly linked list,
> therefore it is a bit hard to add and remove a specific
> entry. Convert it to struct list_head so that in the
> latter patch we can remove an action without finding
> its head.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>


Look good, thanks.

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
