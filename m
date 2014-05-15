From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] loopback: explicitly set pkt_type to PACKET_HOST
Date: Thu, 15 May 2014 16:34:00 -0400 (EDT)
Message-ID: <20140515.163400.1536463708975272927.davem@davemloft.net>
References: <1400092762-23287-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35884 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752915AbaEOUeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 16:34:03 -0400
In-Reply-To: <1400092762-23287-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 14 May 2014 11:39:22 -0700

> From: Cong Wang <cwang@twopensource.com>
> 
> In a corner case where I redirect the packets from veth to lo,
> packets are dropped silently when entering IP stack. This is
> due to we have a different MAC addr on veth, so the packets are
> marked as PACKET_OTHERHOST. And after they are redirect to lo,
> this value is kept since lo has the same MAC addr with the packets.
> Loopback should explicitly set it to PACKET_HOST before calling
> eth_type_trans() for this specific case.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>

How exactly are you performing this redirection?
