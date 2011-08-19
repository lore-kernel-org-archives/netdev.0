From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-2.6] vlan: reset headers on accel emulation path
Date: Thu, 18 Aug 2011 21:29:44 -0700 (PDT)
Message-ID: <20110818.212944.479482017214102055.davem@davemloft.net>
References: <1313685345-2417-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregkh@suse.de, kaber@trash.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40655 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681Ab1HSEbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 00:31:02 -0400
In-Reply-To: <1313685345-2417-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu, 18 Aug 2011 18:35:45 +0200

> It's after all necessary to do reset headers here. The reason is we
> cannot depend that it gets reseted in __netif_receive_skb once skb is
> reinjected. For incoming vlanids without vlan_dev, vlan_do_receive()
> returns false with skb != NULL and __netif_reveive_skb continues, skb is
> not reinjected.
> 
> This might be good material for 3.0-stable as well
> 
> Reported-by: Mike Auty <mike.auty@gmail.com>
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied and queued up for -stable, thanks Jiri!
