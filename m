From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] myri10ge: correctly detect when TSO should be used
Date: Wed, 28 Mar 2007 02:19:44 -0400
Message-ID: <460A0900.1030609@garzik.org>
References: <46097617.8050407@myri.com> <4609768D.8020309@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42344 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933618AbXC1GTq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 02:19:46 -0400
In-Reply-To: <4609768D.8020309@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> Correctly detect when TSO should be used on transmit by looking at the
> skb->gso_size rather than seeing if the frame was larger than our MTU.
> The old method causes problems when a host with a large (jumbo) MTU is
> sending to a host with a small (standard) MTU.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |    7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)

applied to #upstream-fixes


