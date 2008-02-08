From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH] [NETNS] Remove unused member (dst_net) of dst_ops.
Date: Fri, 08 Feb 2008 13:33:49 +0100
Message-ID: <47AC4C2D.1030500@fr.ibm.com>
References: <eb3ff54b0802080324i4c7df923y3476faa34392279a@mail.gmail.com> <1202470574.31674.24.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rami Rosen <ramirose@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:32104 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988AbYBHMjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 07:39:54 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m18CdpAn125544
	for <netdev@vger.kernel.org>; Fri, 8 Feb 2008 12:39:51 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m18CdoXN2068484
	for <netdev@vger.kernel.org>; Fri, 8 Feb 2008 13:39:50 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m18CdoDK017986
	for <netdev@vger.kernel.org>; Fri, 8 Feb 2008 13:39:50 +0100
In-Reply-To: <1202470574.31674.24.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis V. Lunev wrote:
> This has been added by the Daniel Lezcano <dlezcano@fr.ibm.com> in the
> commit d4fa26ff44e31c2636a985e3092e2cd55d8045de. It looks to me a
> preparatory staff for IPv6 namespacing.
> 
> I think this is not needed in 2.6.25  but will be required in 2.6.26
> very soon.

Yes, this is right, I posted this one just before sending ipv6 routing.
Unfortunately, I posted ipv6 routing per namespace when net-2.6.25 closed.

We can remove it for net-2.6 and I can repost it for net-2.6.26, if you 
want. Or we can just keep it ...

   -- Daniel

ps : thanks Denis :)
