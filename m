From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH net-next] cxgb4: set skb->rxhash
Date: Tue, 27 Apr 2010 15:46:45 -0700
Message-ID: <4BD76955.1030104@chelsio.com>
References: <1272406825-11615-1-git-send-email-dm@chelsio.com> <20100427.154338.223483726.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:27317 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757454Ab0D0Wqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 18:46:51 -0400
In-Reply-To: <20100427.154338.223483726.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Dimitris Michailidis <dm@chelsio.com>
> Date: Tue, 27 Apr 2010 15:20:25 -0700
> 
>> Implement the ->set_flags ethtool method to control NETIF_F_RXHASH and
>> set skb->rxhash to the HW calculated hash accordingly.
>>
>> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
> 
> Does the CXGB4 hash the ports for non-TCP packets?
> 
> If not, you will need to check the packet type (preferrably using
> RX descriptor information rather than actually parsing the packet)
> and only record the ->rxhash for TCP packets.
> 

It does, optionally.  Someday I need to implement ->set_rxnfc to expose the 
few available options but it's on by default.
