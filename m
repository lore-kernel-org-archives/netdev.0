From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v4] netpoll: fix a rtnl lock assertion failure
Date: Wed, 16 Jan 2013 22:52:38 -0500 (EST)
Message-ID: <20130116.225238.238898828520417471.davem@davemloft.net>
References: <1358242446-4273-1-git-send-email-amwang@redhat.com>
	<1358385885.32167.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org, jiri@resnulli.us
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43413 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758472Ab3AQDwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 22:52:40 -0500
In-Reply-To: <1358385885.32167.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Jan 2013 17:24:45 -0800

>>  	if (np->dev_name)
>> -		ndev = dev_get_by_name(&init_net, np->dev_name);
>> +		ndev = __dev_get_by_name(&init_net, np->dev_name);
 ...
> Please revert this part.

You mean just revert that hunk above that made it use the
non-refcounting version of dev_get_by_name()?
