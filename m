From: David Miller <davem@davemloft.net>
Subject: Re: [patch net/stable] ipv6/exthdrs: accept tlv which includes
 only padding
Date: Wed, 11 Sep 2013 15:53:01 -0400 (EDT)
Message-ID: <20130911.155301.1665252915703098120.davem@davemloft.net>
References: <1378476145-6282-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, eldad@fogrefinery.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46360 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754742Ab3IKTxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 15:53:04 -0400
In-Reply-To: <1378476145-6282-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri,  6 Sep 2013 16:02:25 +0200

> In rfc4942 and rfc2460 I cannot find anything which would implicate to
> drop packets which have only padding in tlv.
> 
> Current behaviour breaks TAHI Test v6LC.1.2.6.
> 
> Problem was intruduced in:
> 9b905fe6843 "ipv6/exthdrs: strict Pad1 and PadN check"
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Ok I've changed my position, applied and queued up for -stable.

Thanks.
