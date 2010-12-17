From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-next-2.6] ifb: fix a lockdep splat
Date: Fri, 17 Dec 2010 08:09:58 -0500
Message-ID: <1292591398.2668.20.camel@mojatatu>
References: <1292493175.2883.56.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	changli Gao <xiaosuo@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:65097 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754120Ab0LQNJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 08:09:56 -0500
Received: by gxk19 with SMTP id 19so365334gxk.11
        for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 05:09:55 -0800 (PST)
In-Reply-To: <1292493175.2883.56.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-12-16 at 10:52 +0100, Eric Dumazet wrote:
> After recent ifb changes, we must use lockless __skb_dequeue() since
> lock is not anymore initialized.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jamal Hadi Salim <hadi@cyberus.ca>
> Cc: Changli Gao <xiaosuo@gmail.com>

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal

