From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/1] RFC: poll/select performance on datagram sockets
Date: Fri, 29 Oct 2010 13:40:58 -0700 (PDT)
Message-ID: <20101029.134058.246543591.davem@davemloft.net>
References: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>
	<1288380431.2680.3.camel@edumazet-laptop>
	<alpine.LNX.2.00.1010292217390.24561@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, alban.crequy@collabora.co.uk,
	shemminger@vyatta.com, gorcunov@openvz.org, adobriyan@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pauli.nieminen@collabora.co.uk, rweikusat@mssgmbh.com
To: jj@chaosbits.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46255
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761845Ab0J2Ukf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 16:40:35 -0400
In-Reply-To: <alpine.LNX.2.00.1010292217390.24561@swampdragon.chaosbits.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Juhl <jj@chaosbits.net>
Date: Fri, 29 Oct 2010 22:20:12 +0200 (CEST)

> Sorry to intrude out of the blue without really understanding the kernel 
> side of most of the code in question, but if there's a performance 
> regression for applications using poll() shouldn't we address that so we 
> get back to the prior performance level rather than requireing all 
> userspace apps to switch to epoll() ??

For such a pathological program like Alban's test case, I say
absolutely not.
