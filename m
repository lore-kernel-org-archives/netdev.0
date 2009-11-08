From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Support specifying the network namespace upon
 device creation.
Date: Sun, 08 Nov 2009 00:54:07 -0800 (PST)
Message-ID: <20091108.005407.91447800.davem@davemloft.net>
References: <m1eioggeux.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44753
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753113AbZKHIxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 03:53:41 -0500
In-Reply-To: <m1eioggeux.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 03 Nov 2009 01:03:02 -0800

> 
> There is no good reason to not support userspace specifying the
> network namespace during device creation, and it makes it easier
> to create a network device and pass it to a child network namespace
> with a well known name.
> 
> We have to be careful to ensure that the target network namespace
> for the new device exists through the life of the call.  To keep
> that logic clear I have factored out the network namespace grabbing
> logic into rtnl_link_get_net.
> 
> In addtion we need to continue to pass the source network namespace
> to the rtnl_link_ops.newlink method so that we can find the base
> device source network namespace.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>

Applied to net-next-2.6, thanks!
