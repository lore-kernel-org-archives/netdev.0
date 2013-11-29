From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net: clamp ->msg_namelen instead of returning an error
Date: Fri, 29 Nov 2013 16:13:51 -0500 (EST)
Message-ID: <20131129.161351.2154176731890615742.davem@davemloft.net>
References: <20131127124021.GA2025@elgon.mountain>
	<1385587666.5352.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, netdev@vger.kernel.org,
	normalperson@yhbt.net, hannes@stressinduktion.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54748 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753712Ab3K2VNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 16:13:53 -0500
In-Reply-To: <1385587666.5352.13.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Nov 2013 13:27:46 -0800

> On Wed, 2013-11-27 at 15:40 +0300, Dan Carpenter wrote:
>> If kmsg->msg_namelen > sizeof(struct sockaddr_storage) then in the
>> original code that would lead to memory corruption in the kernel if you
>> had audit configured.  If you didn't have audit configured it was
>> harmless.
>> 
>> There are some programs such as beta versions of Ruby which use too
>> large of a buffer and returning an error code breaks them.  We should
>> clamp the ->msg_namelen value instead.
>> 
>> Reported-by: Eric Wong <normalperson@yhbt.net>
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> Fixes: 1661bf364ae9 ("net: heap overflow in __audit_sockaddr()")
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks everyone.
