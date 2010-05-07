From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH net-next-2.6] net: Increase NET_SKB_PAD to 64 bytes
Date: Fri, 07 May 2010 11:48:06 +0200
Message-ID: <4BE3E1D6.30907@monstr.eu>
References: <20100506.220221.90798296.davem@davemloft.net>	<1273209321.2222.36.camel@edumazet-laptop>	<4BE3C70C.4060705@monstr.eu> <20100507.013216.133893678.davem@davemloft.net>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, hadi@cyberus.ca,
	therbert@google.com, microblaze-uclinux@itee.uq.edu.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63998 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755562Ab0EGJsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 05:48:46 -0400
Received: by fxm10 with SMTP id 10so629152fxm.19
        for <netdev@vger.kernel.org>; Fri, 07 May 2010 02:48:44 -0700 (PDT)
In-Reply-To: <20100507.013216.133893678.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Michal Simek <monstr@monstr.eu>
> Date: Fri, 07 May 2010 09:53:48 +0200
> 
>> I will add this Microblaze patch to my repo for testing and anyway
>> should go through my repo.
> 
> It's already in the net-next-2.6 tree.

Anyway.

I am ok with removing NET_IP_ALIGN because it is already defined in 
skbuff.h to 2.
But increasing NET_SKB_PAD to 64 caused that Microblaze extends skb 
buffers for some bytes.
I measured it by iperf and netperf and I see regression around 1-2Mbit/s 
that's why I would like to ask you to revert this patch or keep at least 
NET_SKB_PAD part.

Thanks,
Michal

-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
