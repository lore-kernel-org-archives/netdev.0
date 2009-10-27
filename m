From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH 2/6] net: Introduce unregister_netdevice_many()
Date: Tue, 27 Oct 2009 19:26:41 +0200
Message-ID: <200910271926.41734.opurdila@ixiacom.com>
References: <4AE72813.5080709@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:11839 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753211AbZJ0R3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 13:29:35 -0400
In-Reply-To: <4AE72813.5080709@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 27 October 2009 19:04:19 you wrote:

> +void unregister_netdevice_many(struct list_head *head)
> +{
> +       struct net_device *dev;
> +
> +       if (!list_empty(head)) {
> +               rollback_registered_many(head);
> +               list_for_each_entry(dev, head, unreg_list)
> +                       net_set_todo(dev);
> +       }
> +}
> 

Looks like EXPORT_SYMBOL(unregister_netdevice_many) is missing?

Thanks,
tavi
