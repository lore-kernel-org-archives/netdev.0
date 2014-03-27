From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vlan: Set hard_header_len according to available
 acceleration
Date: Thu, 27 Mar 2014 15:01:07 -0400 (EDT)
Message-ID: <20140327.150107.987417092647041729.davem@davemloft.net>
References: <1395848876-15244-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56618 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756825AbaC0TBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 15:01:09 -0400
In-Reply-To: <1395848876-15244-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Wed, 26 Mar 2014 11:47:56 -0400

> Currently, if the card supports CTAG acceleration we do not
> account for the vlan header even if we are configuring an
> 8021AD vlan.  This may not be best since we'll do software
> tagging for 8021AD which will cause data copy on skb head expansion
> Configure the length based on available hw offload capabilities and
> vlan protocol.
> 
> CC: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Applied and queued up for -stable, thanks Vlad.
