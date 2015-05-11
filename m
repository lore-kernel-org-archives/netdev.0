From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH] net: Fix ifdef typo in net_device definition
Date: Mon, 11 May 2015 20:39:07 +0200
Message-ID: <5550F74B.6030301@iogearbox.net>
References: <20150511183152.13432.73713.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40311 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752391AbbEKSjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 14:39:09 -0400
In-Reply-To: <20150511183152.13432.73713.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/11/2015 08:31 PM, Alexander Duyck wrote:
> While trying to build for some performance testing I received the error
> message below multiple times:
>
> include/linux/netdevice.h:1658:5: warning: "CONFIG_NET_CLS_ACT" is not defined [-Wundef]
>   #if CONFIG_NET_CLS_ACT
>
> It looks like this was just a typo and should have been "#ifdef" instead of
> "#if".
>
> Fixes: d2788d34885d4 ("net: sched: further simplify handle_ing")
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

It's already here, sorry for that:

   https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=4cda01e86f68dacc758b2daf6e8809f2ce915b85

Best,
Daniel
