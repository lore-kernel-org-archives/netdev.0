From: David Miller <davem@davemloft.net>
Subject: Re: Getting a NIC's MTU size
Date: Thu, 20 Feb 2014 13:45:04 -0500 (EST)
Message-ID: <20140220.134504.889753387361360927.davem@davemloft.net>
References: <26769.1392390042@warthog.procyon.org.uk>
	<27696.1392392957@warthog.procyon.org.uk>
	<16869.1392917423@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58072 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754244AbaBTSpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 13:45:06 -0500
In-Reply-To: <16869.1392917423@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Thu, 20 Feb 2014 17:30:23 +0000

> David Miller <davem@davemloft.net> wrote:
> 
>> > One further question: If I want to get the MTU size of the NIC through
>> > which packets will go to get to a particular peer, can I do:
>> 
>> As has been suggested or at least hinted to by others, you have to use
>> the route dst's device pointer.
> 
> So I gather.  My query was intended to be about the safety of accessing the
> dst->dev pointer.  Can I just dereference it?  Or do I need to take a lock or
> use RCU?

If the dst is valid and you have a reference to it, dst->dev is good.
