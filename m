From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH] [NETNS] Remove unused member (dst_net) of dst_ops.
Date: Fri, 08 Feb 2008 14:36:14 +0300
Message-ID: <1202470574.31674.24.camel@iris.sw.ru>
References: <eb3ff54b0802080324i4c7df923y3476faa34392279a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	dlezcano@fr.ibm.com
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:33281 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762799AbYBHLg1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2008 06:36:27 -0500
In-Reply-To: <eb3ff54b0802080324i4c7df923y3476faa34392279a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This has been added by the Daniel Lezcano <dlezcano@fr.ibm.com> in the
commit d4fa26ff44e31c2636a985e3092e2cd55d8045de. It looks to me a
preparatory staff for IPv6 namespacing.

I think this is not needed in 2.6.25  but will be required in 2.6.26
very soon.

Regards,
	Den

On Fri, 2008-02-08 at 13:24 +0200, Rami Rosen wrote:
> Hi,
>   This patches removes dst_net member (a pointer to struct net)
>   of dst_ops (/include/net/dst.h).
> 	
>   Current network namespace implementation does not use it at all.
> 
> Denis - any comments ?
> 	
> 
> Regards,
> Rami Rosen
> 
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

