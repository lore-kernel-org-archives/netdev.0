From: David Miller <davem@davemloft.net>
Subject: Re: packet received in a wrong rx-queue?
Date: Wed, 18 May 2011 05:13:37 -0400 (EDT)
Message-ID: <20110518.051337.1758997463750600514.davem@davemloft.net>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F250D748939@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jon.Zhou@jdsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48989 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573Ab1ERJNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 05:13:50 -0400
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F250D748939@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Zhou <Jon.Zhou@jdsu.com>
Date: Wed, 18 May 2011 02:00:50 -0700

> There are 2 packets in the traffic
> 
> #1 create PDP context request, IPV4--UDP--GTP, src_ip=A and dst_ip=B,src_port=C,dst_port=D
> 
> #2 create PDP context response, IPV4--UDP--GTP,src_ip=B, dst_ip=A, src_port=D,dst_port=C
> 
> I suppose both of them will be received in same rx-queue but actually it doesn't

Well, for hardware flow steering, it's not expected to.
