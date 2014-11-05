From: David Miller <davem@davemloft.net>
Subject: Re: Convert net_msg_warn, NETDEBUG, & LIMIT_NETDEBUG?
Date: Wed, 05 Nov 2014 17:16:23 -0500 (EST)
Message-ID: <20141105.171623.1142237070388305283.davem@davemloft.net>
References: <1415134000.23168.7.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: realty@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48732 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbaKEWQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 17:16:25 -0500
In-Reply-To: <1415134000.23168.7.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <realty@perches.com>
Date: Tue, 04 Nov 2014 12:46:40 -0800

> net_msg_warn is a sysctl used to control the printk
> of a bundle of mostly ipv4/ipv6 logging messages.
> 
> Does anyone use it?
  ...
> Should those KERN_DEBUG uses be converted to
> net_dbg_ratelimited so that these uses could be
> controlled via dynamic_debug instead of the
> net_msg_warn sysctl?
  ...

I will respond to this by saying that, generally speaking, I'd
rather we move away from local debugging facility and controls
and towards the generic ones.

Definitely kill the allocation failure debug stuff, that's obviously
superfluous and bogus.

It may be the case that we're stuck with the net_msg_warn sysctl
for the stuff that isn't obviously extraneous and removable like
the allocation failure cases.

Why don't we work on these one at a time and see what's left after
all the adjustments/deletions?

Thanks.
