From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: Avoid cache line dirtying
Date: Tue, 20 Oct 2009 01:07:53 -0700 (PDT)
Message-ID: <20091020.010753.129086177.davem@davemloft.net>
References: <4AD87CEC.4020407@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, deri@ntop.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59687
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751076AbZJTIHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 04:07:31 -0400
In-Reply-To: <4AD87CEC.4020407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 16 Oct 2009 16:02:20 +0200

> While doing multiple captures, I found af_packet was dirtying cache line
> containing its prot_hook.
> 
> This slow down machines where several cpus are necessary to handle capture
> traffic, as each prot_hook is traversed for each packet coming in or out
> the host.
> 
> This patches moves "struct packet_type prot_hook" to the end of 
> packet_sock, and uses a ____cacheline_aligned_in_smp to make sure
> this remains shared by all cpus.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
