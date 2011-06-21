From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] ss: fix autobound filter
Date: Tue, 21 Jun 2011 08:54:40 -0700
Message-ID: <20110621085440.691170a4@nehalam.ftrdhcpuser.net>
References: <1308316911.2780.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48494 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753509Ab1FUPyn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 11:54:43 -0400
In-Reply-To: <1308316911.2780.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Jun 2011 15:21:51 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Fixes following error. We currently provide garbage data to kernel, that
> can abort the validation process or produce unexpected results.
> 
> $ ss -a autobound
> State      Recv-Q Send-Q      Local Address:Port          Peer Address:Port   
> TCPDIAG answers: Invalid argument
> 
> After patch:
> 
> $ misc/ss -a autobound 
> State      Recv-Q Send-Q      Local Address:Port          Peer Address:Port   
> LISTEN     0      128                     *:44624                    *:*       
> ESTAB      0      0            192.168.1.21:47141        74.125.79.109:imaps   
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied thanks

