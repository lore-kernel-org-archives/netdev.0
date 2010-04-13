From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: batch skb dequeueing from softnet input_pkt_queue
Date: Tue, 13 Apr 2010 13:19:04 +0800
Message-ID: <t2h412e6f7f1004122219p91bf4df5hf6ec06df5ff0f09d@mail.gmail.com>
References: <1271155268-2999-1-git-send-email-xiaosuo@gmail.com>
	<20100412.214453.57473458.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f178.google.com ([209.85.223.178]:32982 "EHLO
	mail-iw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389Ab0DMFTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 01:19:24 -0400
Received: by iwn8 with SMTP id 8so4838710iwn.16
        for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 22:19:24 -0700 (PDT)
In-Reply-To: <20100412.214453.57473458.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 13, 2010 at 12:44 PM, David Miller <davem@davemloft.net> wrote:
> From: Changli Gao <xiaosuo@gmail.com>
> Date: Tue, 13 Apr 2010 18:41:08 +0800
>
>> batch skb dequeueing from softnet input_pkt_queue to reduce potential lock
>> contention and irq disabling/enabling.
>
> In exchange for a bunch of new atomic operations.
>
> No, thanks.
>

Oh, I can eliminate atomic operations totally, if I use another
variable instead. I'll submit another version later.
