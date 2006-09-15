From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] bridge: add ETH_HLEN to packet_length
Date: Fri, 15 Sep 2006 09:57:19 +0900
Message-ID: <20060915095719.71baaf91@localhost.localdomain>
References: <20060914182751.GA15203@kudzu.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:53673 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751386AbWIOA6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 20:58:20 -0400
To: Jon Mason <jdmason@kudzu.us>
In-Reply-To: <20060914182751.GA15203@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Sep 2006 13:27:54 -0500
Jon Mason <jdmason@kudzu.us> wrote:

> In br_dev_queue_push_xmit, why is the check to drop mtu oversized
> packets not checking for enough room for the impending ETH_HLEN size
> skb_push?  In some code currently under development, we are seeing
> skb_under_panic being called from the "skb_push(skb, ETH_HLEN)" in that
> code.  It seems to me it would be better to drop those skbs than panic.
> Attached is a patch to do this.
> 
> Thanks,
> Jon

This is bridge code, it assumes that any device that claims to be a
ethernet device has done the proper reservation. What device are
you using?
