From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: Don't assume 802.1Q when sending alb
 learning packets.
Date: Thu, 22 May 2014 15:45:11 -0400 (EDT)
Message-ID: <20140522.154511.1728176095337929068.davem@davemloft.net>
References: <1400685879-21843-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037AbaEVTpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 15:45:13 -0400
In-Reply-To: <1400685879-21843-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Wed, 21 May 2014 11:24:39 -0400

> TLB/ALB learning packets always assume 802.1Q vlan protocol, but
> that is no longer the case since we now have support for Q-in-Q
> on top of bonding.  Pass the vlan protocol to alb_send_lp_vid()
> so that the packets are properly tagged.
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Applied, thanks Vlad.
