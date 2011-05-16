From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: Fix inconsistent LRO state after
 initialization
Date: Mon, 16 May 2011 15:05:48 -0400 (EDT)
Message-ID: <20110516.150548.2029816108090072202.davem@davemloft.net>
References: <201105161828.15237.thomas.jarosch@intra2net.com>
	<20110516101444.29eec9dc@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.jarosch@intra2net.com, netdev@vger.kernel.org,
	sbhatewara@vmware.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43699 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649Ab1EPTFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 15:05:55 -0400
In-Reply-To: <20110516101444.29eec9dc@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 16 May 2011 10:14:44 -0700

> On Mon, 16 May 2011 18:28:15 +0200
> Thomas Jarosch <thomas.jarosch@intra2net.com> wrote:
> 
>> During initialization of vmxnet3, the state of LRO
>> gets out of sync with netdev->features.
 ...
>> Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
> 
> Thanks for finding this. Vyatta ended up changing the default of adapter->lro
> to workaround just this problem
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
