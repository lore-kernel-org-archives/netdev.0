From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ICMPv6 too big Packet will makes the network unreachable
Date: Tue, 13 Oct 2015 16:26:34 +0200
Message-ID: <1444746394.1871555.408986697.6F3FA822@webmail.messagingengine.com>
References: <CAJFZqHz93RmSp369W508i8zbDmxhohG9n4UfxG1TnSxDPD4B=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Li RongQing <roy.qing.li@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:53996 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932514AbbJMO0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 10:26:35 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 106FE20D1C
	for <netdev@vger.kernel.org>; Tue, 13 Oct 2015 10:26:35 -0400 (EDT)
In-Reply-To: <CAJFZqHz93RmSp369W508i8zbDmxhohG9n4UfxG1TnSxDPD4B=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 13, 2015, at 09:09, Li RongQing wrote:
> 4.  route information  will enter the faulty state after Wait 600
> seconds,
> 
>    root@du1:~# ip route get 2001:1b70:82a8:18:650:65:0:2
>    local 2001:1b70:82a8:18:650:65:0:2 dev lo  proto none  src
> 2001:1b70:82a8:18:650:65:0:2  metric 0  expires 7sec mtu 1280
> 
>    root@du1:~# ip route get 2001:1b70:82a8:18:650:65:0:2
>    local 2001:1b70:82a8:18:650:65:0:2 dev lo  proto none  src
> 2001:1b70:82a8:18:650:65:0:2  metric 0  expires 3sec mtu 1280
> 
>    root@du1:~# ip route get 2001:1b70:82a8:18:650:65:0:2
>    2001:1b70:82a8:18:650:65:0:2 dev eth10.650  src
> 2001:1b70:82a8:18:650:65:0:2  metric 0
>        cache
>    root@du1:~#

Which kernel version did you test this on?

Thanks,
Hannes
