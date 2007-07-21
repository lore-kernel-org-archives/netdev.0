From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Resurrect napi_poll patch.
Date: Sat, 21 Jul 2007 11:54:28 -0700 (PDT)
Message-ID: <20070721.115428.48807536.davem@davemloft.net>
References: <1185002071.6344.21.camel@localhost.localdomain>
	<20070721.004234.122616332.davem@davemloft.net>
	<1185004811.6344.37.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48915
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755890AbXGUSy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 14:54:29 -0400
In-Reply-To: <1185004811.6344.37.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Sat, 21 Jul 2007 18:00:11 +1000

> No, I was just thinking that drivers will put the napi_struct in their
> driver-specific struct (eg. struct e1000_adapter *adapter =
> container_of(container_of(napi, struct e1000_adapter, napi);).  

That works.

> Multi-queue drivers will have no use for a napi_struct in net_device,
> right?  They'll need some wrapper "my_queue" structure containing the
> napi_struct anyway.

Sure, we can eliminate the napi_struct in struct net_device
eventually.

But then again, like the statistics, if it's convenient to
just use the in-net_device one then why not :)
