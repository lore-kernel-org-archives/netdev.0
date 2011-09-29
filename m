From: Rongqing Li <rongqing.li@windriver.com>
Subject: Re: [PATCH] Ipv6: Delete rcu_read_lock
Date: Thu, 29 Sep 2011 16:49:07 +0800
Message-ID: <4E843103.2060609@windriver.com>
References: <1317282414-13368-1-git-send-email-rongqing.li@windriver.com> <1317285859.2855.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:61261 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754872Ab1I2ItL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 04:49:11 -0400
In-Reply-To: <1317285859.2855.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29/2011 04:44 PM, Eric Dumazet wrote:
> A good changelog and patch title are required.
>
> Something like :
>
> [PATCH net-next] ipv6: remove a rcu_read_lock in ndisc_constructor
>
> in6_dev_get(dev) takes a reference on struct inet6_dev, we dont need rcu
> locking in ndisc_constructor()
>
>

Thank you, I will resend it.

-Roy
