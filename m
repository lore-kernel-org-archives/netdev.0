From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH net] ipv4: add a sock pointer to ip_queue_xmit() and friends
Date: Mon, 21 Apr 2014 21:20:44 +0800
Message-ID: <CADvbK_dbA_2XPcYNDgEmBQTGZ9MK683cnbaC0w8Yz3WYaTwibQ@mail.gmail.com>
References: <1397502396.4222.45.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140414.152225.1983723140136958968.davem@davemloft.net>
	<1397510604.4222.63.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140414.185152.204599887297456936.davem@davemloft.net>
	<1397520840.4222.65.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHz2CGW_Eh5P_Z4=a-tfnp-S_62bZRXk2pLxes7ufEdfr0hwAQ@mail.gmail.com>
	<1397572392.4222.93.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Zhan Jianyu <nasa4836@gmail.com>,
	David Miller <davem@davemloft.net>,
	James Chapman <jchapman@katalix.com>,
	network dev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:57868 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbaDUNUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 09:20:46 -0400
Received: by mail-wi0-f176.google.com with SMTP id r20so1795118wiv.3
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 06:20:44 -0700 (PDT)
In-Reply-To: <1397572392.4222.93.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 15, 2014 at 10:33 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Reported-by: Zhan Jianyu <nasa4836@gmail.com>
> Tested-by: Zhan Jianyu <nasa4836@gmail.com>
> Reported-by: lucien xin <lucien.xin@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: James Chapman <jchapman@katalix.com>
> Fixes: 31c70d5956fc ("l2tp: keep original skb ownership")
> Fixes: 8f646c922d55 ("vxlan: keep original skb ownership")
> ---
>
> David, you asked me to take care of both problems, I now realize the two
> patches are not in the same linux version, so it might be needed to
> split in two separate patches to ease backport.
>
> Lucien, can you test this patch solves the problem you reported ?
>

sorry for late,  I have tested vxlan dhclient with the patch, no WARN().

thanks,
