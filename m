From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] connector: add an event for monitoring process tracers
Date: Wed, 13 Jul 2011 07:53:01 -0700 (PDT)
Message-ID: <20110713.075301.2281640410968902358.davem@davemloft.net>
References: <1310502757-32103-1-git-send-email-vzapolskiy@gmail.com>
	<20110713124832.GA28307@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vzapolskiy@gmail.com, oleg@redhat.com, roland@redhat.com,
	netdev@vger.kernel.org
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55439 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754548Ab1GMOxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 10:53:30 -0400
In-Reply-To: <20110713124832.GA28307@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Wed, 13 Jul 2011 16:48:32 +0400

> On Tue, Jul 12, 2011 at 11:32:37PM +0300, Vladimir Zapolskiy (vzapolskiy@gmail.com) wrote:
>> This change adds a procfs connector event, which is emitted on every
>> successful process tracer attach or detach.
>> 
>> If some process connects to other one, kernelspace connector reports
>> process id and thread group id of both these involved processes. On
>> disconnection null process id is returned.
>> 
>> Such an event allows to create a simple automated userspace mechanism
>> to be aware about processes connecting to others, therefore predefined
>> process policies can be applied to them if needed.
> 
> Looks good to me, thank you.
> Acked-by: Evgeniy Polyakov <zbr@ioremap.net>

Since this isn't really "networking" it would be really nice if this
was taken in via some other tree, you can add my ack:

Acked-by: David S. Miller <davem@davemloft.net>
