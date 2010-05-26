From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [PATCH] r8169: Add counters tx_bytes and rx_bytes for ethtool
Date: Wed, 26 May 2010 08:51:45 +0800
Message-ID: <AANLkTik1HW2d-2w-O_kw6NdwEmkJfFvpYYDwaFP3CLfY@mail.gmail.com>
References: <AANLkTimRwNqPYh1MgXPhh3hHep7Koc3OJCCroEj_scqg@mail.gmail.com>
	 <20100525.161539.104072714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:61564 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800Ab0EZAvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 20:51:46 -0400
Received: by pxi18 with SMTP id 18so2230368pxi.19
        for <netdev@vger.kernel.org>; Tue, 25 May 2010 17:51:45 -0700 (PDT)
In-Reply-To: <20100525.161539.104072714.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,
Thanks for your advice.

>
> If the problem is that people want 64-bit counters available for core
> statistics on 32-bit systems, we do not fix that problem by hacking
> every single driver to provide them side-band via ethtool.

Most NICs have provided those two 64-bit counters in hardware. They
work fine even in 32-bit systems and don't need new 64-bit counters
any more. Frankly, r8169 is the first Gbps NIC I have seen that does
not support those two counters. So I thought changing upper layer is
immoderate and tried to provide a cheap but valuable way.

>
> First of all, we now have "struct rtnl_link_stats64" in
> linux/if_link.h, it's there to start combating this problem
> generically, for every device, rather than the way you are trying
> handle it only for one specific driver at a time.

Thanks for your advice. I'll go deep into it and see how we can solve
this problem.


-- 
--Junchang
