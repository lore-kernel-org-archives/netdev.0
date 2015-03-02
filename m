From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] net: Remove iocb argument from sendmsg
 and recvmsg
Date: Mon, 02 Mar 2015 13:06:56 -0500 (EST)
Message-ID: <20150302.130656.1723071239422371932.davem@davemloft.net>
References: <1425281868-25684-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, hch@lst.de, netdev@vger.kernel.org,
	erik.hugne@ericsson.com, jon.maloy@ericsson.com
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52315 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753977AbbCBSHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 13:07:04 -0500
In-Reply-To: <1425281868-25684-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Mon, 2 Mar 2015 15:37:46 +0800

> Currently there is only one user - TIPC whose sendmsg() instances
> using iocb argument. Meanwhile, there is no user using iocb argument
> in its recvmsg() instance. Therefore, if we eliminate the werid usage
> of iobc argument from TIPC, the iocb argument can be removed from
> all sendmsg() and recvmsg() instances of the whole networking stack.
> 
> Reference:
> https://patchwork.ozlabs.org/patch/433960/
> 
> Changes:
> 
> v2:
>  * Fix compile errors of DCCP module pointed by David

Series applied, thanks.
