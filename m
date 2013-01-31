From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] ipv6: do not create neighbor entries for local
 delivery
Date: Wed, 30 Jan 2013 20:26:39 -0500 (EST)
Message-ID: <20130130.202639.978642110493467876.davem@davemloft.net>
References: <20130130082608.GA1604@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, mleitner@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756012Ab3AaB0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 20:26:41 -0500
In-Reply-To: <20130130082608.GA1604@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 30 Jan 2013 09:26:08 +0100

> From: Marcelo Ricardo Leitner <mleitner@redhat.com>
> 
> They will be created at output, if ever needed. This avoids creating
> empty neighbor entries when TPROXYing/Forwarding packets for addresses
> that are not even directly reachable.
> 
> Note that IPv4 already handles it this way. No neighbor entries are
> created for local input.
> 
> Tested by myself and customer.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>

Applied and queued up for -stable, thanks.
