From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Fix support for macvlan devices on top
 bonding
Date: Wed, 04 Jun 2014 15:14:38 -0700 (PDT)
Message-ID: <20140604.151438.219076689159376438.davem@davemloft.net>
References: <1401913418-31307-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net, kaber@trash.net
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37394 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751578AbaFDWOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 18:14:40 -0400
In-Reply-To: <1401913418-31307-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Wed,  4 Jun 2014 16:23:35 -0400

> Currently, macvlan devices do not work well over bond interfaces.
> Everything works well, untill a failover is triggered in the bond
> device and then macvlan becomes unreachble untill arp entries
> are flushed.   This series adds needed functionality to
> handle correct notifications and update switches with mac addresses
> assigned to macvlans.
> 
> The first patch simply addes IFF_UNICAST_FLT flag to bonds since they
> already correctly manage the unicast filter list of the slaves, so
> we might as well prevent the bond from needlessly going into promiscuous
> mode.
> 
> The second patch adds notifier handler to macvlan to trigger correct
> ARP notifications.
> 
> The third patch adds handling for TLB and RLB modes that use special
> ETH_P_LOOPBACK type packets to teach switch about mac addresses.
> It also allow ARPs for the macvlan mac addresses to be handled by
> RLB mode.

Series applied, thanks Vlad.
