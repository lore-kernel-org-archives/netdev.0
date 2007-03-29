From: "=?ISO-8859-2?Q?Marcin_=A6lusarz?=" <marcin.slusarz@gmail.com>
Subject: Re: [KJ] Patch:replace with time_after in drivers/net/eexpress.c
Date: Thu, 29 Mar 2007 20:41:19 +0200
Message-ID: <4bacf17f0703291141n4b485e80m98be0aaecf1ec81d@mail.gmail.com>
References: <1175058871.11584.33.camel@shani-win>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: philb@gnu.org, alan@redhat.com, netdev@vger.kernel.org,
	kernel-janitors@osdl.org, jeff@garzik.org
To: Shani <shani.moideen@wipro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.228]:24838 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934314AbXC2SlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 14:41:22 -0400
Received: by hu-out-0506.google.com with SMTP id 36so12604299hui
        for <netdev@vger.kernel.org>; Thu, 29 Mar 2007 11:41:20 -0700 (PDT)
In-Reply-To: <1175058871.11584.33.camel@shani-win>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/3/28, Shani <shani.moideen@wipro.com>:
> @@ -1650,7 +1651,7 @@ eexp_set_multicast(struct net_device *dev)
>  #endif
>                  oj = jiffies;
>                  while ((SCB_CUstat(scb_status(dev)) == 2) &&
> -                       ((jiffies-oj) < 2000));
> +                       (time_after(jiffies, oj + 2000)));
>                 if (SCB_CUstat(scb_status(dev)) == 2)
>                         printk("%s: warning, CU didn't stop\n", dev->name);
>                  lp->started &= ~(STARTED_CU);
>
it should be time_before, not time_after...
