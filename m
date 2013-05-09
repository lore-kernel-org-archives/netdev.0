From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH nf-next] netfilter: conntrack: remove the central spinlock
Date: Thu, 9 May 2013 05:43:57 +0000 (UTC)
Message-ID: <kmfd2s$e2m$1@ger.gmane.org>
References: <1368068665.13473.81.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:40487 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750724Ab3EIFoO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 May 2013 01:44:14 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UaJeG-0004Hh-P6
	for netdev@vger.kernel.org; Thu, 09 May 2013 07:44:12 +0200
Received: from 116.53.101.117 ([116.53.101.117])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 09 May 2013 07:44:12 +0200
Received: from xiyou.wangcong by 116.53.101.117 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 09 May 2013 07:44:12 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 09 May 2013 at 03:04 GMT, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>  
> +#if 0
> +	for (i = 0; i < ARRAY_SIZE(nf_conntrack_locks); i++)
> +		arch_spin_lock_init(&nf_conntrack_locks[i]);
> +#endif
> +

Is this intentional?
