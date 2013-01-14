From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v3] netpoll: fix a rtnl lock assertion failure
Date: Mon, 14 Jan 2013 18:13:50 -0500 (EST)
Message-ID: <20130114.181350.1796205610296377637.davem@davemloft.net>
References: <1358160234-24996-1-git-send-email-amwang@redhat.com>
	<1358183252.8744.3094.camel@edumazet-glaptop>
	<1358183396.8744.3100.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org, jiri@resnulli.us
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35515 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757034Ab3ANXNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 18:13:53 -0500
In-Reply-To: <1358183396.8744.3100.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Jan 2013 09:09:56 -0800

> On Mon, 2013-01-14 at 09:07 -0800, Eric Dumazet wrote:
> 
>> Strange, why dont we call netdev_master_upper_dev_get() instead ?
>> 
>> 
> 
> What I meant is : the result of this check might be of little use, if we
> don't hold any lock preventing another thread to change things behind
> us.

Agreed, this test is going to be racey.
