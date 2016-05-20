From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: prevent skbs lingering in tunnel socket queues
Date: Fri, 20 May 2016 19:56:43 -0400 (EDT)
Message-ID: <20160520.195643.1333214069455173482.davem@davemloft.net>
References: <1463666313-12743-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbcETX4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 19:56:45 -0400
In-Reply-To: <1463666313-12743-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 19 May 2016 15:58:33 +0200

> In case we find a socket with encapsulation enabled we should call
> the encap_recv function even if just a udp header without payload is
> available. The callbacks are responsible for correctly verifying and
> dropping the packets.
> 
> Also, in case the header validation fails for geneve and vxlan we
> shouldn't put the skb back into the socket queue, no one will pick
> them up there.  Instead we can simply discard them in the respective
> encap_recv functions.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Looks good, applied and queued up for -stable.

Thanks!
