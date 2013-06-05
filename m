From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: tun: release the reference of tun device in
 tun_recvmsg
Date: Wed, 05 Jun 2013 08:36:46 -0700
Message-ID: <1370446606.24311.273.camel@edumazet-glaptop>
References: <201304250822.38944.a.miskiewicz@gmail.com>
	 <201305290029.35303.a.miskiewicz@gmail.com>
	 <51AC5345.6020904@cn.fujitsu.com>
	 <201306051720.15029.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Gao feng <gaofeng@cn.fujitsu.com>,
	Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	Balakumaran Kannan <kumaran.4353@gmail.com>,
	Maruthi Thotad <Maruthi.Thotad@ap.sony.com>,
	"David S. Miller" <davem@davemloft.net>
To: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:47140 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753743Ab3FEPgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 11:36:53 -0400
Received: by mail-pa0-f44.google.com with SMTP id wp1so1076552pac.3
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 08:36:53 -0700 (PDT)
In-Reply-To: <201306051720.15029.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-05 at 17:20 +0200, Arkadiusz Miskiewicz wrote:
> O
> Please push it into stable kernel (3.9) queue, too. Works well here.
> 

Its already in the queue :
http://patchwork.ozlabs.org/bundle/davem/stable/?state=*




> commit 534c877928a16ae5f9776436a497109639bf67dc
> Author: Gao feng <gaofeng@cn.fujitsu.com>
> Date:   Sun Jun 2 22:16:21 2013 +0000
> 
>     ipv6: assign rt6_info to inet6_ifaddr in init_loopback
>     
>     Commit 25fb6ca4ed9cad72f14f61629b68dc03c0d9713f
>     "net IPv6 : Fix broken IPv6 routing table after loopback down-up"
>     forgot to assign rt6_info to the inet6_ifaddr.
>     When disable the net device, the rt6_info which allocated
>     in init_loopback will not be destroied in __ipv6_ifa_notify.
>     
>     This will trigger the waring message below
>     [23527.916091] unregister_netdevice: waiting for tap0 to become free. 
> Usage count = 1
>     
>     Reported-by: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
>     Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
