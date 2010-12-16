From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] ifb: fix a lockdep splat
Date: Thu, 16 Dec 2010 18:00:50 +0800
Message-ID: <AANLkTinbeR68+BsHYC-0yMAkbZ20TS1EiSg=cGHKQ-f2@mail.gmail.com>
References: <1292493175.2883.56.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:34799 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754170Ab0LPKBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 05:01:12 -0500
Received: by fxm18 with SMTP id 18so3066854fxm.2
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 02:01:10 -0800 (PST)
In-Reply-To: <1292493175.2883.56.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 5:52 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> After recent ifb changes, we must use lockless __skb_dequeue() since
> lock is not anymore initialized.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jamal Hadi Salim <hadi@cyberus.ca>
> Cc: Changli Gao <xiaosuo@gmail.com>

Acked-by: Changli Gao <xiaosuo@gmail.com>

Then, I have to refine my patch series. Thanks.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
