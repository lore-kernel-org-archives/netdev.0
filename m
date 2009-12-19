From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: fix net.ipv6.route.gc_min_interval_ms in netns
Date: Fri, 18 Dec 2009 20:11:30 -0800 (PST)
Message-ID: <20091218.201130.115932989.davem@davemloft.net>
References: <b6fcc0a0912180616m54c0d25dn56f008c9d736e505@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33213
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754614AbZLSEL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 23:11:28 -0500
In-Reply-To: <b6fcc0a0912180616m54c0d25dn56f008c9d736e505@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 18 Dec 2009 16:16:40 +0200

>     netns: fix net.ipv6.route.gc_min_interval_ms in netns
> 
>     sysctl table was copied, all right, but ->data for
> net.ipv6.route.gc_min_interval_ms
>     was not reinitialized for "!= &init_net" case.
> 
>     In init_net everthing works by accident due to correct ->data initialization
>     in source table.
> 
>     Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thank you.
